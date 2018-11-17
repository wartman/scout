package scout;

import scout.Signal;

class Child<T:View> implements Renderable implements Stateful<T> {

  static var ids:Int = 0; 

  public var signal(default, never):Signal<T> = new Signal();
  var cid:String = '__scout_proxy_' + (ids++); 
  var parent:View;
  var view:T;

  public function new(parent:View, view:T) {
    this.parent = parent;
    this.view = view;
    #if js
      this.parent.onRemove.add(function (_) this.remove());
      this.parent.beforeRender.add(function (_) this.detach());
      this.parent.afterRender.add(function (_) this.attach());
    #end
  }

  public function subscribe(cb:T->Void):SignalSlot<T> {
    return signal.add(cb);
  }

  public function set(value:T) {
    if (view == value) { 
      return;
    }
    #if js
      remove();
      view = value;
      attach();
    #end
    signal.dispatch(view);
  }
  
  public function get():T {
    // A bit hacky...
    // Also, we should make sure that the view can reset to its
    // old `toRenderResult` method if it's no longer being managed here :P.
    view.doToRenderResult = this.toRenderResult;
    return view;
  }

  #if js
    
    public function remove() {
      view.remove();
    }

    public function attach() {
      var target = parent.el.querySelector('#${cid}');
      if (target != null) {
        target.parentNode.replaceChild(view.render().el, target);
      }
    }

    public function detach() {
      if (view.el.parentElement != null) {
        view.el.parentElement.removeChild(view.el);
      }
    }

    public function toRenderResult():RenderResult {
      return Template.html('<div id="${cid}"></div>');
    }

  #else

    public function toRenderResult():RenderResult {
      return view.render().content;  
    }

  #end

}
