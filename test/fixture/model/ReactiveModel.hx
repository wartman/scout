package fixture.model;

import scout.Model;

class ReactiveModel implements Model {
  
  @:prop(auto) var id:Int;
  @:prop var foo:String;
  public var changed:Int = 0;

  @:observe(states.foo)
  public function whenFooChanges(foo:String) {
    changed++;
  }

}
