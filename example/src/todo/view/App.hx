package todo.view;

import Scout;
import todo.model.Store;

class App extends View {

  @:attr var title:String;
  @:attr var store:Store;
  @:attr(tag) var id:String = 'App';
  @:attr(child) var header:Header = new Header({
    title: title,
    store: store
  });
  @:attr(child) var list:TodoList = new TodoList({
    store: store
  });

  public function render() return Scout.html('
    ${header}
    ${list}
    <footer class="info">
      <p>Double-click to edit a todo.</p>
      <p>Written by <a href="https://github.com/wartman">wartman</a></p>
      <p>Part of <a href="http://todomvc.com">TodoMVC</a></p>
    </footer>
  ');

}
