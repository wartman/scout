package scout.component;

import scout.View;
import scout.Template.html;

using Lambda;

class ListView<T:View> extends View {

  @:attr var tag:String = 'ul';
  @:attr var className:String = 'list';
  @:attr var items:Array<T> = [];

  @:init 
  function initItems() {
    for (item in items) add(item);
  }
  
  public function add(item:T) {
    item.setParent(this);
    if (!items.has(item)) items.push(item);
    render();
  }

  public function delete(item:T) {
    if (items.has(item)) {
      #if js
        item.remove();
      #end
      items = items.filter(function (i) return i != item);
      render();
    }
  }

  public function render() return html('${items}');

}