package fixture.model;

import scout.Model;

class ReactiveModel implements Model {

  @:prop var foo:String;
  public var changed:Int = 0;

  @:observe(props.foo)
  function whenFooChanges(_) {
    changed++;
  }

}
