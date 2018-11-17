package scout.component;

import scout.View;
import scout.Child;
import scout.Renderable;
import scout.Template.html;

using Lambda;

class ListView<T:View> extends View {

  @:attr var tag:String = 'ul';
  @:attr var items:Array<T> = [];
  @:attr var className:String = 'list';
  var children:Array<Child<T>> = [];

  @:init 
  function initItems() {
    for (item in items) add(item);
  }

  public function add(item:T) {
    if (!items.has(item)) items.push(item);
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
      items = items.filter(function (i) return i != item);
      children = children.filter(function (c) return c != child);
      render();
    }
  }

  public function render() return html('${children}');

}