package fixture.view;

import scout.View;

class SimpleView extends View {

  @:attr var greeting:String = 'hello';
  @:attr var location:String = 'world';

  public function render() 
    '<p>${greeting} ${location}</p>';

}
