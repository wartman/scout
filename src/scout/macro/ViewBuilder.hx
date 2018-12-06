package scout.macro;

import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import haxe.macro.Context;

using scout.macro.MetadataTools;
using haxe.macro.Tools;

class ViewBuilder {
  
  static final attrMetaNames = [ ':attr', ':attribute' ];
  static final stateMetaNames = [ ':state' ];
  static final elMetaNames = [ ':el', ':element' ];
  static final compMetaNames = [ ':comp', ':computed' ];
  static final observeMetaNames = [ ':observe' ];
  static var childType = Context.getType('scout.Child');
  static var processed:Array<ClassType> = [];

  public static function buildJs() {
    return new ViewBuilder(
      Context.getLocalClass().get(),
      Context.getBuildFields(), 
      true
    ).export();
  }

  public static function buildSys() {
    return new ViewBuilder(
      Context.getLocalClass().get(),
      Context.getBuildFields(),
      false
    ).export();
  }

  var c:ClassType;
  var fields:Array<Field>;
  var constructorFields:Array<Field> = [];
  var attrs:Array<Field> = [];
  var attrInitializers:Array<Expr> = [];
  var initializers:Array<Expr> = [];
  var eventBindings:Array<Expr> = [];
  var isJs:Bool;

  public function new(c:ClassType, fields:Array<Field>, isJs:Bool) {
    this.c = c;
    this.fields = fields;
    this.isJs = isJs;
  }

  public function export() {
    addElement();
    addAttrsAndStates();
    addImplFields();
    return fields;
  }

  // Todo: clean this up
  function addElement() {
    if (isJs) {
      var metas = c.meta.get().extract(elMetaNames);
      var sel:Expr = macro null;
      var tag:Expr = macro el = js.Browser.document.createElement('div');
      var className:Expr = macro null;
      var attrs:Array<Expr> = [];
      for (meta in metas) { 
        for (e in meta.params) switch (e.expr) {
          case EConst(CIdent(s)) | EConst(CString(s)): switch (s) {
            case 'sel':
              fields.push((macro class {
                @:attr @:optional var sel:String;
              }).fields[0]);
              sel = macro if (sel != null) {
                el = js.Browser.document.querySelector(sel);
              };
            case 'className' | 'class': 
              fields.push((macro class {
                @:attr @:optional var className:String;
              }).fields[0]);
              className = macro el.setAttribute('class', className);
            case 'tag':
              fields.push((macro class {
                @:attr var tag:String = 'div';
              }).fields[0]);
              tag = macro el = js.Browser.document.createElement(tag);
            default:
              fields.push((macro class {
                @:attr var $s:String;
              }).fields[0]);
              attrs.push(macro el.setAttribute($v{s}, $i{s}));
          }
          case EBinop(OpAssign, e1, e2): switch (e1.expr) {
            case EConst(CIdent(s)) | EConst(CString(s)): switch (s) {
              case 'sel': sel = macro {
                var __sel = ${e2};
                if (__sel != null) {
                  el = js.Browser.document.querySelector(__sel);
                }
              };
              case 'tag': tag = macro el = js.Browser.document.createElement(${e2});
              case 'className' | 'class': className = macro el.setAttribute('class', ${e2});
              default: attrs.push(macro el.setAttribute($v{s}, ${e2}));
            }
            default: Context.error('Invalid expression', e.pos);
          }
          default: Context.error('Invalid expression', e.pos);
        }
        c.meta.remove(meta.name);
      }
      fields = fields.concat((macro class {

        function __scout_ensureEl() {
          ${sel};
          if (el == null) {
            ${tag};
            ${className};
            $b{attrs};
          }
        }

      }).fields);
    } else {
      var metas = c.meta.get().extract(elMetaNames);
      var tag:Expr = macro var out = '<div';
      var closingTag:Expr = macro out += '</div>';
      var attrs:Array<Expr> = [];
      for (meta in metas) { 
        for (e in meta.params) switch (e.expr) {
          case EConst(CIdent(s)) | EConst(CString(s)): switch (s) {
            case 'tag':
              fields.push((macro class {
                @:attr var tag:String = 'div';
              }).fields[0]);
              tag = macro var out = '<' + tag;
              closingTag = macro out += '</' + tag + '>';
            case 'className' | 'class': 
              fields.push((macro class {
                @:attr @:optional var className:String;
              }).fields[0]);
              attrs.push(macro attrs.push('class="' + className + '"'));
            default:
              fields.push((macro class {
                @:attr var $s:String;
              }).fields[0]);
              attrs.push(macro attrs.push( $v{s} + '="' + $i{s} + '"'));
          }
          case EBinop(OpAssign, e1, e2): switch (e1.expr) {
            case EConst(CIdent(s)) | EConst(CString(s)): switch (s) {
              case 'tag': 
                tag = macro var out = '<' + ${e2};
                closingTag = macro out += '</' + ${e2} + '>'; 
              case 'className' | 'class': 
                attrs.push(macro attrs.push('class="' + ${e2} + '"'));
              default: 
                attrs.push(macro attrs.push( $v{s} + '="' + ${e2} + '"'));
            }
            default: Context.error('Invalid expression', e.pos);
          }
          default: Context.error('Only assignments are allowed here', e.pos);
        }
        c.meta.remove(meta.name);
      }
      fields = fields.concat((macro class {

        override function __scout_doRender() {
          var attrs:Array<String> = [];
          ${tag};
          $b{attrs};
          out += attrs.join(' ');
          out += '>';
          out += __scout_render();
          ${closingTag};
          content = out;
        }

      }).fields);
    }
  }

