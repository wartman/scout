package scout.macro;

import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import haxe.macro.Context;

using Lambda;
using haxe.macro.Tools;
using scout.macro.MacroTools;

class ModelBuilder {

  public static function build() {
    return new ModelBuilder(
      Context.getLocalClass().get(),
      Context.getBuildFields()
    ).export();
  }

  private var c:ClassType;
  private var fields:Array<Field>;
  private var newFields:Array<Field> = [];
  private var props:Array<Field> = [];
  private var signals:Array<Field> = [];
  private var initializers:Array<Expr> = [];

  public function new(c:ClassType, fields:Array<Field>) {
    this.c = c;
    this.fields = fields;
  }

  public function export():Array<Field> {
    var out = filterFieldsAndExtractProps();
    addImplFields();
    return out.concat(newFields);
  }

  private function filterFieldsAndExtractProps():Array<Field> {
    return fields.filter(function (f) {
      switch (f.kind) {
        case FVar(t, e):
          var propNames = [ ':prop', ':property' ];
          if (f.meta.hasMeta(propNames)) {
            var propIsOptional = f.meta.hasMeta([ ':optional' ]) || e != null;
            var metas = f.meta.extractMeta(propNames);
            if (metas.length > 1) {
              Context.error('A var may only have one :prop or :property metadata entry', f.pos);
            }
            var options = extractPropOptions(metas[0]);

            if (options.has(PropAuto)) {
              propIsOptional = true;
              if (!newFields.exists(function (f) return f.name == '__scout_ids')) {
                newFields.push({
                  name: '__scout_ids',
                  access: [ APrivate, AStatic ],
                  kind: FVar(macro:Int, macro 0),
                  pos: Context.currentPos()
                });
              }
              e = macro __scout_ids++;
            }

            if (options.has(PropOptional)) {
              propIsOptional = true;
            }
            
            props.push(makeRealProp(f.name, t, f.pos, propIsOptional));
            newFields.push(makeProp(f.name, t, f.pos));
            newFields.push(makeGetter(f.name, t, f.pos));
            newFields.push(makeSetter(f.name, t, f.pos));
            signals.push(makeSignal(f.name, t, f.pos));

            var propName = f.name;
            if (e != null) {
              initializers.push(macro if (props.$propName == null) {
                this.$propName = ${e}
              } else {
                this.$propName = props.$propName;
              });
            } else {
              initializers.push(macro this.$propName = props.$propName);
            }

            return false;
          }

          if (f.meta.exists(function (entry) return entry.name == ':computed')) {
            var watch = f.meta.find(function (entry) return entry.name == ':computed').params;
            var fieldName = f.name;
            var initializer = '__scout_init_${fieldName}';

            props.push(makeRealProp(fieldName, t, f.pos, true));
            newFields.push(makeProp(f.name, t, f.pos, false));
            newFields.push(makeGetter(f.name, t, f.pos));
            newFields.push({
              name: initializer,
              access: [ APrivate ],
              kind: FFun({
                ret: (macro:Void),
                args: [],
                expr: macro this.props.$fieldName = ${e}
              }),
              pos: Context.currentPos()
            });
            signals.push(makeSignal(f.name, t, f.pos));
            initializers.push(macro this.$initializer());
            watch.foreach(function (f) {
              switch (f.expr) {
                case EConst(c): switch (c) {
                  case CString(s) | CIdent(s):
                    initializers.push(macro this.signals.$s.add(function (_) {
                      this.$initializer();
                      this.signals.$fieldName.dispatch(this.$fieldName);
                    }));
                  default:
                    throw new Error('Only strings or identifiers are allowed in :computed', f.pos);
                }
                default:
                  throw new Error('Only strings or identifiers are allowed in :computed', f.pos);
              }
              return true;
            });

            return false;
          }

          return true;

        case FFun(func):
          var name = f.name;
          
          if (f.meta.exists(function (m) return m.name == ':observe')) {
            var metas = f.meta.filter(function (m) return m.name == ':observe');
            for (meta in metas) {
              var expr = meta.params[0];
              f.meta.remove(meta);
              initializers.push(macro @:pos(f.pos) ${expr}.add(this.$name));
            }
          }
          
          if (f.meta.exists(function (m) return m.name == ':transition')) {
            var expr = func.expr;
            func.expr = macro {
              silent = true;
              ${expr};
              silent = false;
              // todo: maybe track changes and only fire `onChange` if they
              // are greater than 0?
              onChange.dispatch(this);
            };
          }

          return true;

        default: return true;
      }
    });
  }

