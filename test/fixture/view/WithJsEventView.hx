package fixture.view;

import scout.View;
import scout.Template.html;

class WithJsEventView extends View {

  @:on('click')
  public function onClick(e:js.html.Event) {
    e.preventDefault();
    trace('yay');    
  }

  public function template() return html('ok');

}
