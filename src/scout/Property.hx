package scout;

class Property<T> implements State<T> {
  
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

class PropertyOfObservable<T:Observable<M>, M> implements State<T> {

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

class PropertyOfChild<T:Child> implements State<T> {

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
