package scout;

interface Child extends Renderable {
  public function setParent(parent:Child):Void;
  public function detachFromParent():Void;
  #if js
    public function detach():Void;
    public function attach():Void;
  #end
}
