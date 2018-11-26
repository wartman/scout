package scout;

interface Child {
  public function setParent(parent:Child):Void;
  public function detachFromParent():Void;
  public function getAttachmentPoint():RenderResult;
  #if js
    public function detach():Void;
    public function attach():Void;
  #end
}
