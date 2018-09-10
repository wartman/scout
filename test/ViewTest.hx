import haxe.unit.TestCase;
import fixture.view.*;
import fixture.model.*;
using StringTools;
using ViewTest;

class ViewTest extends TestCase {
 
  public static function clean(content:String) {
    return content.replace('\n', '').replace('\r', '').replace(' ', '').trim();
  }

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
      '<div><ulid="__scout_1"><liclass="child">Hey</li><liclass="child">World</li></ul></div>', 
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
    var view = new WithConstructorChildrenView({}, [
      new ChildView({ message: 'Hey' }),
      new ChildView({ message: 'World' })
    ]);
    view.render();
    assertEquals(
      '<div>
        <ul id="${view.children.cid}">
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

  #if js

    public function testReal() {
      assertTrue(true);
      
      var model = new SimpleModel({
        id: 1,
        name: 'One',
        value: 'bar'
      });
      var model2 = new SimpleModel({
        id: 2,
        name: 'Two',
        value: 'Waiting...'
      });
      model.signals.name.add(function (value) {
        model2.value = 'Model 1 name: ' + value;
      });
      
      var interactiveView = new InteractiveTestView({
        sel: '#Root',
        model: model
      }, [

        new AttrsView({
          location: 'The Internet'
        }),
        
        new WithConstructorChildrenView({}, [
          new ChildView({ message: 'Hey' }),
          new ChildView({ message: 'World' }),
          new ChildView({ message: 'How are kicks' })
        ]),

        new WithModelView({ model: model2 }),
        new WithModelView({ model: model }),

        new WithCollectionView({
          collection: new scout.ModelCollection([
            model,
            model2
          ])
        })

      ]);

      interactiveView.render();
    }

  #end

}
