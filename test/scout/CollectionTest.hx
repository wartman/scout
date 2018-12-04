package scout;

import fixture.model.SimpleModel;

using hex.unittest.assertion.Assert;

class CollectionTest {

  @Test
  public function testBasics() {
    var collection:Collection<SimpleModel> = new Collection([
      new SimpleModel({
        id:1,
        name: 'foo',
        value: 'bar'
      })
    ]);
    var model = collection.get(1);
    model.name.equals('foo');
    collection.exists(model).isTrue();
    collection.has(function (m) return m.value == model.value).isTrue();
    collection.remove(model);
    collection.exists(model).isFalse();
  }

  @Test
  public function testDoesNotAddDups() {
    var collection:Collection<SimpleModel> = new Collection();
    var model = new SimpleModel({
      id:1,
      name: 'foo',
      value: 'bar'
    });
    collection.add(model);
    collection.add(model);
    collection.length.equals(1);
  }

  @Test
  public function testAddRemoveLifecycle() {
    var collection:Collection<SimpleModel> = new Collection([
      new SimpleModel({
        id:1,
        name: 'foo',
        value: 'bar'
      })
    ]);
    var onAdd:Int = 0;
    var onRemove:Int = 0;
    collection.onAdd.add(_ -> onAdd++);
    collection.onRemove.add(_ -> onRemove++);
    var model = new SimpleModel({
      id: 2,
      name: 'bin',
      value: 'bax'
    });
    collection.add(model);
    collection.remove(model);
    onAdd.equals(1);
    onRemove.equals(1);
  }

  @Test
  public function testModelChanges() {
    var collection:Collection<SimpleModel> = new Collection();
    var changed:Int = 0;
    var model = new SimpleModel({
      id:1,
      name: 'foo',
      value: 'bar'
    });
    
    collection.observe(_ -> changed++);
    
    collection.add(model);
    model.name = 'changed';
    model.value = 'changed';
    // `3` because `add` dispatched an `onChange` event too.
    changed.equals(3);

    collection.remove(model);
    model.name = 'changed again';
    model.value = 'changed again';
    // 4 becasue `remove` dispatched an `onChange` event too.
    changed.equals(4);
  }

  @Test
  public function observesModels() {
    var model = new SimpleModel({
      id:1,
      name: 'foo',
      value: 'bar'
    });
    var collection:Collection<SimpleModel> = new Collection([ model ]);
    var observed:String = '';
    collection.observe(model -> observed += model.name);
    model.value = 'bin';
    observed.equals('foo');
  }

}
