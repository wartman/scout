package scout;

class ObservableSubscriber<T:Subscriber<M>, M> implements Observable<T> {

  private var value:T;
  public var signal(default, never):Signal<T> = new Signal();
  private var lastSlot:Signal.SignalSlot<M>;

  public function new(?value:T) {
    if (value != null) {
      this.value = value;
      lastSlot = value.subscribe(function (_) {
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
    lastSlot = value.subscribe(function (_) {
      this.signal.dispatch(value);
    });
    signal.dispatch(value);
  }

  public function get():T {
    return this.value;
  }

  public function subscribe(cb:T->Void) {
    return signal.add(cb);
  }

}
