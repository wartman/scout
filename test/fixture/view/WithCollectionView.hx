package fixture.view;

import scout.View;
import scout.Children;
import scout.Collection;
import fixture.model.SimpleModel;

class WithCollectionView extends View {

  private static var id:Int = 10;
  
  @:attr var collection:Collection<SimpleModel>;
  @:attr var body:Children<WithModelView> = new Children([ for (model in collection) makeView(model) ]);

  @:observe(collection.onAdd)
  public function addViewForModel(model:SimpleModel) {
    body.add(makeView(model));
  }

  function makeView(model:SimpleModel) {
    return new WithModelView({
      model: model
    });
  }

  @:observe(collection.onRemove)
  public function removeViewForModel(model:SimpleModel) {
    var view = body.find(v -> v.model == model);
    if (view != null) body.remove(view);
  }

  public function render() '${body}';

}
