package fixture.view;

import scout.View;

class SingleChildView extends View {

  @:attr var child:SimpleView;

  public function render() 
    '<div class="content">${child}</div>';

}
