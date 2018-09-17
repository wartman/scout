package scout;

class ObservableValue<T> implements Observable<T> {

  private var value:T;
  public var signal(default, never):Signal<T> = new Signal();

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

  public function subscribe(cb:T->Void) {
    return signal.add(cb);
  }

}
