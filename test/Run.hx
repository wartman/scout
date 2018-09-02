import haxe.unit.TestRunner;

class Run {

  public static function main() {
    var runner = new TestRunner();
    runner.add(new ViewTest());
    runner.add(new TemplateTest());
    runner.add(new ModelTest());
    runner.add(new ModelCollectionTest());
    runner.add(new ViewCollectionTest());
    runner.run();
  }

}
