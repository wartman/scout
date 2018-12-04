package fixture.model;

import scout.Model;

class WithInitModel implements Model {

  public var foo:String;

  @:init
  function testInit() {
    foo = 'foo';
  }

}