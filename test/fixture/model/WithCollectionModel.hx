package fixture.model;

import scout.Model;
import scout.Collection;

class WithCollectionModel implements Model {
  @:prop var collection:Collection<SimpleModel> = new Collection();
}
