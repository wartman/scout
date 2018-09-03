package scout;

#if js
  import js.html.Element;
#end
import scout.Template;

using Lambda;

class ViewCollection implements Renderable {

  private static var ids:Int = 0;

  public var view(default, null):View;
  public var parent:ViewCollection = null;
  public var cid(default, null):String = '__scout_' + ids++;
  public var rendered:Bool = false;
  public var attached:Bool = false;
  private var views:Array<View> = [];
  public var length(get, never):Int;
  public function get_length():Int return views.length;
  private var onReady:Signal<ViewCollection> = new Signal();

  #if sys
    public var content(default, null):String = '';
  #end

  public function new(view:View, ?initViews:Array<View>) {
    this.view = view;
    if (initViews != null) {
      for (view in initViews) {
        add(view);
      }
    }

    #if js
      this.view.onRemove.add(function (_) removeAll());
      this.view.beforeRender.add(function (_) detach());
      this.view.afterRender.add(function (_) render());
    #end
  }

  public function add(view:View, ?options:{ 
    ?silent:Bool, 
    ?replace:Bool,
    ?at:Int 
  }) {
    if (options == null) {
      options = { silent: false, replace: false };
    }

    if (options.replace) {
      for (v in views) {
        remove(v, { silent: options.silent });
      }
      views = [];
    }

    if (options.at != null) {
      views.insert(options.at, view);
    } else {
      views.push(view);
    }
    view.children.parent = this;
    
    #if js
      if (!options.silent) {
        attach([ view ], { ready: inDom() });
      }
    #end

    return this;
  }

  public function remove(view:View, ?options:{ silent:Bool }) {
    if (options == null) {
      options = { silent: false };
    }

    views.remove(view);

    #if js
      if (!options.silent) {
        view.remove();
      }
    #end

    return this;
  }

  public function find(elt:View->Bool):Null<View> {
    return Lambda.find(views, elt);
  }

  public function has(elt:View->Bool):Bool {
    return Lambda.exists(views, elt);
  }

  public function exists(view:View):Bool {
    return Lambda.has(views, view);
  }

  public function iterator():Iterator<View> {
    return views.iterator();
  }

  public function mount(tag:String):RenderResult {
    #if sys
      render();
      return Template.html('<${tag} id="${cid}">${ @:safe content }</${tag}>');
    #else
      return Template.html('<${tag} id="${cid}"></${tag}>');
    #end
  }

  public function toRenderResult():RenderResult {
    return mount('div');
  }

  #if js

    public function render() {
      attach(views, {
        ready: inDom(),
        reset: true
      });
      rendered = true;
      return this;
    }

    public function removeAll() {
      if (parent != null) {
        parent.remove(view, { silent: true });
      }
      for (view in views) {
        view.remove();
      }
      views = [];
    }

    public function detach() {
      for (view in views) {
        if (view.el.parentElement != null) {
          view.el.parentElement.removeChild(view.el);
        }
      }
      return this;
    }

    private function attach(views:Array<View>, options:{
      ready:Bool,
      ?reset:Bool
    }) {
      var el = getEl();
      if (el == null) return;
      if (options.reset == null) options.reset = false;

      var managers = views.map(function (v) return v.children);
      for (manager in managers) if (!manager.rendered) {
        manager.view.render();
        manager.rendered = true;
      }

      if (options.reset) {
        el.innerHTML = '';
      }

      for (view in views) {
        el.appendChild(view.el);
      }

      for (manager in managers) {
        manager.attached = true;
        if (options.ready) {
          manager.ready();
        }
      }
    }

    // Only use this method if you know what you're doing!
    //
    // For performance reasons, this method does not check if the view is
    // actually attached to the DOM. It's taking your word for it.
    //
    // Fires the ready event on the current view and all attached subviews.  
    public function ready() {
      view.onReady.dispatch(view);
      for (view in views) {
        if (view.children.attached) {
          view.children.ready();
        }
      }
    }

    private function getEl() {
      return view.el.querySelector('#' + cid);
    }

    private function inDom() {
      var node = view.el;
      while(node != null) {
        if (node == js.Browser.document.body) {
          return true;
        }
        node = node.parentElement;
      }
      return false;
    }

  #else

    public function render() {
      var out = [];
      attach(views, { replace: true });
      rendered = true;
      return this;
    }

    private function attach(views:Array<View>, options:{ replace:Bool }) {
      var managers = views.map(function (v) return v.children);
      for (manager in managers) if (!manager.rendered) {
        manager.view.render();
        manager.rendered = true;
      }

      var result = views.map(function (v) return v.content).join('');
      if (options.replace) {
        content = result;
      } else {
        content += result;
      }

      for (manager in managers) {
        manager.attached = true;
        // if (options.ready) {
        //   manager.ready();
        // }
      }
    }

  #end

}