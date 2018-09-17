package scout;

import scout.Signal;

interface Subscriber<T> {
  public function subscribe(cb:T->Void):SignalSlot<T>;
}
