package scout;

interface Mountable {
  public function detachFromParent():Void;
  public function setParent(parent:View):Void;
}
