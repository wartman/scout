package scout.component;

import scout.View;
import scout.Child;
import scout.Template.html;

using Lambda;

class ChildrenView<T:View> extends View {

  @:attr var tag:String = 'div';
  @:attr var body:Array<T> = [];
  var children:Array<Child<T>> = [];

  @:init 
  function initBody() {
    for (item in body) add(item);
  }

  public function add(item:T) {
    if (!body.has(item)) body.push(item);
    var child = new Child(this, item);
    children.push(child);
    render();
  }

  public function delete(item:T) {
    var child = children.find(function (c) return c.get().cid == item.cid);
    if (child != null) {
      #if js
        child.remove();
      #end
      body = body.filter(function (i) return i != item);
      children = children.filter(function (c) return c != child);
      render();
    }
  }

  public function render() return html('${children}');

}
