package scout;

class Property<T> implements State<T> {
  
  var value:T;
  public final signal:Signal<T> = new Signal();

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
  public final signal:Signal<T> = new Signal();

  public function new(?value:T) {
    if (value != null) {
      this.value = value;
      lastSlot = value.observe(function (_) {
        this.signal.dispatch(value);
      });
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
    lastSlot = value.observe(function (_) {
      this.signal.dispatch(value);
    });
    signal.dispatch(value);
  }

  public function get():T {
    return this.value;
  }

  public function observe(cb:(value:T)->Void) {
    return signal.add(cb);
  }

}
