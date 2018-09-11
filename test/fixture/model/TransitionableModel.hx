package fixture.model;

import scout.Model;

class TransitionableModel implements Model {
  
  @:prop var id:Int;
  @:prop var name:String;
  @:prop var value:String;

  @:transition
  public function setNameAndValue(name:String, value:String) {
    this.name = name;
    this.value = value;
  }

}
