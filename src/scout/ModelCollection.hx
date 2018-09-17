package scout;

using Lambda;

class ModelCollection<T:Model> implements Observable<ModelCollection<T>> {

  public var length(get, never):Int;
  public function get_length():Int return models.length;
  public var onAdd(default, never):Signal<T> = new Signal();
  public var onRemove(default, never):Signal<T> = new Signal();
  public var onChange(default, never):Signal<ModelCollection<T>> = new Signal();
  private var models:Array<T>;
  private var modelListeners:Map<T, Signal.SignalSlot<Model>> = new Map();

  public function new(?init:Array<T>) {
    models = init != null ? init : [];
  }

  public function subscribe(cb:ModelCollection<T>->Void) {
    return onChange.add(cb);
  }

  public function add(model:T) {
    if (!models.has(model)) {
      models.push(model);
      modelListeners.set(model, model.subscribe(function (_) onChange.dispatch(this)));
      onAdd.dispatch(model);
      onChange.dispatch(this);
    }
    return this;
  }

  public inline function indexOf(model:T):Int {
    return models.indexOf(model);
  }

  public inline function filter(f:T->Bool):Array<T> {
    return this.models.filter(f);
  }

  public inline function exists(model:T):Bool {
    return models.has(model);
  }

  public inline function idExists(id:Int):Bool {
    return has(function (m) return m.id == id);
  }

  public inline function has(elt:T->Bool):Bool {
    return models.exists(elt);
  }

  public inline function find(elt:T->Bool):T {
    return models.find(elt);
  }

  public inline function get(id:Int):T {
    return find(function (m) return m.id == id);
  }

  public inline function getAt(index:Int) {
    return models[index];
  }

  public inline function each(cb:T->Bool) {
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
      onChange.dispatch(this);
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
