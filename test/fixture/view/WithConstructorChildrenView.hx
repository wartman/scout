package fixture.view;

import scout.View;
import scout.Children;
import scout.Template.html;

class WithConstructorChildrenView extends View {

  @:attr var body:Children<View>;

  public function render() return html('<ul>${body}</ul>');

}
