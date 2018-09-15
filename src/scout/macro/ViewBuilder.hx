package scout.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
using scout.macro.MacroTools;

class ViewBuilder {

  public static function buildJs() {
    return new ViewBuilder(Context.getBuildFields(), true).export();
  }

  public static function buildSys() {
    return new ViewBuilder(Context.getBuildFields(), false).export();
  }

  private var fields:Array<Field>;
  private var attrs:Array<Field> = [];
  private var renderableAttrs:Map<String, String> = new Map();
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
          var metaNames = [ ':attr', ':attribute' ];
          if (f.meta.hasMeta(metaNames)) {

            var metas = f.meta.extractMeta(metaNames);
            if (metas.length > 1) {
              Context.error('A var may only have one :attr or :attribute metadata entry', f.pos);
            }
            var options = extractAttrOptions(metas[0]);

            if (f.name == 'className') {
              hasClassName = true;
              options.push(AttrRender('class'));
            }
            if (f.name == 'tag') hasTagName = true; 
            if (f.name == 'sel') hasSelName = true;

            attrs.push({
              name: f.name,
              kind: FVar(t, null),
              access: [ APublic ],
              meta: f.meta.hasMeta([ ':optional' ]) || e != null ? [ 
                { name: ':optional', pos: f.pos } 
              ] : [],
              pos: f.pos
            });
            
            for (option in options) switch (option) {
              case AttrRender(s):
                if (f.name == 'className' && s == null) s = 'class';
                if (s == null) s = f.name;
                renderableAttrs.set(f.name, s);
              default:
            }

            if (e != null) {
              var name = f.name;
              defaults.push( macro if (this.attrs.$name == null) this.attrs.$name = ${e} );
            }

            return false;
          }
          return true;
        case FFun(func):
          var name = f.name;

          if (f.meta.hasMeta([ ':js' ])) {
            if (!isJs) {
              return false;
            }
          }

          if (f.meta.hasMeta([ ':sys' ])) {
            if (isJs) {
              return false;
            }
          }

          if (name == 'template') {
            f.access.push(haxe.macro.Access.AOverride);
          }

          if (f.meta.hasMeta([ ':init' ])) {
            initializers.push(macro this.$name() );
          }

          if (f.meta.hasMeta([ ':on' ])) {
            if (!isJs) {
              return false;
            }
            
            var metas = f.meta.extractMeta([ ':on' ]);
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
          
          if (f.meta.hasMeta([ ':observe' ])) {
            var metas = f.meta.extractMeta([ ':observe' ]);
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
          
          ensureElement();

          this.children = new scout.ViewCollection(this, children);

          $b{initializers};
          $b{eventBindings};
          this.delegateEvents(events);
        }

        private function ensureElement() {
          if (attrs.sel != null) {
            el = js.Browser.document.querySelector(sel);
          }
          if (el == null) {
            el = js.Browser.document.createElement(tag);
            $b{ [ for (attr in renderableAttrs.keys()) {
              var name = { expr:EConst(CString(renderableAttrs.get(attr))), pos: Context.currentPos() };
              macro el.setAttribute(${name}, $i{attr});
            } ] }
          }
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

      override private function generateHtml() {
        var options:Dynamic = {}
        $b{ [ for (attr in renderableAttrs.keys()) {
          var name = { expr:EConst(CString(renderableAttrs.get(attr))), pos: Context.currentPos() };
          macro Reflect.setField(options, ${name}, $i{attr});
        } ] }
        return new scout.Element(attrs.tag, options, [
          scout.Template.safe(template())
        ]).toRenderResult();
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

  private function extractAttrOptions(meta:MetadataEntry):Array<AttrOptions> {
    return [ for (e in meta.params) {
      switch (e.expr) {
        case EConst(CIdent(s)):
          switch (s) {
            case 'tag': AttrRender(null);
            default: Context.error('${s} is not a valid parameter for ${meta.name}', e.pos);
          }
        case EBinop(
          OpAssign, 
          { expr: EConst(CIdent(s)), pos:_ },
          { expr: EConst(CString(alias)), pos:_ }
        ):
          switch (s) {
            case 'tag': AttrRender(alias);
            default: Context.error('${s} is not a valid parameter for ${meta.name}', e.pos);
          }
        default:
          Context.error('Invalid expression for ${meta.name}', e.pos);
      }
    } ].filter(function (item) return item != null);
  }

}

private enum AttrOptions {
  AttrRender(?alias:String);
}
