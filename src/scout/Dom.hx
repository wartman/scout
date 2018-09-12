package scout;

import js.html.Element;
import js.html.Event;

typedef EventBinding = { destroy:Void->Void };

class Dom {

  private static var docNodeType:Int = 9;

  public static function delegate(el:Element, selector:Null<String>, type:String, cb:Event->Void, ?useCapture:Bool):EventBinding {
    function listener (e:Event) {
      var del = closest(cast e.target, selector);
      if (del != null) cb(e);
    }

    if (selector == null) {
      listener = cb;
    }
    
    el.addEventListener(type, listener, useCapture);
    
    return {
      destroy: function() {
        el.removeEventListener(type, listener, useCapture);
      }
    }
  }

  public static inline function select(sel:String){
    return js.Browser.document.querySelector(sel);
  }

  public static inline function selectAll(sel:String){
    return js.Browser.document.querySelectorAll(sel);
  }

  public static function closest(el:Element, selector:String):Element {
    while (el != null && el.nodeType != docNodeType) {
      if (el.matches(selector)) return el;
      el = cast el.parentNode;
    }
    if (el.nodeType == docNodeType) return null;
    return el;
  }

  public static inline function html(el:Element, html:String):Element {
    el.innerHTML = html;
    return el;
  }

}