  private function addImplFields() {
    var propsType = TAnonymous(props);
    var signalsType = TAnonymous(signals);
    var localType = TPath({ pack: c.pack, name: c.name });

    newFields = newFields.concat((macro class {

      public var props(default, null):$propsType;
      public var signals(default, null):$signalsType;
      public var onChange(default, null):scout.Signal<$localType> = new scout.Signal();
      private var silent:Bool = false;

      public function new(props:$propsType) {
        this.props = cast {};
        this.signals = cast {};
        $b{ signals.map(function (field) {
          var name = field.name;
          return macro this.signals.$name = new scout.Signal();
        }) };
        $b{ initializers };
      }

      public function subscribe(listener:scout.Model->Void):scout.Signal.SignalSlot<Model> {
        return cast this.onChange.add(listener);
      }

    }).fields);
  }

  private function makeProp(name:String, t:ComplexType, pos:Position, hasSetter:Bool = true):Field {
    return {
      name: name,
      kind: FProp('get', hasSetter ? 'set' : 'never', t, null),
      access: [ APublic ],
      pos: pos
    };
  }

  private function makeRealProp(name:String, type:ComplexType, pos:Position, isOptional:Bool):Field {
    return {
      name: name,
      kind: FVar(type, null),
      access: [ APublic ],
      meta: isOptional ? [ { name: ':optional', pos: pos } ] : [],
      pos: pos
    };
  }

  private function makeGetter(name:String, ret:ComplexType, pos:Position):Field {
    return {
      name: 'get_${name}',
      kind: FFun({
        ret: ret,
        args: [],
        expr: macro return this.props.$name
      }),
      meta: [ { name: ':keep', pos:Context.currentPos() } ],
      access: [ AInline, APublic ],
      pos: pos
    };
  }

  private function makeSetter(name:String, t:ComplexType, pos:Position):Field {
    var watch:Array<Expr> = [];

    switch (t) {
      case TPath(p):
        // Todo: find a better method that allows subclasses
        if (p.name.indexOf('Collection') >= 0) {
          watch.push(macro this.props.$name.subscribe(function (c) {
            this.signals.$name.dispatch(c);
            if (!silent) {
              this.onChange.dispatch(this);
            }
          }));
        }
      default:
    }

    return {
      name: 'set_${name}',
      kind: FFun({
        ret: t,
        args: [ { name: 'value', type: t } ],
        expr: macro {
          if (this.props.$name == value) {
            return value;
          }
          this.props.$name = value;
          this.signals.$name.dispatch(value);
          if (!silent) {
            this.onChange.dispatch(this);
          }
          $b{watch};
          return value;
        }
      }),
      // meta: [ { name: ':keep', pos:Context.currentPos() } ],
      access: [ APublic ],
      pos: pos
    };
  }

  private function makeSignal(name:String, type:ComplexType, pos:Position):Field {
    return {
      name: name,
      kind: FVar( TPath({
        pack: [ 'scout' ],
        name: 'Signal',
        params: [ TPType(type) ]
      }) ),
      access: [ APublic ],
      pos: pos
    };
  }

  private function extractPropOptions(meta:MetadataEntry):Array<PropOptions> {
    return [ for (e in meta.params) {
      switch (e.expr) {
        case EConst(CIdent(s)):
          switch (s) {
            case 'auto': PropAuto;
            case 'optional': PropOptional;
            default: Context.error('${s} is not a valid parameter for ${meta.name}', e.pos);
          }
        default:
          Context.error('${meta.name} only accepts identifiers', e.pos);
      }
    } ].filter(function (item) return item != null);
  }

}

private enum PropOptions {
  PropAuto;
  PropOptional;
}
