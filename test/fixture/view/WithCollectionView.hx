package fixture.view;

import scout.View;
import scout.ModelCollection;
import scout.Template.html;
import scout.component.ListView;
import fixture.model.SimpleModel;

class WithCollectionView extends View {

  private static var id:Int = 10;
  
  @:attr var collection:ModelCollection<SimpleModel>;
  @:attr(child) var body:ListView<SimpleModelView> = new ListView({ items: [] });

  @:init
  public function initializeChildren() {
    for (model in collection) {
      addViewForModel(model);
    }
  }

  @:observe(collection.onAdd)
  public function addViewForModel(model:SimpleModel) {
    body.add(new SimpleModelView({
      model: model,
      collection: this.collection
    }));
  }

  @:observe(collection.onRemove)
  public function removeViewForModel(model:SimpleModel) {
    for (view in body.items) {
      if (view.model == model) {
        body.delete(view);
      }
    }
  }

  @:on('click', '.add')
  public function addModelOnClick(e:js.html.Event) {
    collection.add(new SimpleModel({
      id: id++,
      name: 'added',
      value: 'Added!'
    }));
  }

  public function render() 
    return html('
      <button class="add">Add model</button>
      <ul>${body}</ul>
    ');

}
