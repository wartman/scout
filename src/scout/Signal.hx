package scout;

@:forward
abstract SignalSlot<T>({ listener:(value:T)->Void, signal:Signal<T>, once:Bool }) {

  public inline function new(listener:(value:T)->Void, signal:Signal<T>, once:Bool = false) {
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

  public static inline function observe<T>(obs:Observable<T>, cb:(value:T)->Void) {
    obs.observe(cb);
  }

  @:to public function toObservable():Observable<T> {
    return cast {
      observe: (cb:(value:T)->Void) -> add(cb) 
    };
  }

  public inline function new() {
    this = { slots: [] };
  }

  public function add(listener:(value:T)->Void, once:Bool = false):SignalSlot<T> {
    var slot = new SignalSlot(listener, cast this, once);
    this.slots.push(slot);
    return slot;
  }

  public inline function once(listener:(value:T)->Void):SignalSlot<T> {
    return add(listener, true);
  }

  public inline function remove(listener:(value:T)->Void) {
    this.slots = this.slots.filter(slot -> slot.listener != listener);
  }

  public function dispatch(data:T) {
    for (slot in this.slots) {
      slot.listener(data);
      if (slot.once) slot.remove();
    }
  }

}
