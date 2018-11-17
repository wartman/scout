package fixture.view;

import scout.View;
import scout.component.ChildrenView;
import scout.Template.html;

class WithConstructorChildrenView extends View {

  @:attr(child) var body:ChildrenView<View> = new ChildrenView({});

  public function template() 
    return html('<ul>${body}</ul>');

}
