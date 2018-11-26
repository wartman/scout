package fixture.view;

import scout.View;

@:el(
  tag = 'span',
  id = cid,
  className,
  'data-foo' = foo,
  'data-bar' = 'bar'
)
class CustomElementView extends View {
  @:attr var foo:String;
}
