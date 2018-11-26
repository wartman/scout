package scout;

interface Child extends Renderable {
  public function setParent(parent:Child):Void;
  public function detachFromParent():Void;
}
