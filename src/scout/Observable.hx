package scout;

interface Observable<T> extends Subscriber<T> {
  public var signal(default, never):Signal<T>;
  public function get():T;
  public function set(value:T):Void;    
}
