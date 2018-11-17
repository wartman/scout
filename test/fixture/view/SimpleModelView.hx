package fixture.view;

import scout.View;
import scout.ModelCollection;
import scout.Template.html;
import fixture.model.SimpleModel;

class SimpleModelView extends View {

  @:attr var className:String = "child";
  @:attr var tag:String = 'li';
  @:attr var model:SimpleModel;
  @:attr var collection:ModelCollection<SimpleModel>;

  @:on('click', '.remove')
  public function removeSelf(e) {
    e.preventDefault();
    e.stopPropagation();
    collection.remove(model);
  }

  public function render() return html('${model.value} <button class="remove">x</button>'); 

}
