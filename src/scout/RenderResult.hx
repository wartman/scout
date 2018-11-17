package scout;

@:forward
abstract RenderResult(String) from String to String {

  public function new(str) this = str;

  @:from public static function ofRenderable(renderable:Renderable)
    return renderable.toRenderResult();

}
