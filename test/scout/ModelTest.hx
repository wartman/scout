package scout;

import fixture.model.*;

using hex.unittest.assertion.Assert;

class ModelTest {

  @Test
  public function testConstructor() {
    var simple = new SimpleModel({
      name: 'foo',
      value: 'bar'
    });
    simple.id.equals(@:privateAccess SimpleModel.__scout_ids);
    'foo'.equals(simple.name);
    'bar'.equals(simple.value);
  }

  @Test
  public function testSignalsWithObserve() {
    var simple = new SimpleModel({
      id: 1,
      name: 'foo',
      value: 'bar'
    });
    var nameChanged = 0;
    simple.observe(_ -> nameChanged++);
    simple.name = 'one';
    simple.name = 'two';
    simple.name = 'four';
    nameChanged.equals(3);
  }

  @Test
  public function signalDoesNotFireIfNoChange() {
    var simple = new SimpleModel({
      id: 1,
      name: 'foo',
      value: 'bar'
    });
    var nameChanged = 0;
    simple.observe(_ -> nameChanged++);
    simple.name = 'one';
    simple.name = 'one';
    simple.name = 'one';
    simple.name = 'one';
    simple.name = 'one';
    simple.name = 'two';
    nameChanged.equals(2);
  }

  @Test
  public function testSpecificSignals() {
    var simple = new SimpleModel({
      id: 1,
      name: 'foo',
      value: 'bar'
    });
    var nameChanged = 0;
    var valueChanged = 0;
    simple.props.name.observe(_ -> nameChanged++);
    simple.props.value.observe(_ -> valueChanged++);

    simple.name = 'one';
    simple.name = 'two';
    simple.name = 'four';
    nameChanged.equals(3);

    simple.value = 'one';
    simple.value = 'two';
    simple.value = 'four';
    valueChanged.equals(3);
  }

  @Test
  public function testComputed() {
    var computed = new ComputedModel({
      foo: 'foo',
      bar: 'bar'
    });
    var fooBarChanged = 0;
    computed.props.fooBar.observe(_ -> fooBarChanged++);

    computed.fooBar.equals('foobar');
    computed.foo = 'changed';
    fooBarChanged.equals(1);
    computed.fooBar.equals('changedbar');
    computed.bar = 'changed';
    fooBarChanged.equals(2);
    computed.fooBar.equals('changedchanged');
  }

  @Test
  public function testAutoIncrement() {
    var start = @:privateAccess ComputedModel.__scout_ids;
    var one = new ComputedModel({ foo:'foo', bar: 'bar' });
    var two = new ComputedModel({ foo:'foo', bar: 'bar' });

    (one.id != two.id).isTrue();
    (start + 1).equals(one.id);
    (start + 2).equals(two.id);
  }

  @Test
  public function testReactiveModel() {
    var model = new ReactiveModel({
      foo: 'bar'
    });
    model.foo = 'bin';
    model.foo = 'bax';
    model.changed.equals(2);
  }

  @Test
  public function testTransitionableModel() {
    var model = new TransitionableModel({
      id: 0,
      name: 'foo',
      value: 'foo'
    });
    var changed:Int = 0;
    model.observe(function (_) changed++);
    
    model.setNameAndValue('bar', 'bar');
    changed.equals(1);
    model.name.equals('bar');
    model.value.equals('bar');

    changed = 0;

    model.name = 'foo';
    model.value = 'foo';
    changed.equals(2);
  }

  @Test
  public function testOptionalModel() {
    var model = new OptionalModel({
      name: 'foo'
    });
    model.value.equals(null);
  }

  @Test
  public function testModelsUseTheCorrectPropertyWithViews() {
    var model = new WithViewModel({
      view: new fixture.view.SimpleView({ location: 'World', greeting: 'Hello' })
    });
    // Note: all we care about is if it compiles.
    model.view.location.equals('World');
  }

}
