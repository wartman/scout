import haxe.unit.TestCase;
import scout.Element;
import scout.Template;

class ElementTest extends TestCase {

  public function testRendering() {
    var el = new Element('div', {
      className: 'bar'
    }, []);
    assertEquals('<div class="bar"></div>', el.render());
  }

  public function testRenderingWithChildren() {
    var el = new Element('div', {
      className: 'bar'
    }, [ 'foo', 'bar' ]);
    assertEquals('<div class="bar">foobar</div>', el.render());
  }

  public function testRenderingWithRenderResultChildren() {
    var el = new Element('div', {
      className: 'bar'
    }, [ 
      new Element('p', {}, [ 'hello' ]),
      '<p>world</p>',
    ]);
    assertEquals('<div class="bar"><p>hello</p>&lt;p&gt;world&lt;/p&gt;</div>', el.render());
  }

  public function testInsideTemplate() {
    var el = new Element('p', {
      className: 'foo'
    }, [ 'hello world' ]);
    var out = Template.html('<div>${el}</div>');
    assertEquals('<div><p class="foo">hello world</p></div>', out);
  }

}
