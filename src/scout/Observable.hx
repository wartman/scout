package scout;

import scout.Signal;

interface Observable<T> {
  public function subscribe(cb:T->Void):SignalSlot<T>;
}
