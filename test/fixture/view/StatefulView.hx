package fixture.view;

import scout.View;
import scout.Template.html;

class StatefulView extends View {

  @:attr(observe) var state:Bool = false;

  public function render() return state ? html('on') : html('off');

}