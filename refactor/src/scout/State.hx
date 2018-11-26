package scout;

interface State<T> extends Observable<T> {
  public final signal:Signal<T> = new Signal(); // silly error
  public function get():T;
  public function set(value:T):Void; 
}
