package fixture.view;

import scout.View;
import scout.Template.html;
import fixture.model.SimpleModel;

class WithModelView extends View {

  @:attr var model:SimpleModel;

  public function template() return html('${model.name}|${model.value}');

  @:observe(model.signals.name)
  @:observe(model.signals.value)
  public function onNameChange(_) {
    render();
  }


}
