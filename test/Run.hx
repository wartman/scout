import hex.unittest.notifier.*;
import hex.unittest.runner.*;
import scout.ModelTest;
import scout.CollectionTest;
import scout.ViewTest;
import scout.TemplateTest;

class Run {

  public static function main() {
    var emu = new ExMachinaUnitCore();
    // #if (js && !nodejs) 
    //   emu.addListener(new BrowserUnitTestNotifier('Root'));
    // #else
      emu.addListener(new ConsoleNotifier(false));
    // #end
    emu.addListener(new ExitingNotifier());
    emu.addTest(ModelTest);
    emu.addTest(CollectionTest);
    emu.addTest(ViewTest);
    emu.addTest(TemplateTest);
    emu.run();
  }

}
