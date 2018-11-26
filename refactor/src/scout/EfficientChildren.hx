package scout;

import scout.Children;

class EfficientChildrenImpl<T:Child> extends ChildrenImpl<T> {

  override function add(view:T) {
    view.setParent(parent);
    #if (js && !nodejs)
      if (children.length > 0) {
        var last = children[children.length - 1];
        children.push(view);
        if (Std.is(last, View) && Std.is(view, View)) {
          var lastView:View = cast last;
          var newView:View = cast view;
          Dom.addAfter(lastView.el, newView.render().el);
          return;
        }
      }
    #end
    children.push(view);
    if (Std.is(parent, View)) {
      var view:View = cast parent;
      view.render();
    }
  }

  override function prepend(view:T) {
    view.setParent(parent);
    #if (js && !nodejs)
      if (children.length > 0) {
        var first = children[0];
        children.unshift(view);
        if (Std.is(first, View) && Std.is(view, View)) {
          var firstView:View = cast first;
          var newView:View = cast view;
          Dom.addBefore(firstView.el, newView.render().el);
          return;
        }
      }
    #end
    children.unshift(view);
    if (Std.is(parent, View)) {
      var view:View = cast parent;
      view.render();
    }
  }

}

@:forward
abstract EfficientChildren<T:Child>(EfficientChildrenImpl<T>) to Child to Renderable {

  public inline function new(?children:Array<T>) { 
    this = new EfficientChildrenImpl(children);
  }

  @:from public static inline function ofArray<T:Child>(children:Array<T>) 
    return new EfficientChildren(children);

}
