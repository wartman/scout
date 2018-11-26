package scout;

#if (js && !nodejs)
  import js.html.Element;

  typedef ViewEvent = {
    selector:String,
    action:String,
    method:(e:js.html.Event) -> Void
  };
#end

#if (js && !nodejs)
  @:autoBuild(scout.macro.ViewBuilder.buildJs())
#else
  @:autoBuild(scout.macro.ViewBuilder.buildSys())
#end
class View implements Renderable implements Child {
  
  static var __scout_ids:Int = 0;

  public final cid:String = '__scout_view_' + __scout_ids++;
  public final beforeRender:Signal<View> = new Signal();
  public final afterRender:Signal<View> = new Signal();
  public final onReady:Signal<View> = new Signal();
  public final onRemove:Signal<View> = new Signal();
  var parent:Child;
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
    var parentListeners:Array<Signal.SignalSlot<View>> = [];
    var events:Array<ViewEvent> = [];
    var delegatedEvents:Array<Dom.EventBinding> = [];
  #else
    public var content:String;
  #end

  function __scout_render() return Template.html('');

  function __scout_doRender():Void {
    content = __scout_render();
  }

  function shouldRender():Bool {
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

  public function setParent(parent:Child) {
    detachFromParent();
    this.parent = parent;
    #if (js && !nodejs)
      if (Std.is(this.parent, View)) {
        var view:View = cast this.parent; 
        parentListeners = [
          view.onRemove.add(function (_) remove()),
          view.beforeRender.add(function (_) detach()),
          view.afterRender.add(function (_) attach())
        ];
      }
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

  public function toRenderResult():RenderResult {
    #if (js && !nodejs)
      return Template.html('<div id="$cid"></div>');
    #else
      return render().content;
    #end
  }

  #if (js && !nodejs)
  
    public function detach() {
      if (el.parentElement != null) {
        el.parentElement.removeChild(el);
      }
    }
    
    public function attach() {
      if (parent == null) return;
      if (Std.is(this.parent, View)) {
        var view:View = cast this.parent; 
        var target = view.el.querySelector('#${cid}');
        if (target != null) {
          target.parentNode.replaceChild(render().el, target);
        }
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

  #end

}
