package fixture.view;

import scout.View;

class SingleStateChildView extends View {

  @:state var child:SimpleView;

  @:observe(child)
  public function update(_) render();

  public function render() 
    '<div class="content">${child}</div>';

}
