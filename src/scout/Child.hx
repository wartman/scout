package scout;

class Child<T:Mountable> implements Stateful<T> {

  var parent:View;
  var target:T;
  public var signal(default, never):Signal<T> = new Signal();

  public function new(parent:View, ?target:T) {
    this.parent = parent;
    if (target != null) {
      this.target = target;
      target.setParent(this.parent);
    }
  }

  public function set(target:T) {
    if (this.target == target) {
      return;
    }
    if (this.target != null) {
      this.target.detachFromParent();
    }
    this.target = target;
    this.target.setParent(parent);
    signal.dispatch(this.target);
  }

  public function get():T {
    return this.target;
  }

  public function subscribe(cb:T->Void) {
    return signal.add(cb);
  }

}
