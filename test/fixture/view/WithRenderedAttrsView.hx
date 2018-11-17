package fixture.view;

import scout.View;
import scout.Template.html;

class WithRenderedAttrsView extends View {

  @:attr var tag:String = 'section';
  @:attr var className:String = 'foo';
  @:attr(tag) var id:String = 'Foo';
  @:attr(tag = 'data-foo') var dataFoo:String = 'foo';
  @:attr var key:String;

  public function render() return html(key);

}