  function addImplFields() {
    var conAttrArgType = TAnonymous(constructorFields);
    var attrsType = TAnonymous(attrs);

    fields = fields.concat((macro class {
      final attrs:$attrsType;
    }).fields);

    if (isJs) {
      fields = fields.concat((macro class {

        public function new(attrs:$conAttrArgType) {
          this.attrs = cast {};
          $b{attrInitializers};
          __scout_ensureEl();
          $b{initializers};
          $b{eventBindings};
          this.delegateEvents(events);
        }

      }).fields);
    } else {
      fields = fields.concat((macro class {

        public function new(attrs:$conAttrArgType) {
          this.attrs = cast {};
          $b{attrInitializers};
          $b{initializers};
        }

      }).fields);
    }
  }

  function addAttrsAndStates() {
    var newFields:Array<Field> = [];
    fields = fields.filter(f -> switch (f.kind) {
      case FVar(t, e):
        if (f.meta.hasEntry(attrMetaNames)) {
          newFields = newFields.concat(makeFieldsForAttr(f, t, e));
          return false;
        }
        if (f.meta.hasEntry(stateMetaNames)) {
          newFields = newFields.concat(makeFieldsForState(f, t, e));
          return false;
        }
        return true;
      case FFun(func):
        if (f.meta == null) {
          f.meta = [];
        }

        if (f.meta.hasEntry([ ':js' ]) && !isJs) {
          return false;
        }

        if (f.meta.hasEntry([ ':sys' ]) && isJs) {
          return false;
        }

        if (f.name == 'render') {
          f.name = '__scout_render';
          f.access.push(haxe.macro.Access.AOverride);
        }
        
        if (f.meta.hasEntry([ ':init' ])) {
          var name = f.name;
          initializers.push(macro this.$name());
        }

        if (f.meta.hasEntry([ ':on' ])) {
          if (!isJs) {
            return false;
          }
          var name = f.name;
          var metas = f.meta.extract([ ':on' ]);
          for (meta in metas) {
            var type = meta.params[0];
            var target = meta.params[1];
            if (target == null) target = macro null;
            eventBindings.push(macro this.events.push({ 
              selector: ${target},
              action: ${type},
              method: this.$name 
            }));
          }
        }
        
        if (f.meta.hasEntry(observeMetaNames)) {
          var name = f.name;
          var metas = f.meta.extract(observeMetaNames);
          for (meta in metas) {
            if (meta.params.length == 0) {
              Context.error('An identifier is required', f.pos);
            } else if (meta.params.length > 1) {
              Context.error('Only one param is allowed here', f.pos);
            }
            initializers.push(Common.makeObserverForState('attrs', meta.params[0], macro this.$name));
          }
        }

        switch (func.expr.expr) {
          case EConst(CString(s)):
            var expr = func.expr;
            func.expr = macro return scout.Template.html(${expr});
            f.kind = FFun(func);
          default:
        }

        true;
      default: true;
    });
    fields = fields.concat(newFields);
  }

  function makeFieldsForAttr(f:Field, t:ComplexType, ?e:Expr):Array<Field> {
    var isOptional = f.meta.hasEntry([ ':optional' ]) || e != null;
    constructorFields.push(Common.makeConstructorField(f.name, t, f.pos, isOptional));
    attrs.push(Common.makeValue(f.name, t, f.pos));
    
    if (Context.unify(t.toType(), childType)) {
      var name = f.name;
      var init = e == null
        ? macro attrs.$name
        : macro attrs.$name == null ? ${e} : attrs.$name;
      initializers.push(macro {
        var __c = ${init};
        __c.setParent(this);
        this.attrs.$name = __c;
      });
    } else {
      attrInitializers.push(Common.makeValueInitializer('attrs', 'attrs', f.name, t, e));
    }
    return [
      Common.makeProp(f.name, t, f.pos, false),
      Common.makeValueGetter('attrs', f.name, t, f.pos)
    ];
  }

  function makeFieldsForState(f:Field, t:ComplexType, ?e:Expr):Array<Field> {
    var isOptional = f.meta.hasEntry([ ':optional' ]) || e != null;
    attrs.push(Common.makeState(f.name, t, f.pos));
    constructorFields.push(Common.makeConstructorField(f.name, t, f.pos, isOptional));
    attrInitializers.push(Common.makeStateInitializer('attrs', 'attrs', f.name, t, e, true));
    return [
      Common.makeProp(f.name, t, f.pos, true),
      Common.makeStateGetter('attrs', f.name, t, f.pos),
      Common.makeStateSetter('attrs', f.name, t, f.pos)
    ];
  }

}
