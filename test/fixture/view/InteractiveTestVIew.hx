package fixture.view;

import scout.View;
import scout.component.ChildrenView;
import scout.Template.html;
import fixture.model.SimpleModel;

class InteractiveTestView extends View {

  @:attr var model:SimpleModel;
  @:attr(child) var body:ChildrenView<View>;

  @:on('submit', '.change-name')
  public function changeName(e:js.html.Event) {
    e.preventDefault();
    e.stopPropagation();
    var newName:js.html.InputElement = cast el.querySelector('.new-name');
    if (
      newName != null
      && newName.value != '' 
    ) {
      model.name = newName.value;
    }
  }

  public function render() return html('
    <header>
      <h1>Interactive Test</h1>
      <form class="change-name">
        <input value="" class="new-name" />
        <button>Change name</button>
      </form>
    </header>
    ${body}
  ');

}
