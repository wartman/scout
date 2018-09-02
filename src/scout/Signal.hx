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

abstract Signal<T>({ slots: Array<SignalSlot<T>> }) {

  public inline function new() {
    this = { slots: [] };
  }

  public function add(listener:T->Void, once:Bool = false):SignalSlot<T> {
    var slot = new SignalSlot(listener, cast this, once);
    this.slots.push(slot);
    return slot;
  }

  public inline function once(listener:T->Void):SignalSlot<T> {
    return add(listener, true);
  }

  public inline function remove(listener:T->Void) {
    this.slots = this.slots.filter(function (slot) return slot.listener != listener);
  }

  public function dispatch(data:T) {
    for (slot in this.slots) {
      slot.listener(data);
      if (slot.once) slot.remove();
    }
  }

}
