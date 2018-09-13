typedef View = scout.View;
typedef Model = scout.Model;
typedef ModelCollection<T:Model> = scout.ModelCollection<T>; 
typedef Template = scout.Template;
typedef Element = scout.Element;
#if js
  typedef Dom = scout.Dom;
#end

class Scout {

  macro public static function html(e:ExprOf<String>)
    return scout.Template.escape(e);

  public static function mount(sel:String, view:View) {
    #if sys
      var options:Dynamic = {};
      if (StringTools.startsWith(sel, '#')) {
        options.id = sel.substring(1);
      } else if (StringTools.startsWith(sel, '.')) {
        options.className = sel.substring(1);
      }
      Sys.print(
        new Element('div', options, [
          Template.safe(view.render().content)
        ]).render()
      );
    #else
      Dom.select(sel).appendChild(view.render().el);
    #end
  }

}
