package scout;

interface StateObject<T> extends Observable<T> {
  public function get():T;
  public function set(value:T):Void; 
}

@:forward
abstract State<T>(StateObject<T>) to Observable<T> {

  @:from public static function ofObservable<T:Observable<M>, M>(value:T):State<T> {
    return cast new StateOfObservable(value);
  }

  @:from public static function ofDynamic<T:Dynamic>(value:T):State<T> {
    return new State(value);
  }

  public static function ofChild<T:Child>(parent:View, child:T):State<T> {
    return cast new StateOfChild(parent, child);
  }

  public function new(?value:T) {
    this = new SimpleState(value);
  }

}

private class SimpleState<T> implements StateObject<T> {

  var value:T;
  final signal:Signal<T> = new Signal();

  public function new(?value:T) {
    this.value = value;
  }

  public function set(value:T) {
    if (this.value == value) {
      return;
    }
    this.value = value;
    signal.dispatch(this.value);
  }

  public function get():T {
    return this.value;
  }

  public function observe(cb:(value:T)->Void) {
    return signal.add(cb);
  }

}

private class StateOfObservable<T:Observable<M>, M> implements StateObject<T> {

  var value:T;
  var lastSlot:Signal.SignalSlot<M>;
  final signal:Signal<T> = new Signal();

  public function new(?value:T) {
    if (value != null) {
      this.value = value;
      lastSlot = value.observe(_ -> signal.dispatch(value));
    }
  }

  public function set(value:T) {
    if (this.value == value) {
      return;
    }
    this.value = value;
    if (lastSlot != null) {
      lastSlot.remove();
    }
    if (value != null) {
      lastSlot = value.observe(_ -> signal.dispatch(value));
    }
    signal.dispatch(value);
  }

  public function get():T {
    return value;
  }

  public function observe(cb:(value:T)->Void) {
    return signal.add(cb);
  }

}

private class StateOfChild<T:Child> implements StateObject<T> {

  var parent:View;
  var target:T;
  final signal:Signal<T> = new Signal();

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

  public function observe(cb:T->Void) {
    return signal.add(cb);
  }

}
