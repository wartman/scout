package fixture.view;

import scout.View;
import scout.Template.html;
import fixture.model.SimpleModel;

class WithModelView extends View {

  @:attr var model:SimpleModel;

  public function template() return html('${model.name}|${model.value}');

  @:observe(model.states.name)
  @:observe(model.states.value)
  public function onNameChange(_) {
    render();
  }


}
