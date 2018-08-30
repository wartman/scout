import haxe.unit.TestCase;

import fixture.view.*;
using StringTools;

class ViewTest extends TestCase {
 
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
      '<div><ul><divid="__scout_1"><liclass="child">Hey</li><liclass="child">World</li></div></ul></div>', 
      bar.content.replace('\n', '').replace(' ', '').trim()
    );
  }

  #if js

    public function testReal() {
      var one = new AttrsView({
        sel: '#test-1',
        location: 'browser'
      });
      var two = new WithChildrenView({
        sel: '#test-2'
      });
      one.render();
      two.render();
      assertTrue(one.isReady);
      assertTrue(two.isReady);
    }

  #end

}
