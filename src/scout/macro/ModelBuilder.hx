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

  var c:ClassType;
  var fields:Array<Field>;
  var newFields:Array<Field> = [];
  var props:Array<Field> = [];
  var states:Array<Field> = [];
  var stateInitializers:Array<Expr> = [];
  var initializers:Array<Expr> = [];
  var observableType = Context.getType('scout.Observable');

  public function new(c:ClassType, fields:Array<Field>) {
    this.c = c;
    this.fields = fields;
  }

  public function export():Array<Field> {
    ensureId();
    var out = filterFieldsAndExtractProps();
    addImplFields();
    return out.concat(newFields);
  }

  function ensureId() {
    if (!fields.exists(function (f) return f.name == 'id')) {
      fields = fields.concat((macro class {
        @:prop(auto) var id:Int;
      }).fields);
    }
  }

  function filterFieldsAndExtractProps():Array<Field> {
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

            // var propName = f.name;
            states.push(makeState(f.name, t, e, f.pos));

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
                expr: macro this.states.$fieldName.set(${e})
              }),
              pos: Context.currentPos()
            });
            states.push(makeState(f.name, t, null, f.pos));
            initializers.push(macro this.$initializer());
            watch.foreach(function (f) {
              switch (f.expr) {
                case EConst(c): switch (c) {
                  case CString(s) | CIdent(s):
                    initializers.push(macro this.states.$s.subscribe(function (_) {
                      this.$initializer();
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
              initializers.push(macro @:pos(f.pos) scout.Signal.observe(${expr}, this.$name));
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

  function addImplFields() {
    var propsType = TAnonymous(props);
    var statesType = TAnonymous(states);
    var localType = TPath({ pack: c.pack, name: c.name });

    newFields = newFields.concat((macro class {

      public var states(default, null):$statesType;
      public var onChange(default, null):scout.Signal<$localType> = new scout.Signal();
      var silent:Bool = false;

      public function new(props:$propsType) {
        this.states = cast {};
        $b{stateInitializers};
        $b{initializers};
      }

      public function subscribe(listener:scout.Model->Void):scout.Signal.SignalSlot<Model> {
        return cast this.onChange.add(listener);
      }

    }).fields);
  }

  function makeProp(name:String, t:ComplexType, pos:Position, hasSetter:Bool = true):Field {
    return {
      name: name,
      kind: FProp('get', hasSetter ? 'set' : 'never', t, null),
      access: [ APublic ],
      pos: pos
    };
  }

  function makeRealProp(name:String, type:ComplexType, pos:Position, isOptional:Bool):Field {
    return {
      name: name,
      kind: FVar(type, null),
      access: [ APublic ],
      meta: isOptional ? [ { name: ':optional', pos: pos } ] : [],
      pos: pos
    };
  }

  function makeGetter(name:String, ret:ComplexType, pos:Position):Field {
    return {
      name: 'get_${name}',
      kind: FFun({
        ret: ret,
        args: [],
        expr: macro return this.states.$name.get()
      }),
      meta: [ { name: ':keep', pos:Context.currentPos() } ],
      access: [ AInline, APublic ],
      pos: pos
    };
  }

  function makeSetter(name:String, t:ComplexType, pos:Position):Field {
    return {
      name: 'set_${name}',
      kind: FFun({
        ret: t,
        args: [ { name: 'value', type: t } ],
        expr: macro {
          this.states.$name.set(value);
          return value;
        }
      }),
      // meta: [ { name: ':keep', pos:Context.currentPos() } ],
      access: [ APublic ],
      pos: pos
    };
  }

  function makeState(name:String, type:ComplexType, ?e:Expr, pos:Position):Field {
    var obs = {
      name: name,
      kind: FVar(macro:scout.Stateful<$type>),
      access: [ APublic ],
      pos: pos
    };
    var init = e != null ? macro props.$name != null ? props.$name : ${e} : macro props.$name;
    if (Context.unify(type.toType(), observableType)) {
      stateInitializers.push(macro this.states.$name = new scout.ObservableState(${init}));
    } else { 
      stateInitializers.push(macro this.states.$name = new scout.State(${init}));
    }

    initializers.push(macro {
      this.states.$name.subscribe(function (_) {
        if (!this.silent) this.onChange.dispatch(this);
      });
    });

    return obs;
  }

  function extractPropOptions(meta:MetadataEntry):Array<PropOptions> {
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

enum PropOptions {
  PropAuto;
  PropOptional;
}
