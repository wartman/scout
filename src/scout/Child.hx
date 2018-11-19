package scout;

class Child<T:View> implements Stateful<T> {

  var parent:View;
  var view:T;
  public var signal(default, never):Signal<T> = new Signal();

  public function new(parent:View, ?view:T) {
    this.parent = parent;
    if (view != null) {
      view.setParent(this.parent);
      this.view = view;
    }
  }

  public function set(view:T) {
    if (this.view == view) {
      return;
    }
    if (this.view != null) {
      this.view.detachFromParent();
    }
    this.view = view;
    this.view.setParent(parent);
    signal.dispatch(this.view);
  }

  public function get():T {
    return this.view;
  }

  public function subscribe(cb:T->Void) {
    return signal.add(cb);
  }

}
