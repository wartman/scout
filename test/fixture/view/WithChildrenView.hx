package fixture.view;

import scout.View;
import scout.component.ListView;
import scout.Template.html;

class WithChildrenView extends View {

  @:attr(child) var body:ListView<ChildView> = new ListView({
    className: 'children',
    items: [
      new ChildView({ message: 'Hey' }),
      new ChildView({ message: 'World' })
    ]
  });

  public function render()
    return html('${body}');

}
