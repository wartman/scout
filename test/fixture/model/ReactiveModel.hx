package fixture.model;

import scout.Model;

class ReactiveModel implements Model {
  
  @:prop @:autoIncrement var id:Int;
  @:prop var foo:String;
  public var changed:Int = 0;

  @:observe(signals.foo)
  public function whenFooChanges(foo:String) {
    changed++;
  }

}
