package fixture.view;

import scout.View;
import scout.Template.html;

class WithConstructorChildrenView extends View {

  public function template() 
    return children.mount('ul');

}
