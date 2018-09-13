package fixture.model;

import scout.Model;

class OptionalModel implements Model {
  @:prop var id:Int;
  @:prop var name:String;
  @:prop(optional) var value:String;
}
