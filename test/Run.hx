import hex.unittest.notifier.*;
import hex.unittest.runner.*;
import scout.ModelTest;
import scout.CollectionTest;
import scout.ViewTest;
import scout.TemplateTest;

class Run {

  public static function main() {
    var emu = new ExMachinaUnitCore();
    #if travix
      emu.addListener(new TravixNotifier());
    // // #elseif (js && !nodejs) 
    // //   emu.addListener(new BrowserUnitTestNotifier('Root'));
    #else
      emu.addListener(new ConsoleNotifier(false));
    #end
    emu.addTest(ModelTest);
    emu.addTest(CollectionTest);
    emu.addTest(ViewTest);
    emu.addTest(TemplateTest);
    emu.addListener(new ExitingNotifier());
    emu.run();
  }

}
