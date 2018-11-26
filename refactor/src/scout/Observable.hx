package scout;

import scout.Signal;

interface Observable<T> {
  public function observe(cb:T->Void):SignalSlot<T>;
}
