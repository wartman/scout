package scout.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;

class ViewBuilder {

  // TODO:
  // Refactor for DRY between sys and js builders.
  public static function buildSys() {
    var fields:Array<Field> = Context.getBuildFields();
    var attrs:Array<Field> = [];
    var defaults:Array<Expr> = [];
    var initializers:Array<Expr> = [];
    var hasClassName:Bool = false;
    var hasTagName:Bool = false;
    var hasSelName:Bool = false;

    fields = fields.filter(function (f) {
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
            // simply remove all event bindings
            return false;
          }
          return true;
        default: return true;
      }
    });

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

    var attrType = TAnonymous(attrs);

    fields = fields.concat([

        {
          name: 'attrs',
          access: [ APrivate ],
          kind: FVar(attrType, null),
          pos: Context.currentPos() 
        },

        {
          name: 'new',
          access: [ APublic ],
          kind: FFun({
            ret: (macro:Void),
            args: [ { name: 'attrs', type: attrType } ],
            expr: macro {
              this.attrs = attrs;
              children = new scout.ViewCollection(this);
              $b{defaults};
              $b{initializers};
            }
          }),
          pos: Context.currentPos()
        }

      ]).concat((macro class {

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

    for (attr in attrs) switch attr.kind {
      case FVar(t, _):
        fields.push(makeProp(attr.name, t, attr.pos));
        fields.push(makeGetter(attr.name, t, attr.pos)); 
      default:
    }

    return fields;
  }

  public static function buildJs() {
    var fields:Array<Field> = Context.getBuildFields();
    var attrs:Array<Field> = [];
    var defaults:Array<Expr> = [];
    var initializers:Array<Expr> = [];
    var eventBindings:Array<Expr> = [];
    var hasClassName:Bool = false;
    var hasTagName:Bool = false;
    var hasSelName:Bool = false;

    fields = fields.filter(function (f) {
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
            var meta = f.meta.find(function (m) return m.name == ':on');
            var type = meta.params[0];
            var target = meta.params[1];
            if (target == null) target = macro null;
            eventBindings.push(macro this.events.push({ 
              selector: ${target},
              action: ${type},
              method: this.$name 
            }));
          }
          return true;
        default: return true;
      }
    });

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

    var attrType = TAnonymous(attrs);

    fields = fields.concat([

        {
          name: 'attrs',
          access: [ APrivate ],
          kind: FVar(attrType, null),
          pos: Context.currentPos() 
        },

        {
          name: 'new',
          access: [ APublic ],
          kind: FFun({
            ret: (macro:Void),
            args: [ { name: 'attrs', type: attrType } ],
            expr: macro {
              this.attrs = attrs;
              $b{defaults};
              
              if (attrs.sel != null) {
                el = js.Browser.document.querySelector(attrs.sel);
              } 

              if (el == null){
                el = js.Browser.document.createElement(attrs.tag);
                if (attrs.className != null) el.setAttribute('class', attrs.className);
              }

              children = new scout.ViewCollection(this);
              $b{initializers};
              $b{eventBindings};
              this.delegateEvents(events);
            }
          }),
          pos: Context.currentPos()
        }

      ]);

    for (attr in attrs) switch attr.kind {
      case FVar(t, _):
        fields.push(makeProp(attr.name, t, attr.pos));
        fields.push(makeGetter(attr.name, t, attr.pos)); 
      default:
    }

    return fields;
  }

  private static function makeProp(name:String, t:ComplexType, pos:Position):Field {
    return {
      name: name,
      kind: FProp('get', 'null', t, null),
      access: [ APublic ],
      pos: pos
    };
  }

  private static function makeGetter(name:String, ret:ComplexType, pos:Position):Field {
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
