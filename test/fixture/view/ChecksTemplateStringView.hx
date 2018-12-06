package fixture.view;

import scout.View;

class ChecksTemplateStringView extends View {

  @:attr var foo:String;

  public function render() '${bar()} ${bin()}';

  public function bar() 'bar';

  public function bin() 'bin ${foo}';

}
