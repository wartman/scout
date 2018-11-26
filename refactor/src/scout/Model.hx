package scout;

@:autoBuild(scout.macro.ModelBuilder.build())
interface Model extends Observable<Model> {
  public var id(get, set):Int;
}
