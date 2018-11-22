package fixture.view;

import scout.View;
import scout.Children;
import scout.Template.html;

class WithChildrenView extends View {

  @:attr var body:Children<ChildView> = new Children([
    new ChildView({ message: 'Hey' }),
    new ChildView({ message: 'World' })
  ]);

  public function render()
    return html('<li class="children">${body}</li>');

}
