typedef View = scout.View;
typedef Model = scout.Model;
typedef ModelCollection<T> = scout.ModelCollection<T>; 
typedef Template = scout.Template;
#if js
  typedef Dom = scout.Dom;
#end

class Scout {

  macro public static function html(e:ExprOf<String>)
    return scout.Template.escape(e);

}
