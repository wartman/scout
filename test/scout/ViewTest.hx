package scout;

import fixture.model.SimpleModel;
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
  public function testStringsAreConverted() {
    var view = new ChecksTemplateStringView({
      foo: 'foo'
    });
    view.render().content.equals('<div>bar bin foo</div>');
  }

  @Test
  public function testCustomElement() {
    var view = new CustomElementView({
      className: 'foo',
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

  @Test
  public function testStatefulView() {
    var view = new StatefulView({ foo: 'foo' });
    view.render().content.equals('<div>foo</div>');
    view.foo = 'bar';
    // Note that we don't render again!
    view.content.equals('<div>bar</div>');
  }

  @Test
  public function testStateChild() {
    var bar = new SingleStateChildView({
      child: new SimpleView({
        location: 'World',
        greeting: 'Hello'
      })
    });
    var expected = '<div><div class="content"><div><p>Hello World</p></div></div></div>';
    bar.render().content.equals(expected);
    // test rerendering
    bar.render().content.equals(expected);
    
    expected = '<div><div class="content"><div><p>Goodbye World</p></div></div></div>';
    bar.child = new SimpleView({
      location: 'World',
      greeting: 'Goodbye'
    });
    bar.content.equals(expected);
    // test rerendering
    bar.render().content.equals(expected);
  }

  @Test
  public function testModelView() {
    var view = new WithModelView({ model: new fixture.model.SimpleModel({ name: 'foo', value: 'bar' }) });
    view.render().content.equals('<div>foo bar</div>');
    view.model.name = 'bar';
    view.model.value = 'foo';
    // Note that we don't render again!
    view.content.equals('<div>bar foo</div>');
  }

  @Test
  public function testModelStateView() {
    var view = new WithModelStateView({ model: new fixture.model.SimpleModel({ name: 'foo', value: 'bar' }) });
    view.render().content.equals('<div>foo bar</div>');
    view.model = new fixture.model.SimpleModel({ name: 'bar', value: 'foo' });
    // Note that we don't render again!
    view.content.equals('<div>bar foo</div>');
  }

  @Test
  public function testCollectionView() {
    var collection:Collection<SimpleModel> = new Collection([
      new SimpleModel({ name: 'foo', value: 'bar' })
    ]);
    var view = new WithCollectionView({ collection: collection });
    var expected = '<div><div>foo bar</div></div>';
    view.render().content.equals(expected);

    collection.add(new SimpleModel({ name: 'bin', value: 'bax' }));
    expected = '<div><div>foo bar</div><div>bin bax</div></div>';
    view.content.equals(expected);
  }

}
