import haxe.unit.TestCase;
import scout.Element;

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


}
