package scout;

import scout.Children;

using Lambda;

// This needs some work to:
//  a) Actually be efficient.
//  b) Make sure that it won't needlessly update the DOM if, for example,
//     the HTML has already been rendered server-side.
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
          if (!lastView.el.parentElement.contains(newView.el)) {
            lastView.el.parentElement.appendChild(newView.render().el);
          } else {
            newView.render();
          }
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
          if (!firstView.el.parentElement.contains(newView.el)) {
            firstView.el.parentElement.insertBefore(newView.render().el, firstView.el);
          } else {
            newView.render();
          }
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
  
  override function remove(view:T) {
    var child = children.find(function (c) return c == view);
    if (child != null) {
      child.detachFromParent();
      #if (js && !nodejs)
        if (Std.is(child, View)) { 
          var view:View = cast child;
          view.remove();
          children.remove(child);
          return;
        }
      #end
      children.remove(child);
      if (Std.is(parent, View)) {
        var view:View = cast parent;
        view.render();
      }
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
