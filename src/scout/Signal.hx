package scout;

@:forward
abstract SignalSlot<T>({ listener:T->Void, signal:Signal<T>, once:Bool }) {

  public inline function new(listener:T->Void, signal:Signal<T>, once:Bool = false) {
    this = {
      listener: listener,
      signal: signal,
      once: once
    };
  }

  public inline function remove() {
    this.signal.remove(this.listener);
  }

}

abstract Signal<T>(Array<SignalSlot<T>>) {

  public inline function new() {
    this = [];
  }

  public function add(listener:T->Void, once:Bool = false):SignalSlot<T> {
    var slot = new SignalSlot(listener, cast this, once);
    this.push(slot);
    return slot;
  }

  public inline function once(listener:T->Void):SignalSlot<T> {
    return add(listener, true);
  }

  public inline function remove(listener:T->Void) {
    this = this.filter(function (slot) return slot.listener != listener);
  }

  public function dispatch(data:T) {
    for (slot in this) {
      slot.listener(data);
      if (slot.once) slot.remove();
    }
  }

}
