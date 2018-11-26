package todo.view;

import scout.View;
import todo.model.Store;

@:el(sel = sel, id = id)
class App extends View {

  @:attr var sel:String;
  @:attr var title:String;
  @:attr var store:Store;
  @:attr var id:String = 'App';
  @:attr var header:Header = new Header({
    title: title,
    store: store
  });
  @:attr var list:TodoList = new TodoList({
    store: store,
    body: []
  });

  public function render() '
    <div class="todoapp">
      ${header}
      ${list}
    </div>
    <footer class="info">
      <p>Double-click to edit a todo.</p>
      <p>Written by <a href="https://github.com/wartman">wartman</a></p>
      <p>Part of <a href="http://todomvc.com">TodoMVC</a></p>
    </footer>
  ';

}
