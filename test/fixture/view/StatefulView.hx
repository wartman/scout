package fixture.view;

import scout.View;

class StatefulView extends View {

  @:state var foo:String;

  @:observe(attrs.foo)
  function doRender(_) render();

  public function render() '${foo}';

}
