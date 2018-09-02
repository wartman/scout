package scout.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
using haxe.macro.Tools;

class ModelBuilder {

  public static function build() {
    var c = Context.getLocalClass().get();
    var fields:Array<Field> = Context.getBuildFields();
    var newFields:Array<Field> = [];
    var props:Array<Field> = [];
    var signals:Array<Field> = [];
    var defaults:Array<Expr> = [];

    fields = fields.filter(function (f) {
      switch (f.kind) {
        case FVar(t, e):
          if (f.meta.exists(function (entry) return entry.name == ':property' || entry.name == ':prop')) {
            props.push(makeRealProp(f.name, t, f.pos, f.meta.exists(function (entry) return entry.name == ':optional') || e != null));
            newFields.push(makeProp(f.name, t, f.pos));
            newFields.push(makeGetter(f.name, t, f.pos));
            newFields.push(makeSetter(f.name, t, f.pos));
            signals.push(makeSignal(f.name, t, f.pos));

            if (e != null) {
              var propName = f.name;
              defaults.push(macro if (this.props.$propName == null) this.$propName = ${e});
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
            defaults.push(macro this.$initializer());

            watch.foreach(function (f) {
              switch (f.expr) {
                case EConst(c): switch (c) {
                  case CString(s) | CIdent(s):
                    defaults.push(macro this.signals.$s.add(function (_) {
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
        default: return true;
      }
    });

    newFields.push({
      name: 'props',
      access: [ APrivate ],
      kind: FVar( TAnonymous(props), null ),
      pos: Context.currentPos()
    });

    newFields.push({
      name: 'signals',
      access: [ APublic ],
      kind: FVar( TAnonymous(signals) ),
      pos: Context.currentPos()
    });

    newFields.push({
      name: 'onChange',
      access: [ APublic ],
      kind: FVar( TPath({
        pack: [ 'scout' ],
        name: 'Signal',
        params: [ TPType(TPath({
          pack: c.pack,
          name: c.name
        })) ]
      }), macro new scout.Signal() ),
      pos: Context.currentPos()
    });

    var propType = TAnonymous(props);
    var localType = TPath({ pack: c.pack, name: c.name });

    newFields = newFields.concat((macro class {

      public function new(props:$propType) {
        this.props = props;
        this.signals = cast {};
        $b{ signals.map(function (field) {
          var name = field.name;
          return macro this.signals.$name = new scout.Signal();
        }) };
        $b{ defaults };
      }

      public function subscribe(listener:scout.Model->Void):scout.Signal.SignalSlot<Model> {
        return cast this.onChange.add(listener);
      }

    }).fields);

    fields = fields.concat(newFields);
    return fields;
  }

  private static function makeProp(name:String, t:ComplexType, pos:Position, hasSetter:Bool = true):Field {
    return {
      name: name,
      kind: FProp('get', hasSetter ? 'set' : 'never', t, null),
      access: [ APublic ],
      pos: pos
    };
  }

  private static function makeRealProp(name:String, type:ComplexType, pos:Position, isOptional:Bool):Field {
    return {
      name: name,
      kind: FVar(type, null),
      access: [ APublic ],
      meta: isOptional ? [ { name: ':optional', pos: pos } ] : [],
      pos: pos
    };
  }

  private static function makeGetter(name:String, ret:ComplexType, pos:Position):Field {
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

  private static function makeSetter(name:String, t:ComplexType, pos:Position):Field {
    var watch:Array<Expr> = [];

    switch (t) {
      case TPath(p):
        // Todo: find a better method that allows subclasses
        if (p.name.indexOf('Collection') >= 0) {
          watch.push(macro this.props.$name.subscribe(function (c) {
            this.signals.$name.dispatch(c);
            this.onChange.dispatch(this);
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
          this.onChange.dispatch(this);
          this.signals.$name.dispatch(value);
          $b{watch};
          return value;
        }
      }),
      // meta: [ { name: ':keep', pos:Context.currentPos() } ],
      access: [ APublic ],
      pos: pos
    };
  }

  private static function makeSignal(name:String, type:ComplexType, pos:Position):Field {
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

}