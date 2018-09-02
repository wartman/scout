import haxe.unit.TestCase;
import scout.ModelCollection;
import fixture.model.SimpleModel;

class ModelCollectionTest extends TestCase {

  public function testBasics() {
    var collection:ModelCollection<SimpleModel> = new ModelCollection([
      new SimpleModel({
        id:1,
        name: 'foo',
        value: 'bar'
      })
    ]);
    var model = collection.get(1);
    assertEquals('foo', model.name);
    assertTrue(collection.exists(model));
    assertTrue(collection.has(function (m) return m.value == model.value));
    collection.remove(model);
    assertFalse(collection.exists(model));
  }

  public function testDoesNotAddDups() {
    var collection:ModelCollection<SimpleModel> = new ModelCollection();
    var model = new SimpleModel({
      id:1,
      name: 'foo',
      value: 'bar'
    });
    collection.add(model);
    collection.add(model);
    assertEquals(1, collection.length);
  }

  public function testAddRemoveLifecycle() {
    var collection:ModelCollection<SimpleModel> = new ModelCollection([
      new SimpleModel({
        id:1,
        name: 'foo',
        value: 'bar'
      })
    ]);
    var onAdd:Int = 0;
    var onRemove:Int = 0;
    collection.onAdd.add(function (_) onAdd++);
    collection.onRemove.add(function (_) onRemove++);
    var model = new SimpleModel({
      id: 2,
      name: 'bin',
      value: 'bax'
    });
    collection.add(model);
    collection.remove(model);
    assertEquals(1, onAdd);
    assertEquals(1, onRemove);
  }

  public function testModelChanges() {
    var collection:ModelCollection<SimpleModel> = new ModelCollection();
    var changed:Int = 0;
    var model = new SimpleModel({
      id:1,
      name: 'foo',
      value: 'bar'
    });
    
    collection.subscribe(function (_) changed++);
    
    collection.add(model);
    model.name = 'changed';
    model.value = 'changed';
    // `3` because `add` dispatched an `onChange` event too.
    assertEquals(3, changed);

    collection.remove(model);
    model.name = 'changed again';
    model.value = 'changed again';
    // 4 becasue `remove` dispatched an `onChange` event too.
    assertEquals(4, changed);
  }

}
