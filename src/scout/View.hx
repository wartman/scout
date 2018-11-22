package scout;

#if (js && !nodejs)
  import js.html.Element;

  typedef ViewEvent = {
    selector:String,
    action:String,
    method:js.html.Event -> Void
  };
#end

#if (js && !nodejs)
  @:autoBuild(scout.macro.ViewBuilder.buildJs())
#else
  @:autoBuild(scout.macro.ViewBuilder.buildSys())
#end
class View implements Renderable implements Mountable {

  static var autoIdIndex:Int = 0;

  #if (js && !nodejs)
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
    public var content(get, set):String;
    public function get_content() return el.outerHTML;
    public function set_content(content:String) return el.innerHTML = content;
    var events:Array<ViewEvent> = [];
    var delegatedEvents:Array<Dom.EventBinding> = [];
  #else
    public var content:String;
  #end

  public var isReady(get, never):Bool;
  public inline function get_isReady():Bool {
    #if (js && !nodejs)
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
  #if (js && !nodejs)
    var parentListeners:Array<Signal.SignalSlot<View>> = [];
  #end

  public function __scout_render() return Template.html('');

  public function __scout_doRender():Void {
    content = __scout_render();
  }

  public function shouldRender():Bool {
    return true;
  }

  public function render() {
    if (shouldRender()) {
      beforeRender.dispatch(this);
      __scout_doRender();
      afterRender.dispatch(this);
    }
    return this;
  }

  public function setParent(view:View) {
    detachFromParent();
    parent = view;
    #if (js && !nodejs)
      parentListeners = [
        parent.onRemove.add(function (_) remove()),
        parent.beforeRender.add(function (_) detach()),
        parent.afterRender.add(function (_) attach())
      ];
    #end
  }

  public function detachFromParent() {
    #if (js && !nodejs)
      for (listener in parentListeners) listener.remove();
      parentListeners = [];
      detach();
    #end
    parent = null;
  }

  #if (js && !nodejs)

    public function toRenderResult():RenderResult {
      if (parent != null) {
        // return new scout.Element(tag, { id: cid }, []).toRenderResult();
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
      return render().content;
    }

  #end

}
