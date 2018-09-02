package fixture.view;

import scout.View;
import scout.Template.html;

class WithChildrenView extends View {

  @:init public function setupChildren() {
    addViews([
      new ChildView({ message: 'Hey' }),
      new ChildView({ message: 'World' })
    ]);
  }

  public function template() 
    return children.mount('ul');

}
