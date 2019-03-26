package fixture.view;

import scout.View;

class OptionalChildView extends View {

  @:attr @:optional var child:SimpleView;

  public function render() 
    '<div class="content">${child}</div>';

}
