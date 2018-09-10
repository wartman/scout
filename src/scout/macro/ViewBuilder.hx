package scout.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;

class ViewBuilder {

  public static function buildJs() {
    return new ViewBuilder(Context.getBuildFields(), true).export();
  }

  public static function buildSys() {
    return new ViewBuilder(Context.getBuildFields(), false).export();
  }

  private var fields:Array<Field>;
  private var attrs:Array<Field> = [];
  private var defaults:Array<Expr> = [];
  private var initializers:Array<Expr> = [];
  private var eventBindings:Array<Expr> = [];
  private var isJs:Bool;
  private var hasClassName:Bool = false;
  private var hasTagName:Bool = false;
  private var hasSelName:Bool = false;

  public function new(fields:Array<Field>, isJs:Bool) {
    this.fields = fields;
    this.isJs = isJs;
  }

  public function export():Array<Field> {
    var fields = filterFieldsAndExtractAttrs();
    var attrType = generateAttrType();
    fields = generateConstructor(fields, attrType);
    fields = generateGettersAndSetters(fields);
    return fields;
  }

  private function filterFieldsAndExtractAttrs():Array<Field> {
    return fields.filter(function (f) {
      switch (f.kind) {
        case FVar(t, e):
          if (f.meta.exists(function (m) return m.name == ':attr' || m.name == ':attribute')) {
            if (f.name == 'className') hasClassName = true;
            if (f.name == 'tag') hasTagName = true; 
            if (f.name == 'sel') hasSelName = true;

            attrs.push({
              name: f.name,
              kind: FVar(t, null),
              access: [ APublic ],
              meta: f.meta.exists(function (entry) return entry.name == ':optional') || e != null ? [ 
                { name: ':optional', pos: f.pos } 
              ] : [],
              pos: f.pos
            });
            
            if (e != null) {
              var name = f.name;
              defaults.push( macro if (this.attrs.$name == null) this.attrs.$name = ${e} );
            }

            return false;
          }
          return true;
        case FFun(func):
          var name = f.name;

          if (name == 'template') {
            f.access.push(haxe.macro.Access.AOverride);
          }

          if (f.meta.exists(function (m) return m.name == ':init')) {
            initializers.push(macro this.$name() );
          }

          if (f.meta.exists(function (m) return m.name == ':on')) {
            if (!isJs) {
              return false;
            }
            
            var metas = f.meta.filter(function (m) return m.name == ':on');
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
          
          if (f.meta.exists(function (m) return m.name == ':onSignal')) {
            var metas = f.meta.filter(function (m) return m.name == ':onSignal');
            for (meta in metas) {
              var expr = meta.params[0];
              f.meta.remove(meta);
              initializers.push(macro @:pos(f.pos) ${expr}.add(this.$name));
            }
          }

          return true;
        default: return true;
      }
    });
  }

  private function generateAttrType() {
    if (!hasClassName) {
      attrs.push({
        name: 'className',
        kind: FVar(macro:String),
        access: [ APublic ],
        meta: [ { name: ':optional', pos: Context.currentPos() } ],
        pos: Context.currentPos()
      });
    }

    if (!hasTagName) {
      attrs.push({
        name: 'tag',
        kind: FVar(macro:String),
        access: [ APublic ],
        meta: [ { name: ':optional', pos: Context.currentPos() } ],
        pos: Context.currentPos()
      });
      defaults.push( macro this.attrs.tag = 'div' );
    }

    if (!hasSelName) {
      attrs.push({
        name: 'sel',
        kind: FVar(macro:String),
        access: [ APublic ],
        meta: [ { name: ':optional', pos: Context.currentPos() } ],
        pos: Context.currentPos()
      });
    }

    return TAnonymous(attrs);
  }

  private function generateConstructor(fields:Array<Field>, attrType:ComplexType):Array<Field> {
    fields.push({
      name: 'attrs',
      access: [ APrivate ],
      kind: FVar(attrType, null),
      pos: Context.currentPos() 
    });

    if (isJs) {
      return fields.concat((macro class {

        public function new(attrs:$attrType, ?children:Array<scout.View>) {
          this.attrs = attrs;
          $b{defaults};
          
          if (attrs.sel != null) {
            el = js.Browser.document.querySelector(attrs.sel);
          } 

          if (el == null){
            el = js.Browser.document.createElement(attrs.tag);
            if (attrs.className != null) el.setAttribute('class', attrs.className);
          }

          this.children = new scout.ViewCollection(this, children);

          $b{initializers};
          $b{eventBindings};
          this.delegateEvents(events);
        }

      }).fields);
    }

    return fields.concat((macro class {

      public function new(attrs:$attrType, ?children:Array<scout.View>) {
        this.attrs = attrs;
        this.children = new scout.ViewCollection(this, children);
        $b{defaults};
        $b{initializers};
      }

      // todo: this is messy.

      override private function generateHtml() {
        return '<' + attrs.tag + generateAttrs() + '>' 
          + template() + '</' + attrs.tag + '>';
      }

      private function generateAttrs() {
        var out = [];
        if (attrs.className != null) {
          out.push('class="' + StringTools.htmlEscape(attrs.className) + '"');
        }
        if (out.length > 0) {
          return ' ' + out.join(' ');
        }
        return '';
      }

    }).fields);
  }

  private function generateGettersAndSetters(fields:Array<Field>) {
    for (attr in attrs) switch attr.kind {
      case FVar(t, _):
        fields.push(makeProp(attr.name, t, attr.pos));
        fields.push(makeGetter(attr.name, t, attr.pos)); 
      default:
    }
    return fields;
  }

  private function makeProp(name:String, t:ComplexType, pos:Position):Field {
    return {
      name: name,
      kind: FProp('get', 'null', t, null),
      access: [ APublic ],
      pos: pos
    };
  }

  private function makeGetter(name:String, ret:ComplexType, pos:Position):Field {
    return {
      name: 'get_${name}',
      kind: FFun({
        ret: ret,
        args: [],
        expr: macro return this.attrs.$name
      }),
      access: [ AInline, APublic ],
      pos: pos
    };
  }

}
