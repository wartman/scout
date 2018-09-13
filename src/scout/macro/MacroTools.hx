package scout.macro;

import haxe.macro.Expr;

class MacroTools {

  public static function extractMeta(meta:Metadata, names:Array<String>) {
    return meta.filter(function (m) return Lambda.has(names, m.name));
  }

  public static function hasMeta(meta:Metadata, names:Array<String>) {
    return Lambda.exists(meta, function (m) return Lambda.has(names, m.name));
  }

}
