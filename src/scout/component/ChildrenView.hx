package scout.component;

import scout.View;
import scout.Template.html;

using Lambda;

typedef ChildrenViewOptions = {
  ?silent:Bool
};

class ChildrenView<T:View> extends View {

  @:attr var tag:String = 'div';
  @:attr var body:Array<T> = [];

  @:init 
  function initBody() {
    for (child in body) add(child);
  }

  public function add(child:T, ?options:ChildrenViewOptions) {
    if (options == null) options = {};
    if (options.silent == null) options.silent = false;
    child.setParent(this);
    if (!body.has(child)) body.push(child);
    if (!options.silent) render();
  }

  public function delete(child:T, ?options:ChildrenViewOptions) {
    if (options == null) options = {};
    if (options.silent == null) options.silent = false;
    if (body.has(child)) {
      #if js
        child.remove();
      #end
      body = body.filter(function (i) return i != child);
      if (!options.silent) render();
    }
  }

  public function render() return html('${body}');

}
