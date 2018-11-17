package fixture.view;

import scout.View;
import scout.Template.html;

class SimpleView extends View {

  @:attr var className:String = 'foo';
  @:attr var tag:String = 'section';
  @:attr var key:String;

  public function render() return html(key);

}
