package scout.component;

import scout.View;
import scout.Template.html;

using Lambda;

class ChildrenView<T:View> extends View {

  @:attr var tag:String = 'div';
  @:attr var body:Array<T> = [];

  @:init 
  function initBody() {
    for (child in body) add(child);
  }

  public function add(child:T) {
    child.setParent(this);
    if (!body.has(child)) body.push(child);
    render();
  }

  public function delete(child:T) {
    if (body.has(child)) {
      #if js
        child.remove();
      #end
      body = body.filter(function (i) return i != child);
      render();
    }
  }

  public function render() return html('${body}');

}
