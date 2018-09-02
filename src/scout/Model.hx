package scout;

@:autoBuild(scout.macro.ModelBuilder.build())
interface Model {
  public var id(get, set):Int;
  public function subscribe(listener:Model->Void):Signal.SignalSlot<Model>;
}
