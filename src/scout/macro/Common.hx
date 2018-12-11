#if macro
package scout.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.Tools;

class Common {

  public static function makeObserverForState(prop:Expr, target:Expr) {
    return macro @:pos(prop.pos) ${prop}.observe(${target}); 
  }

  public static function makeProp(name:String, type:ComplexType, pos:Position, hasSetter:Bool = true):Field {
    return {
      name: name,
      kind: FProp('get', hasSetter ? 'set' : 'never', type, null),
      access: [ APublic ],
      pos: pos
    };
  }

  public static function makeGetter(name:String, ret:ComplexType, expr:Expr, pos:Position):Field {
    return {
      name: 'get_$name',
      kind: FFun({
        ret: ret,
        args: [],
        expr: expr
      }),
      meta: [ { name: ':keep', pos: pos } ],
      access: [ APublic ],
      pos: pos
    };
  }

  public static function makeSetter(name:String, ret:ComplexType, expr:Expr, pos:Position):Field {
    return {
      name: 'set_${name}',
      kind: FFun({
        ret: ret,
        args: [ { name: 'value', type: ret } ],
        expr: expr
      }),
      meta: [ { name: ':keep', pos: pos } ],
      access: [ APublic ],
      pos: pos
    };
  }

  public static function makeValueGetter(propsName:String, name:String, ret:ComplexType, pos:Position):Field {
    return makeGetter(
      name,
      ret,
      macro return this.$propsName.$name,
      pos
    );
  }

  public static function makeValueSetter(propsName:String, name:String, ret:ComplexType, pos:Position):Field {
    return makeSetter(
      name,
      ret,
      macro @:pos(pos) {
        this.$propsName.$name = value;
        return value;
      },
      pos
    );
  }

  public static function makeStateGetter(propsName:String, name:String, ret:ComplexType, pos:Position):Field {
    return {
      name: 'get_$name',
      kind: FFun({
        ret: ret,
        args: [],
        expr: macro @:pos(pos) return this.$propsName.$name.get()
      }),
      meta: [ { name: ':keep', pos: pos } ],
      access: [ APublic ],
      pos: pos
    };
  }

  public static function makeStateSetter(propsName:String, name:String, ret:ComplexType, pos:Position):Field {
    return {
      name: 'set_${name}',
      kind: FFun({
        ret: ret,
        args: [ { name: 'value', type: ret } ],
        expr: macro @:pos(pos) {
          this.$propsName.$name.set(value);
          return value;
        }
      }),
      meta: [ { name: ':keep', pos: pos } ],
      access: [ APublic ],
      pos: pos
    };
  }

  public static function makeValue(name:String, type:ComplexType, pos:Position):Field {
    return {
      name: name,
      kind: FVar(type),
      access: [ APublic ],
      pos: pos
    };
  }

  public static function makeConstructorField(name:String, type:ComplexType, pos:Position, isOptional:Bool):Field {
    return {
      name: name,
      kind: FVar(type, null),
      access: [ APublic ],
      meta: isOptional ? [ { name: ':optional', pos: pos } ] : [],
      pos: pos
    };
  }

  public static function makeState(name:String, type:ComplexType, pos:Position):Field {
    return {
      name: name,
      kind: FVar(macro:scout.State<$type>),
      access: [ APublic ],
      pos: pos
    };
  }

  public static function makeStateInitializer(argName:String, propsName:String, name:String, type:ComplexType, ?e:Expr, ?useChild:Bool = false) {
    var observableType = Context.getType('scout.Observable');
    var childType = Context.getType('scout.Child');

    var init = e != null 
      ? macro $p{[ argName, name ]} != null ? $p{[ argName, name ]} : ${e} 
      : macro $p{[ argName, name ]};
    
    if (useChild && Context.unify(type.toType().follow(), childType)) {
      return macro this.$propsName.$name = scout.State.ofChild(this, ${init});
    }
    
    return macro this.$propsName.$name = ${init};
  }

  public static function makeValueInitializer(argName:String, propsName:String, name:String, type:ComplexType, ?e:Expr) {
    var init = e != null 
      ? macro $p{[ argName, name ]} != null ? $p{[ argName, name ]} : ${e} 
      : macro $p{[ argName, name ]};
    
    return macro this.$propsName.$name = ${init};
  }

}
#end
