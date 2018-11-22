package scout;

using Lambda;

private class ChildrenImpl<T:View> implements Mountable implements Renderable {

  var parent:View;
  var children:Array<T> = [];

  public function new(?children:Array<T>) {
    if (children != null) {
      this.children = children;
    }
  }

  public function setParent(parent:View) {
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
    parent.render();
  }

  public function prepend(view:T) {
    view.setParent(parent);
    children.unshift(view);
    parent.render();
  }

  public function remove(view:T) {
    var child = children.find(function (c) return c == view);
    if (child != null) {
      child.detachFromParent();
      #if js
        child.remove();
      #end
      children.remove(child);
      parent.render();
    }
  }

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

  public function toRenderResult() return Template.html('${children}');

}

@:forward
abstract Children<T:View>(ChildrenImpl<T>) to Mountable to Renderable {

  public inline function new(?children:Array<T>) { 
    this = new ChildrenImpl(children);
  }

  @:from public static inline function ofArray<T:View>(children:Array<T>) return new Children(children);

}
