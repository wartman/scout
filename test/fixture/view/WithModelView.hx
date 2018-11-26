package fixture.view;

import scout.View;
import fixture.model.SimpleModel;

class WithModelView extends View {

  @:attr var model:SimpleModel;

  @:observe(model)
  function update(_) render();

  public function render() 
    '${model.name} ${model.value}'; 

}
