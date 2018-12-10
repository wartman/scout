#if macro
package scout.macro;

import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import haxe.macro.Context;

using Lambda;
using haxe.macro.Tools;
using scout.macro.MetadataTools;

class ModelBuilder {

  static final propMetaNames = [ ':prop', ':property' ];
  static final compMetaNames = [ ':comp', ':computed' ];
  static final observeMetaNames = [ ':observe' ];
  static final transitionMetaNames = [ ':transition' ];
  static final initMetaNames = [ ':init' ];
  static var processed:Array<ClassType> = [];

  public static function build() {
    return new ModelBuilder(
      Context.getLocalClass().get(),
      Context.getBuildFields()
    ).export();
  }

  var c:ClassType;
  var fields:Array<Field>;
  var constructorFields:Array<Field> = [];
  var states:Array<Field> = [];
  var stateInitializers:Array<Expr> = [];
  var initializers:Array<Expr> = [];

  public function new(c:ClassType, fields:Array<Field>) {
    this.c = c;
    this.fields = fields;
  }

  public function export():Array<Field> {
    if (processed.has(c)) return fields;
    processed.push(c);
    ensureId();
    addProps();
    addImplFields();
    return fields;
  }

  function ensureId() {
    if (!fields.exists(function (f) return f.name == 'id')) {
      fields = fields.concat((macro class {
        static var __scout_ids:Int = 0;
        @:prop var id:Int = __scout_ids += 1;
      }).fields);
    }
  }

  function addProps() {
    var newFields:Array<Field> = [];
    fields = fields.filter(f -> {
      if (f.meta == null) return true;

      switch (f.kind) {
        case FVar(t, e):
          if (f.meta.hasEntry(propMetaNames)) {
            newFields = newFields.concat(makeFieldsForProp(f, t, e));
            return false;
          }
          if (f.meta.hasEntry(compMetaNames)) {
            newFields = newFields.concat(makeFieldsForComputed(f, t, e));
            return false;
          }
          return true;

        case FFun(func):
          if (f.meta.hasEntry(observeMetaNames)) {
            var name = f.name;
            var metas = f.meta.extract(observeMetaNames);
            for (meta in metas) {
              if (meta.params.length == 0) {
                Context.error('An identifier is required', f.pos);
              } else if (meta.params.length > 1) {
                Context.error('Only one param is allowed here', f.pos);
              }
              initializers.push(Common.makeObserverForState(meta.params[0], macro this.$name));
            }
          }
          if (f.meta.hasEntry(transitionMetaNames)) {
            var expr = func.expr;
            func.expr = macro {
              __scout_silent = true;
              ${expr};
              __scout_silent = false;
              // todo: maybe track changes and only fire `onChange` if they
              // are greater than 0?
              onChange.dispatch(this);
            }
          }
          if (f.meta.hasEntry(initMetaNames)) {
            var name = f.name;
            initializers.push(macro $i{name}());
          }
          return true;
        
        default: return true;
      }
    });
    fields = fields.concat(newFields);
  }

  function addImplFields() {
    var conArgType = TAnonymous(constructorFields);
    var statesType = TAnonymous(states);
    var localType = TPath({ pack: c.pack, name: c.name });

    fields = fields.concat((macro class {

      public final props:$statesType;
      public final onChange:scout.Signal<$localType> = new scout.Signal();
      var __scout_silent:Bool = false;
      // var __scout_changes:Int = 0;

      public function new(props:$conArgType) {
        this.props = cast {};
        $b{stateInitializers};
        __scout_init();
      }

      function __scout_init() {
        $b{initializers};
      }

      public function observe(listener:scout.Model->Void):scout.Signal.SignalSlot<Model> {
        return cast this.onChange.add(cast listener);
      }

    }).fields);
  }

  function makeFieldsForProp(f:Field, t:ComplexType, ?e:Expr):Array<Field> {
    var metas = f.meta.extract(propMetaNames);
    if (metas.length > 1) {
      Context.error('A var may only have one :prop or :property metadata entry', f.pos);
    }
    var propIsOptional = f.meta.hasEntry([ ':optional' ]) || e != null;
    
    constructorFields.push(Common.makeConstructorField(f.name, t, f.pos, propIsOptional));
    states.push(makeState(f.name, t, e, f.pos));
    
    return [
      Common.makeProp(f.name, t, f.pos),
      Common.makeStateGetter('props', f.name, t, f.pos),
      Common.makeStateSetter('props', f.name, t, f.pos)
    ];
  }

  function makeFieldsForComputed(f:Field, t:ComplexType, e:Expr):Array<Field> {
    var metas = f.meta.extract(compMetaNames);
    if (metas.length > 1) {
      Context.error('A var may only have one :comp or :computed metadata entry', f.pos);
    }
    var watch = metas[0].params;
    var name = f.name;
    var initializer = '__scout_init_${f.name}';
    
    constructorFields.push(Common.makeConstructorField(f.name, t, f.pos, true));
    var out = [
      Common.makeProp(f.name, t, f.pos, false),
      Common.makeStateGetter('props', f.name, t, f.pos)
    ].concat((macro class {
      function $initializer():Void {
        this.props.$name.set(${e});
      }
    }).fields);
    states.push(makeState(f.name, t, null, f.pos));
    initializers.push(macro this.$initializer());
    for (target in watch) switch (target.expr) {
      case EConst(c): switch (c) {
        case CString(s) | CIdent(s):
          initializers.push(macro this.props.$s.observe(_ -> this.$initializer()));
        default:
          throw new Error('Only strings or identifiers are allowed in :computed', f.pos);
      }
      default:
        throw new Error('Only strings or identifiers are allowed in :computed', f.pos);
    }
    return out;
  }

  function makeState(name:String, type:ComplexType, ?e:Expr, pos:Position):Field {
    stateInitializers.push(Common.makeStateInitializer('props', 'props', name, type, e));
    initializers.push(macro {
      this.props.$name.observe(function (_) {
        if (!this.__scout_silent) this.onChange.dispatch(this);
      });
    });
    return Common.makeState(name, type, pos);
  }

}
#end
