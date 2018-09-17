package scout;

interface Stateful<T> extends Observable<T> {
  public var signal(default, never):Signal<T>;
  public function get():T;
  public function set(value:T):Void;    
}
