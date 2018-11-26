package scout;

interface State<T> extends Observable<T> {
  public function get():T;
  public function set(value:T):Void; 
}
