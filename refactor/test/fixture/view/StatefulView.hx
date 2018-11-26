package fixture.view;

import scout.View;

class StatefulView extends View {

  @:state var foo:String;

  @:observe(foo)
  public function render() return html('<p>${foo}</p>');

}
