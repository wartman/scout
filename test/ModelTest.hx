import haxe.unit.TestCase;
import scout.Model;
import fixture.model.*;

class ModelTest extends TestCase {

  public function testConstructor() {
    var simple = new SimpleModel({
      id: 1,
      name: 'foo',
      value: 'bar'
    });
    assertEquals(1, simple.id);
    assertEquals('foo', simple.name);
    assertEquals('bar', simple.value);
  }

  public function testSignalsWIthSubscribe() {
    var simple = new SimpleModel({
      id: 1,
      name: 'foo',
      value: 'bar'
    });
    var nameChanged = 0;
    simple.subscribe(function (_) nameChanged++);
    simple.name = 'one';
    simple.name = 'two';
    simple.name = 'four';
    assertEquals(3, nameChanged);
  }

  public function testSignalsDoNotFireIfNoChange() {
    var simple = new SimpleModel({
      id: 1,
      name: 'foo',
      value: 'bar'
    });
    var nameChanged = 0;
    simple.subscribe(function (_) nameChanged++);
    simple.name = 'one';
    simple.name = 'one';
    simple.name = 'one';
    simple.name = 'one';
    simple.name = 'one';
    simple.name = 'two';
    assertEquals(2, nameChanged);
  }

  public function testSpecificSignals() {
    var simple = new SimpleModel({
      id: 1,
      name: 'foo',
      value: 'bar'
    });
    var nameChanged = 0;
    var valueChanged = 0;
    simple.signals.name.add(function (_) nameChanged++);
    simple.signals.value.add(function (_) valueChanged++);

    simple.name = 'one';
    simple.name = 'two';
    simple.name = 'four';
    assertEquals(3, nameChanged);

    simple.value = 'one';
    simple.value = 'two';
    simple.value = 'four';
    assertEquals(3, valueChanged);
  }

  public function testComputed() {
    var computed = new ComputedModel({
      foo: 'foo',
      bar: 'bar'
    });
    var fooBarChanged = 0;
    computed.signals.fooBar.add(function (_) fooBarChanged++);

    assertEquals('foobar', computed.fooBar);
    computed.foo = 'changed';
    assertEquals(1, fooBarChanged);
    assertEquals('changedbar', computed.fooBar);
    computed.bar = 'changed';
    assertEquals(2, fooBarChanged);
    assertEquals('changedchanged', computed.fooBar);
  }

  public function testAutoIncrement() {
    var start = @:privateAccess ComputedModel.__scout_ids;
    var one = new ComputedModel({ foo:'foo', bar: 'bar' });
    var two = new ComputedModel({ foo:'foo', bar: 'bar' });

    assertTrue(one.id != two.id);
    assertEquals(start, one.id);
    assertEquals(start + 1, two.id);
  }

  public function testReactiveModel() {
    var model = new ReactiveModel({
      foo: 'bar'
    });
    model.foo = 'bin';
    model.foo = 'bax';
    assertEquals(2, model.changed);
  }

  public function testTransitionableModel() {
    var model = new TransitionableModel({
      id: 0,
      name: 'foo',
      value: 'foo'
    });
    var changed:Int = 0;
    model.subscribe(function (_) changed++);
    
    model.setNameAndValue('bar', 'bar');
    assertEquals(1, changed);
    assertEquals('bar', model.name);
    assertEquals('bar', model.value);

    changed = 0;

    model.name = 'foo';
    model.value = 'foo';
    assertEquals(2, changed);
  }

  public function testOptionalModel() {
    var model = new OptionalModel({
      id: 1,
      name: 'foo'
    });

    assertEquals(null, model.value);
  }

}
