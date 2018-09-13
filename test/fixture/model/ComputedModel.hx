package fixture.model;

import scout.Model;

class ComputedModel implements Model {
  @:prop(auto) var id:Int;
  @:prop var foo:String;
  @:prop var bar:String;
  @:computed(foo, bar) var fooBar:String = foo + bar;
}
