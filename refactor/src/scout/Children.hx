package scout;

using Lambda;

private class ChildrenImpl<T:Child> implements Renderable implements Child {

  var parent:Child;
  var children:Array<T> = [];

  public function new(?children:Array<T>) {
    if (children != null) {
      this.children = children;
    }
  }

  public function setParent(parent:Child) {
    this.parent = parent;
    for (view in children) {
      view.setParent(this.parent);
    }
  }

  public function detachFromParent() {
    for (view in children) {
      view.detachFromParent();
    }
  }

  public function add(view:T) {
    view.setParent(parent);
    children.push(view);
    if (Std.is(parent, View)) {
      var view:View = cast parent;
      view.render();
    }
  }

  public function prepend(view:T) {
    view.setParent(parent);
    children.unshift(view);
    if (Std.is(parent, View)) {
      var view:View = cast parent;
      view.render();
    }
  }

  public function remove(view:T) {
    var child = children.find(function (c) return c == view);
    if (child != null) {
      child.detachFromParent();
      #if js
        if (Std.is(child, View)) { 
          var view:View = cast child;
          view.remove();
        }
      #end
      children.remove(child);
      if (Std.is(parent, View)) {
        var view:View = cast parent;
        view.render();
      }
    }
  }

  #if js

    public function attach() {
      // void
    }

    public function detach() {
      // void
    }

  #end

  public function getAt(index:Int) {
    return children[index];
  }

  public function has(view:T) {
    return children.has(view);
  }

  public function find(cb:T->Bool):Null<T> {
    return children.find(cb);
  }

  public function map<R>(cb:T->R):Array<R> {
    return children.map(cb);
  }

  public function iterator():Array<T> {
    return children;
  }

  public function getAttachmentPoint() return toRenderResult();

  public function toRenderResult() return Template.html('${children}');

}

@:forward
abstract Children<T:Child>(ChildrenImpl<T>) to Child to Renderable {

  public inline function new(?children:Array<T>) { 
    this = new ChildrenImpl(children);
  }

  @:from public static inline function ofArray<T:Child>(children:Array<T>) return new Children(children);

}
