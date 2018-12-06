package scout;

using Lambda;

class Collection<T:Model> implements Observable<T> {

  public final onAdd:Signal<T> = new Signal();
  public final onRemove:Signal<T> = new Signal();
  public final onChange:Signal<T> = new Signal();
  public var length(get, never):Int;
  public function get_length():Int return models.length;
  var models:Array<T>;
  var modelListeners:Map<T, Signal.SignalSlot<Model>> = new Map();

  public function new(?init:Array<T>) {
    models = [];
    if (init != null) for (model in init) registerModel(model);
  }

  public function observe(cb:(model:T)->Void) {
    return onChange.add(cb);
  }

  public function add(model:T) {
    if (!models.has(model)) {
      registerModel(model);
      onAdd.dispatch(model);
      onChange.dispatch(model);
    }
    return this;
  }

  function registerModel(model:T) {
    models.push(model);
    var listener = model.observe(_ -> onChange.dispatch(model));
    modelListeners.set(model, listener);
  }

  public inline function indexOf(model:T):Int {
    return models.indexOf(model);
  }

  public inline function filter(f:(model:T)->Bool):Array<T> {
    return models.filter(f);
  }

  public inline function exists(model:T):Bool {
    return models.has(model);
  }

  public inline function idExists(id:Int):Bool {
    return has(function (m) return m.id == id);
  }

  public inline function has(elt:(model:T)->Bool):Bool {
    return models.exists(elt);
  }

  public inline function find(elt:(model:T)->Bool):T {
    return models.find(elt);
  }

  public inline function get(id:Int):T {
    return find(function (m) return m.id == id);
  }

  public inline function getAt(index:Int) {
    return models[index];
  }

  public inline function each(cb:(model:T)->Bool) {
    models.foreach(cb);
    return this;
  }

  public inline function map<B>(cb:T->B):Array<B> {
    return models.map(cb);
  }

  public function iterator():Iterator<T> {
    return models.iterator();
  }

  public function remove(model:T) {
    if (modelListeners.exists(model)) {
      modelListeners.get(model).remove();
      modelListeners.remove(model);
    }
    if (models.exists(function (m) return m.id == model.id)) {
      models = models.filter(function (m) return m.id != model.id);
      onRemove.dispatch(model);
      onChange.dispatch(model);
    }
    return this;
  }

  public function removeById(id:Int) {
    var model = get(id);
    if (model != null) {
      remove(model);
    }
    return this;
  }

}
