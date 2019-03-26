package scout;

class NullChild implements Child {

  public function new() {}
  
  public function setParent(parent:Child):Void {
    // noop
  }

  public function detachFromParent():Void {
    // noop
  }

  public function toRenderResult():RenderResult {
    return '';
  }

}
