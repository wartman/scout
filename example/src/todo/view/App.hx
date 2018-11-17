package todo.view;

import Scout;
import scout.component.ChildrenView;

class App extends View {

  @:attr(tag) var id:String = 'App';
  @:attr var body:Array<View>;
  @:attr(child) var children:ChildrenView<View> = new ChildrenView({ 
    tag: 'section', 
    className: 'todo-app', 
    body: body
  });

  public function template() return Scout.html('
    ${children}
    
    <footer class="info">
      <p>Double-click to edit a todo.</p>
      <p>Written by <a href="https://github.com/wartman">wartman</a></p>
      <p>Part of <a href="http://todomvc.com">TodoMVC</a></p>
    </footer>
  ');

}
