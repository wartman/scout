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

}
