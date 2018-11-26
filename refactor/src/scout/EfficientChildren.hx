package scout;

@:el(
  tag = tag,
  className = className
)
class EfficientChildren<T:View> extends View {

  @:attr var tag:String = 'ul';
  @:attr var className:String = '';
  @:attr var children:Array<T>;

  public var length(get, null):Int;
  public function get_length() return children.length;

  public function add(child:T) {
    children.push(child);
    #if (js && !nodejs)
      el.appendChild(child.render().el);
    #end
  }

  public function prepend(child:T) {
    children.unshift(child);
    #if (js && !nodejs)
      if (children.length > 0) {
        el.insertBefore(child.render().el, el.firstChild);
      } else {
        el.appendChild(child.render().el);
      }
    #end
  }

  public function findChild(cb:(child:T)->Bool):Null<T> {
    return Lambda.find(children, cb);
  }

  public function getChildAt(index:Int):Null<T> {
    return children[index];
  }

  public function removeChild(child:T) {
    #if js
      var c = findChild(c -> c == child);
      if (c != null) c.remove();
    #end
    children.remove(child);
  }

  #if (sys || nodejs)
    public function render() '${children}';
  #end

}
