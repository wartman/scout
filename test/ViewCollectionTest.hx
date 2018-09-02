import haxe.unit.TestCase;
import fixture.view.*;
import scout.ViewCollection;

class ViewCollectionTest extends TestCase {

  public function testAddingAndRemovingViews() {
    var proxyView = new SimpleView({ key: 'proxy' });
    var collection = new ViewCollection(proxyView);

    var one = new SimpleView({ key: 'one' });
    var two = new SimpleView({ key: 'two' });

    collection.add(one);
    collection.add(two);

    assertTrue(collection.exists(one));
    assertTrue(collection.exists(two));

    collection.remove(one);
    assertFalse(collection.exists(one));
    assertTrue(collection.exists(two));
  }

  public function testReplacingViews() {
    var proxyView = new SimpleView({ key: 'proxy' });
    var collection = new ViewCollection(proxyView);
    
    var one = new SimpleView({ key: 'one' });
    var two = new SimpleView({ key: 'two' });

    collection.add(one);
    collection.add(two);

    assertEquals(2, collection.length);

    collection.add(one, { replace: true });
    
    assertFalse(collection.exists(two));
    assertEquals(1, collection.length);
  }

}
