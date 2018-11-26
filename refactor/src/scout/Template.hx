package scout;

private class SafeContent implements Renderable {

  private var content:String;

  public function new(content:String) {
    this.content = content;
  }

  public function toRenderResult():RenderResult {
    return cast content;
  }

}

class Template {

  macro public static function html(e:haxe.macro.Expr.ExprOf<String>) {
    return scout.macro.TemplateBuilder.escape(e);
  }

  public static function safe(str:String) {
    return new SafeContent(str);
  }

}