package scout;

import fixture.view.*;

using hex.unittest.assertion.Assert;

class ViewTest {

  @Test
  public function testSimpleView() {
    var view = new SimpleView({
      greeting: 'Hey',
      location: 'World'
    });
    view.render().content.equals('<div><p>Hey World</p></div>');
  }

  @Test
  public function testCustomElement() {
    var view = new CustomElementView({
      foo: 'foo'
    });
    view.render().content.equals('<span class="foo" id="${view.cid}" data-foo="foo" data-bar="bar"></span>');
  }

  @Test
  public function testChild() {
    var bar = new SingleChildView({
      child: new SimpleView({
        location: 'World',
        greeting: 'Hello'
      })
    });
    var expected = '<div><div class="content"><div><p>Hello World</p></div></div></div>';
    bar.render().content.equals(expected);
    // test rerendering
    bar.render().content.equals(expected);
  }

  @Test
  public function testChildren() {
    var bar = new ChildrenView({
      body: [ 
        new SimpleView({
          location: 'World',
          greeting: 'Hello'
        }),
        new SimpleView({
          location: 'World',
          greeting: 'Goodbye'
        })
      ]
    });
    var expected = '<div><div class="content"><div><p>Hello World</p></div><div><p>Goodbye World</p></div></div></div>';
    bar.render().content.equals(expected);
    bar.render().content.equals(expected);
  }


}
