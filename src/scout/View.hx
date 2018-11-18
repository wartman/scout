package scout;

#if js
  import js.html.Element;

  typedef ViewEvent = {
    selector:String,
    action:String,
    method:js.html.Event -> Void
  };
#end

#if js
  @:autoBuild(scout.macro.ViewBuilder.buildJs())
#else
  @:autoBuild(scout.macro.ViewBuilder.buildSys())
#end
class View implements Renderable {

  private static var autoIdIndex:Int = 0;

  #if js
    @:isVar public var el(default, set):Element;
    public function set_el(el:Element) {
      if (delegatedEvents.length > 0) {
        undelegateEvents();
      }
      this.el = el;
      if (events.length > 0) {
        delegateEvents(this.events);
      }
      return el;
    }
    public var content(get, null):String;
    public function get_content() return el.outerHTML;
    private var events:Array<ViewEvent> = [];
    private var delegatedEvents:Array<Dom.EventBinding> = [];
  #else
    public var content(default, null):String;
  #end

  public var isReady(get, never):Bool;
  public inline function get_isReady():Bool {
    #if js
      return js.Browser.document.contains(el);
    #else
      return true;
    #end
  }

  public var cid(default, null):String = '__scout_view_' + autoIdIndex++;
  public var beforeRender(default, null):Signal<View> = new Signal();
  public var afterRender(default, null):Signal<View> = new Signal();
  public var onReady(default, null):Signal<View> = new Signal();
  public var onRemove(default, null):Signal<View> = new Signal();
  var parent:View;
  #if js
    var parentListeners:Array<Signal.SignalSlot<View>> = [];
  #end

  public function __scout_render() return Template.html('');

  public function shouldRender():Bool {
    return true;
  }

  public function render() {
    if (shouldRender()) {
      beforeRender.dispatch(this);
      #if js
        el.innerHTML = __scout_render();
      #else
        content = generateHtml();
      #end
      afterRender.dispatch(this);
    }
    return this;
  }

  public function setParent(view:View) {
    parent = view;
    #if js
      for (listener in parentListeners) listener.remove();
      parentListeners = [
        parent.onRemove.add(function (_) remove()),
        parent.beforeRender.add(function (_) detach()),
        parent.afterRender.add(function (_) attach())
      ];
    #end
  }

  #if js

    public function toRenderResult():RenderResult {
      if (parent != null) {
        return Template.html('<div id="$cid"></div>');
      }
      return render().content;
    }

    public function attach() {
      if (parent == null) return;
      var target = parent.el.querySelector('#${cid}');
      if (target != null) {
        target.parentNode.replaceChild(render().el, target);
      }
    }

    public function detach() {
      if (el.parentElement != null) {
        el.parentElement.removeChild(el);
      }
    }

    public function remove() {
      onRemove.dispatch(this);
      undelegateEvents();
      el.remove();
    }

    public function delegateEvents(events:Array<ViewEvent>) {
      for (event in events) {
        var e = Dom.delegate(this.el, event.selector, event.action, event.method);
        delegatedEvents.push(e);
      }
    }

    public function undelegateEvents() {
      for (binding in delegatedEvents) {
        binding.destroy();
      }
      delegatedEvents = [];
    }

  #else

    public function toRenderResult():RenderResult {
      return generateHtml();
    }

    private function generateHtml() {
      return __scout_render();
    }

  #end

}
