package fixture.view;

import scout.View;
import scout.Template.html;

class AttrsView extends View {

  @:attr var className:String = 'foo';
  @:attr var tag:String = 'section';
  @:attr var location:String = 'world';

  public function render() return html('Hello ${location}!');

  @:on('click')
  public function onClick(e) {
    trace('hi');
  }

} 
