package fixture.view;

import scout.View;
import scout.ModelCollection;
import scout.Template.html;
import fixture.model.SimpleModel;

using Reflect;

class WithCollectionView extends View {

  private static var id:Int = 10;
  
  @:attr var collection:ModelCollection<SimpleModel>;

  @:init
  public function initializeChildren() {
    for (model in collection) {
      addViewForModel(model);
    }
  }

  @:observe(collection.onAdd)
  public function addViewForModel(model:SimpleModel) {
    addView(new SimpleModelView({
      model: model,
      collection: this.collection
    }));
  }

  @:observe(collection.onRemove)
  public function removeViewForModel(model:SimpleModel) {
    for (view in children) {
      if (cast(view, SimpleModelView).model == model) {
        removeView(view);
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

  public function template() 
    return html('
      <button class="add">Add model</button>
      ${ children.mount("ul") }
    ');

}
