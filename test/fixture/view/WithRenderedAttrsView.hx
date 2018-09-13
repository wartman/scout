package fixture.view;

import scout.View;
import scout.Template.html;

class WithRenderedAttrsView extends View {

  @:attr var tag:String = 'section';
  @:attr(tag) var className:String = 'foo';
  @:attr(tag) var id:String = 'Foo';
  @:attr(tag) var dataFoo:String = 'foo';
  @:attr var key:String;

  public function template() return html(key);

}
