package scout;

#if js
  import js.html.Element;
#end

class ViewCollection {

  private static var ids:Int = 0;

  public var view(default, null):View;
  public var parent:ViewCollection = null;
  public var cid(default, null):String = '__scout_' + ids++;
  public var rendered:Bool = false;
  public var attached:Bool = false;
  private var views:Array<View> = [];
  private var onReady:Signal<ViewCollection> = new Signal();

  #if sys
    public var content(default, null):String = '';
  #end

  public function new(view:View) {
    this.view = view;

    #if js
      this.view.onRemove.add(function (_) removeAll());
      this.view.beforeRender.add(function (_) detach());
      this.view.afterRender.add(function (_) render());
    #end
  }

  public function add(view:View, ?options:{ ?silent:Bool, ?replace:Bool }) {
    if (options == null) {
      options = { silent: false, replace: false };
    }

    views.push(view);
    view.children.parent = this;
    
    #if js
      if (!options.silent) {
        attach([ view ], {
          ready: inDom(),
          replace: options.replace
        });
      }
    #end
    
    return this;
  }

  public function remove(view:View, ?options:{ silent:Bool }) {
    if (options == null) {
      options = { silent: false };
    }

    var index = views.indexOf(view);
    if (index > -1) views = views.splice(index, 1);

    #if js
      if (!options.silent) {
        view.remove();
      }
    #end

    return this;
  }

  #if js

    public function render() {
      attach(views, {
        ready: inDom(),
        replace: true
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

    public function replace(els:Array<Element>) {
      var el = view.el.querySelector('#' + cid);
      el.innerHTML = '';
      for (e in els) {
        el.appendChild(e);
      }
    }

    public function append(els:Array<Element>) {
      var el = view.el.querySelector('#' + cid);
      for (e in els) {
        el.appendChild(e);
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

    private function attach(views:Array<View>, options:{
      replace:Bool,
      ready:Bool
    }) {
      var el = getEl();
      if (el == null) return;

      var managers = views.map(function (v) return v.children);
      for (manager in managers) if (!manager.rendered) {
        manager.view.render();
        manager.rendered = true;
      }

      var els = views.map(function (v) return v.el);
      if (options.replace) {
        this.replace(els);
      } else {
        this.append(els);
      }

      for (manager in managers) {
        manager.attached = true;
        if (options.ready) {
          manager.ready();
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

    public function toRenderResult() {
      return Template.html('<div id="${cid}"></div>');
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

    public function toRenderResult() {
      render();
      return Template.html('<div id="${cid}">${ @:safe content }</div>');
    }

  #end

}