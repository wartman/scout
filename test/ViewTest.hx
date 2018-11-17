import haxe.unit.TestCase;
import fixture.view.*;
import fixture.model.*;
using StringTools;
using ViewTest;

class ViewTest extends TestCase {
 
  public static function clean(content:String) {
    return content.replace('\n', '').replace('\r', '').replace(' ', '').trim();
  }
  
  #if js

    public function testReal() {
      assertTrue(true);
      var view = new WithConstructorChildrenView({
        body: new scout.component.ChildrenView({
          body: [
            cast new ChildView({ message: 'Hey' }),
            cast new ChildView({ message: 'World' })
          ]
        })
      });
      view.render();
      js.Browser.document.querySelector('#Root').appendChild(view.el);
    }

  #end

  public function testConstructor() {
    var foo = new AttrsView({
      location: 'bar'
    });
    foo.render();
    assertEquals('<section class="foo">Hello bar!</section>', foo.content);
  }

  public function testChildren() {
    var bar = new WithChildrenView({});
    bar.render();
    assertEquals(
      '<div><ulclass="children"><liclass="child">Hey</li><liclass="child">World</li></ul></div>', 
      bar.content.clean()
    );
  }

  public function testViewWithModel() {
    var model = new SimpleModel({
      id: 1,
      name: 'foo',
      value: 'bar'
    });
    var view = new WithModelView({ model: model });
    view.render();
    assertEquals(
      '<div>foo|bar</div>',
      view.content
    );
    model.name = 'changed';
    assertEquals(
      '<div>changed|bar</div>',
      view.content
    );
    model.value = 'changed';
    assertEquals(
      '<div>changed|changed</div>',
      view.content
    );
  }

  public function testAddChildrenViaConstructor() {
    var view = new WithConstructorChildrenView({
      body: new scout.component.ChildrenView({
        body: [
          cast new ChildView({ message: 'Hey' }),
          cast new ChildView({ message: 'World' })
        ]
      })
    });
    view.render();
    assertEquals(
      '<div>
        <ul class="children">
          <li class="child">Hey</li>
          <li class="child">World</li>
        </ul>
      </div>'.clean(),
      view.content.clean()
    );
  }

  public function testEventBinding() {
    var view = new WithJsEventView({});
    // should compile for all targets is all :V
    assertTrue(true);
  }

  public function testAttrRendering() {
    var view = new WithRenderedAttrsView({ key: 'bar' });
    view.render();
    assertEquals('<section data-foo="foo" id="Foo" class="foo">bar</section>'.clean(), view.content.clean());
  }

  public function testState() {
    var view = new StatefulView({ state: false });
    view.render();
    assertEquals('<div>off</div>', view.content);
    view.state = true;
    assertEquals('<div>on</div>', view.content);
  }

}
