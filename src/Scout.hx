typedef View = scout.View;
typedef Model = scout.Model;
typedef ModelCollection<T:Model> = scout.ModelCollection<T>; 
typedef Template = scout.Template;
typedef Element = scout.Element;
typedef Child<T:View> = scout.Child<T>;
typedef RenderResult = scout.RenderResult;
#if js
  typedef Dom = scout.Dom;
#end

class Scout {

  macro public static function html(e:ExprOf<String>)
    return scout.Template.escape(e);

  #if js
    public static function mount(sel:String, view:View) {
      Dom.select(sel).appendChild(view.render().el);
    }
  #end

}
