package todo.view;

import scout.View;
import scout.EfficientChildren;
import todo.model.Store;
import todo.model.Todo;

@:el( sel, className = 'todo-list-wrapper' )
class TodoList extends View {

  @:attr var store:Store;
  @:attr var body:EfficientChildren<TodoItem> 
    = new EfficientChildren([ for (todo in store.todos) makeTodo(todo) ]);
    

  @:observe(store.todos.onAdd)
  public function addTodo(todo:Todo) {
    if (body.length == 0) render();
    body.prepend(makeTodo(todo));
  }

  function makeTodo(todo:Todo) {
    return new TodoItem({ 
      sel: '#Todo-${todo.id}',
      id: 'Todo-${todo.id}',
      todo: todo, 
      store: store 
    });
  }

  @:observe(store.todos.onRemove)
  public function removeTodo(todo:Todo) {
    var view = body.find(function (view) return view.todo == todo);
    if (view != null) body.remove(view);
    if (body.length == 0) render();
  }

  @:js
  @:observe(store.props.todosRemaining)
  private function updateCount(remaining:Int) {
    var count = el.querySelector('.todo-count');
    if (count == null) return;
    count.innerHTML = todoCount(remaining);
  }

  @:on('click', '.filter-all')
  public function filterAll(e:js.html.Event) {
    store.visible = VisibleAll;
  }

  @:on('click', '.filter-completed')
  public function filterCompleted(e:js.html.Event) {
    store.visible = VisibleCompleted;
  }

  @:on('click', '.filter-pending')
  public function filterPending(e:js.html.Event) {
    store.visible = VisiblePending;
  }

  public function render() '
    <ul class="todo-list">
      ${body}
    </ul>
    ${footer()}
  ';

  function footer() return if ( store.todos.length > 0 ) scout.Template.html('
    <footer class="footer">
      <span class="todo-count">${ todoCount(store.todosRemaining) }</span>
      <ul class="filters">
        <li><a href="#all" class="filter-all">All</a></li>
        <li><a href="#completed" class="filter-completed">Completed</a></li>
        <li><a href="#pending" class="filter-pending">Pending</a></li>
      </ul>
    </footer>  
  ') else scout.Template.html('');

  function todoCount(remaining:Int) return switch (remaining) { 
    case 0: scout.Template.html('No items left');
    case 1: scout.Template.html('1 item left');
    default: scout.Template.html('${remaining} items left');
  }

}
