package scout;

import scout.Template;

using Reflect;
using Lambda;

class Element implements Renderable {

  private static var tagNames:Array<String> = [
    'a', 'abbr', 'address', 'area', 'article', 'aside', 'audio', 'b', 'base',
    'bdi', 'bdo', 'blockquote', 'body', 'br', 'button', 'canvas', 'caption',
    'cite', 'code', 'col', 'colgroup', 'dd', 'del', 'dfn', 'dir', 'div', 'dl',
    'dt', 'em', 'embed', 'fieldset', 'figcaption', 'figure', 'footer', 'form',
    'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'header', 'hgroup', 'hr', 'html',
    'i', 'iframe', 'img', 'input', 'ins', 'kbd', 'keygen', 'label', 'legend',
    'li', 'link', 'main', 'map', 'mark', 'menu', 'meta', 'nav', 'noscript',
    'object', 'ol', 'optgroup', 'option', 'p', 'param', 'pre', 'q', 'rp', 'rt',
    'ruby', 's', 'samp', 'script', 'section', 'select', 'small', 'source', 'span',
    'strong', 'style', 'sub', 'sup', 'table', 'tbody', 'td', 'textarea', 'tfoot',
    'th', 'thead', 'title', 'tr', 'u', 'ul', 'video'
  ];

  private static var voidTags:Array<String> = [
    'area', 'base', 'br', 'col', 'command', 'embed', 'hr', 
    'img', 'input', 'keygen', 'link', 'meta', 'param', 'source', 
    'track', 'wbr'
  ];

  @:isVar private var tag(default, set):String;
  public function set_tag(tag:String) {
    if (tagNames.indexOf(tag) <= 0) {
      throw "Invalid tag name: ${tag}";
    }
    this.tag = tag;
    return tag;
  }
  private var classes:Array<String> = [];
  private var attrs:Map<String, Dynamic> = new Map();
  private var children:Array<Dynamic> = [];

  public function new(tag:String, attrs:Dynamic, ?children:Array<Dynamic>) {
    this.tag = tag;
    this.children = children;
    for (field in attrs.fields()) {
      if (field == 'className') {
        addClass(attrs.field(field));
      } else {
        addAttribute(field, attrs.field(field));
      }
    }
  }

  public function addClass(cls:String) {
    classes.push(cls);
  }

  public function removeClass(cls:String) {
    classes = classes.filter(function (c) return c != cls);
  }

  public function addAttribute(name:String, value:String) {
    if (name == 'class') {
      addClass(value);
      return;
    }
    attrs.set(name, value);
  }

  public function removeAttribute(name:String) {
    attrs.remove(name);
  }

  public function render() {
    if (children.length == 0 && voidTags.indexOf(tag) >= 0) {
      return Template.html('<${ @:safe tag }${ @:safe renderAttrs() }/>');
    }
    return Template.html('<${ @:safe tag }${ @:safe renderAttrs() }>${children}</${ @:safe tag }>');
  }

  private function renderAttrs() {
    var entries = [ for (key in attrs.keys()) {
      var value = attrs.get(key);

      if (Std.is(value, Bool)) {
        cast(value, Bool) == true ? key : null;
      } else {
        '${key}="${StringTools.htmlEscape(Std.string(value))}"';
      }

    } ].filter(function (entry) return entry != null);
    if (classes.length > 0) {
      entries.unshift('class="${classes.join(' ')}"');
    }
    return entries.length > 0 ? ' ' + entries.join(' ') : '';
  }

  public function toRenderResult():RenderResult {
    return render();
  }

}
