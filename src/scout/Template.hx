package scout;

#if macro
  import haxe.macro.Expr;
  import haxe.macro.Context;

  using haxe.macro.Tools;
  using haxe.macro.MacroStringTools;
#end

interface Renderable {
  public function toRenderResult():RenderResult;
}

@:forward
abstract RenderResult(String) from String to String {

  public function new(str) this = str;

  @:from public static function ofRenderable(renderable:Renderable)
    return renderable.toRenderResult();

}

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

  macro public static function html(e:ExprOf<String>)
    return escape(e);

  public static function safe(str:String)
    return new SafeContent(str);

  #if macro
  
    public static function escape(data:ExprOf<String>) {
      switch (data.expr) {
        case EConst(CString(s)):
          var expr = s.formatString(data.pos);
          var out = handle(expr);
          return macro @:pos(data.pos) new scout.Template.RenderResult(${out});
        default:
      }
      return macro @:pos(data.pos) new scout.Template.RenderResult(${data});
    }

    private static function handle(expr:Expr):Expr {
      switch (Context.typeof(expr)) {
        case TAbstract(t, _):
          if (t.toString() == 'scout.RenderResult') return expr;
        case TInst(t, params):
          if (t.toString() == 'Array') {
            if (params[0].toString() == 'scout.RenderResult') 
              return macro @:pos(expr.pos) new scout.Template.RenderResult(${expr}.join(''));
            else
              return macro @:pos(expr.pos) ${expr}.map(function (s) { 
                if (Std.is(s, scout.Template.Renderable)) {
                  return cast(s, scout.Template.Renderable).toRenderResult();
                } else {
                  return StringTools.htmlEscape(Std.string(s));
                }
              }).join('');
          }
          
          // Note: this may not be needed, but I'm keeping it here
          //       for the moment.
          if (t.toString() == 'scout.ViewCollection') {
            return macro @:pos(expr.pos) ${expr}.toRenderResult();
          }

          // Note: will need to make this more robust and check up
          //       the inheritance chain.
          if (t.toString() != 'String') {
            var interfaces = Context.getType(t.toString()).getClass().interfaces;
            for (i in interfaces) {
              if (i.t.toString() == 'scout.Renderable') {
                return macro @:pos(expr.pos) ${expr}.toRenderResult();
              }
            }
          }
        default:
      }
      switch (expr.expr) {
        case EBinop(OpAdd, e1, e2):
          return { expr: EBinop(OpAdd, handle(e1), handle(e2)), pos: expr.pos };
        case EConst(CString(_)) | EMeta({ name: ':safe' }, _):
          return expr;
        case EArrayDecl(exprs):
          var handled = exprs.map(handle);
          return macro @:pos(expr.pos) $a{handled}.join('');
        default: 
          return macro @:pos(expr.pos) StringTools.htmlEscape(Std.string(${expr}));
      }
    }

  #end

}
