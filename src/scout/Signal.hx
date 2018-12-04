package scout;

typedef SignalListener<T> = (value:T)->Void;

class SignalSlot<T> {

  public final listener:SignalListener<T>;
  public final once:Bool;
  final signal:Signal<T>;

  public function new(
    listener:SignalListener<T>,
    signal:Signal<T>,
    once:Bool = false
  ) {
    this.listener = listener;
    this.signal = signal;
    this.once = once;
  }

  public inline function remove() {
    this.signal.remove(listener);
  }

}

class Signal<T> implements Observable<T> {

  var slots:Array<SignalSlot<T>> = [];

  public function new() {}

  public function add(
    listener:SignalListener<T>,
    once:Bool = false
  ):SignalSlot<T> {
    var slot = new SignalSlot(listener, this, once);
    slots.push(slot);
    return slot;
  }

  public inline function observe(listener:SignalListener<T>)
    return add(listener, false);

  public inline function once(listener:SignalListener<T>)
    return add(listener, true);

  public function remove(listener:SignalListener<T>) {
    slots = slots.filter(slot -> slot.listener != listener);
  }

  public function dispatch(payload:T) {
    for (slot in slots) {
      slot.listener(payload);
      if (slot.once) slot.remove();
    }
  }

}
