package fixture.view;

import scout.View;
import scout.Children;

class ChildrenView extends View {

  @:attr var body:Children<SimpleView>;

  public function render() '<div class="content">${body}</div>';

}
