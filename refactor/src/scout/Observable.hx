package scout;

import scout.Signal;

interface Observable<T> {
  public function observe(cb:(value:T)->Void):SignalSlot<T>;
}
