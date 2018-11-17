package fixture.view;

import scout.View;
import scout.Template.html;

class ChildView extends View {

  @:attr var className:String = "child";
  @:attr var tag:String = "li";
  @:attr var message:String;

  public function render() return html('${message}'); 

}