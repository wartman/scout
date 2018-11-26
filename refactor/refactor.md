The new view will look like this:

```haxe
@:element(className = 'foo') // or `@:element('div.foo')`
class Foo extends View {

  @:attr var foo:String;
  @:attr(state) var bar:String; // `state` now required to make reactive
  @:attr var body:Children<View>; // same as before
  @:attr var efficient:EfficientChildren<View, 'div.foo'>;

  public function render() return html('
    <div class="content">
      ${body}
    </div>
    ${efficient}
  ');

}
```

New model looks the same.
