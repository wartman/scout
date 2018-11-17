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

  var fields:Array<Field>;
  var attrs:Array<Field> = [];
  var states:Array<Field> = [];
  var renderableAttrs:Map<String, String> = new Map();
  var attrInitializers:Array<Expr> = [];
  var initializers:Array<Expr> = [];
  var eventBindings:Array<Expr> = [];
  var isJs:Bool;
  var hasClassName:Bool = false;
  var hasTagName:Bool = false;
  var hasSelName:Bool = false;

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

  function filterFieldsAndExtractAttrs():Array<Field> {
    return fields.filter(function (f) {
      switch (f.kind) {
        case FVar(t, e):
          var metaNames = [ ':attr', ':attribute' ];
          if (f.meta.hasMeta(metaNames)) {

            var name = f.name;
            var metas = f.meta.extractMeta(metaNames);
            if (metas.length > 1) {
              Context.error('A var may only have one :attr or :attribute metadata entry', f.pos);
            }
            var options = extractAttrOptions(metas[0]);
            var isOptional:Bool = false;

            if (f.name == 'className') {
              hasClassName = true;
              options.push(AttrRender('class'));
            }
            if (f.name == 'tag') hasTagName = true; 
            if (f.name == 'sel') hasSelName = true;

            for (option in options) switch (option) {
              case AttrRender(s):
                if (f.name == 'className' && s == null) s = 'class';
                if (s == null) s = f.name;
                renderableAttrs.set(f.name, s);
              case AttrObserve(target):
                if (target == null) target = 'render';
                initializers.push(macro this.states.$name.subscribe(function (_) $i{target}()));
              case AttrOptional:
                isOptional = true;
              default:
            }

            addAttr(f.name, t, e, f.pos, isOptional, options);
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

          if (name == 'render') {
            f.name = '__scout_render';
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
              initializers.push(macro @:pos(f.pos) scout.Signal.observe(${expr}, this.$name));
            }
          }

          return true;
        default: return true;
      }
    });
  }

  private function generateAttrType() {
    if (!hasClassName) {
      addAttr('className', macro:String, null, Context.currentPos(), true, [ AttrRender('class') ]);
    }
    if (!hasTagName) {
      addAttr('tag', macro:String, macro 'div', Context.currentPos(), true, []);
    }
    if (!hasSelName) {
      addAttr('sel', macro:String, null, Context.currentPos(), true, []);
    }
    return TAnonymous(attrs);
  }

  private function generateConstructor(fields:Array<Field>, attrType:ComplexType):Array<Field> {
    fields.push({
      name: 'states',
      access: [ APrivate ],
      kind: FVar(TAnonymous(states), null),
      pos: Context.currentPos()
    });

    // var attrBuilders = [ for (attr in attrs) {
    //   var key = attr.name;
    //   macro if (attrs.$key != null) this.$key = attrs.$key;
    // } ];

    if (isJs) {
      return fields.concat((macro class {

        public function new(attrs:$attrType) {
          this.states = cast {};
          $b{attrInitializers};
          ensureElement();
          $b{initializers};
          $b{eventBindings};
          this.delegateEvents(events);
        }

        private function ensureElement() {
          if (sel != null) {
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

      public function new(attrs:$attrType) {
        this.states = cast {};
        $b{attrInitializers};
        $b{initializers};
      }

      override function generateHtml() {
        var options:Dynamic = {}
        $b{ [ for (attr in renderableAttrs.keys()) {
          var name = { expr:EConst(CString(renderableAttrs.get(attr))), pos: Context.currentPos() };
          macro Reflect.setField(options, ${name}, $i{attr});
        } ] }
        return new scout.Element(tag, options, [
          scout.Template.safe(__scout_render())
        ]).toRenderResult();
      }

    }).fields);
  }

  function generateGettersAndSetters(fields:Array<Field>) {
    for (attr in attrs) switch attr.kind {
      case FVar(t, _):
        fields.push(makeProp(attr.name, t, attr.pos));
        fields.push(makeGetter(attr.name, t, attr.pos));
        fields.push(makeSetter(attr.name, t, attr.pos)); 
      default:
    }
    return fields;
  }

  private function makeProp(name:String, t:ComplexType, pos:Position):Field {
    return {
      name: name,
      kind: FProp('get', 'set', t, null),
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
        expr: macro return this.states.$name.get()
      }),
      access: [ AInline, APublic ],
      pos: pos
    };
  }

  private function makeSetter(name:String, ret:ComplexType, pos:Position):Field {
    return {
      name: 'set_${name}',
      kind: FFun({
        ret: ret,
        args: [ { name:'value', type:ret } ],
        expr: macro {
          this.states.$name.set(value);
          return value;
        }
      }),
      access: [ AInline, APublic ],
      pos: pos
    };
  }

  private function addAttr(name:String, t:ComplexType, ?e:Expr, pos:Position, isOptional:Bool = false, options:Array<AttrOptions>) {
    attrs.push({
      name: name,
      kind: FVar(t, null),
      access: [ APublic ],
      meta: isOptional || e != null ? [ { name: ':optional', pos: pos } ] : [],
      pos: pos
    });

    states.push({
      name: name,
      kind: FVar(macro:scout.Stateful<$t>, null),
      access: [ APublic ],
      meta: [],
      pos: pos
    });

    var init = e != null ? macro attrs.$name != null ? attrs.$name : ${e} : macro attrs.$name;
    for (option in options) switch (option) {
      case AttrChild:
        attrInitializers.push(macro this.states.$name = new scout.Child(this, ${init}));
        return;
      default:
    }
    attrInitializers.push(macro this.states.$name = new scout.State(${init}));
  }

  private function extractAttrOptions(meta:MetadataEntry):Array<AttrOptions> {
    return [ for (e in meta.params) {
      switch (e.expr) {
        case EConst(CIdent(s)):
          switch (s) {
            case 'tag': AttrRender(null);
            case 'observe': AttrObserve(null);
            case 'optional': AttrOptional;
            case 'child': AttrChild;
            default: Context.error('${s} is not a valid parameter for ${meta.name}', e.pos);
          }
        case EBinop(
          OpAssign, 
          { expr: EConst(CIdent(s)), pos:_ },
          { expr: EConst(CString(target)), pos:_ }
        ):
          switch (s) {
            case 'tag': AttrRender(target);
            case 'observe': AttrObserve(target);
            default: Context.error('${s} is not a valid parameter for ${meta.name}', e.pos);
          }
        case EBinop(
          OpAssign, 
          { expr: EConst(CIdent('observe')), pos:_ },
          { expr: EConst(CIdent(target)), pos:_ }
        ): AttrObserve(target);
        default:
          Context.error('Invalid expression for ${meta.name}', e.pos);
      }
    } ].filter(function (item) return item != null);
  }

}

private enum AttrOptions {
  AttrOptional;
  AttrChild;
  AttrRender(?alias:String);
  AttrObserve(?target:String);
}
