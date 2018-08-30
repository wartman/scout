package fixture.view;

import scout.View;
import scout.Template.html;

private class ChildView extends View {

  @:attr var className:String = "child";
  @:attr var tag:String = "li";
  @:attr var message:String;

  public function template() return html('${message}'); 

}

class WithChildrenView extends View {

  @:init public function setupChildren() {
    add(new ChildView({ message: 'Hey' }));
    add(new ChildView({ message: 'World' }));
  }

  public function template() return html('
    <ul>
      ${ children }
    </ul>
  ');

}
