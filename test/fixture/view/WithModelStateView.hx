package fixture.view;

import scout.View;
import fixture.model.SimpleModel;

class WithModelStateView extends View {

  @:state var model:SimpleModel;

  @:observe(attrs.model)
  function update(_) render();

  public function render() 
    '${model.name} ${model.value}'; 

}
