package todo.view;

import Scout;
import todo.model.Store;
import todo.model.Todo;

class TodoList extends View {

  @:attr var className:String = 'todo-list-wrapper';
  @:attr var store:Store;

  @:init
  private function initializeViews() {
    for (todo in store.todos) {
      addTodo(todo);
    }
  }

  @:observe(store.todos.onAdd)
  public function addTodo(todo:Todo) {
    addView(new TodoItem({ 
      sel: '#Todo-${todo.id}',
      id: 'Todo-${todo.id}',
      todo: todo, 
      store: store 
    }));
  }

  @:observe(store.todos.onRemove)
  public function removeTodo(todo:Todo) {
    var view = children.find(function (view) return cast(view, TodoItem).todo == todo);
    removeView(view);
  }

  @:js
  @:observe(store.signals.todosRemaining)
  private function updateCount(remaining:Int) {
    var count = el.querySelector('.todo-count');
    if (count == null) return;
    count.innerHTML = remaining + ' Remaining';
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

  public function template() return Scout.html('
    ${children.mount("ul", { className: "todo-list" })}

    <footer class="footer">
      <span class="todo-count">${store.todosRemaining} Remaining</span>

      <ul class="filters">
        <li><a href="#all" class="filter-all">All</a></li>
        <li><a href="#completed" class="filter-completed">Completed</a></li>
        <li><a href="#pending" class="filter-pending">Pending</a></li>
      </ul>
    </footer>
  ');

}
