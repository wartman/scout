package scout;

#if macro
  import haxe.macro.Expr;
  import haxe.macro.Context;

  using haxe.macro.Tools;
  using haxe.macro.MacroStringTools;
#end

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
          return macro @:pos(data.pos) new scout.RenderResult(${out});
        default:
      }
      return macro @:pos(data.pos) new scout.RenderResult(${data});
    }

    private static function handle(expr:Expr):Expr {
      var type = Context.typeof(expr).follow();
      var renderable = Context.getType('scout.Renderable');
      if (Context.unify(type, renderable)) {
        return macro @:pos(expr.pos) ${expr}.toRenderResult();
      }

      switch (type) {
        case TAbstract(t, _):
          if (t.toString() == 'scout.RenderResult') return expr;
        case TInst(t, params):
          if (t.toString() == 'Array') {
            var param = params[0].follow();
            if (param.toString() == 'scout.RenderResult') 
              return macro @:pos(expr.pos) new scout.RenderResult(${expr}.join(''));
            else if (Context.unify(param, renderable) && !(param.toString() == 'Dynamic'))
              return macro @:pos(expr.pos) ${expr}.map(function (r) return r.toRenderResult()).join('');
            else
              return macro @:pos(expr.pos) ${expr}.map(function (s) { 
                if (Std.is(s, scout.Renderable)) {
                  return cast(s, scout.Renderable).toRenderResult();
                } else {
                  return StringTools.htmlEscape(Std.string(s));
                }
              }).join('');
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
