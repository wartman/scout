package todo.view;

import Scout;
import scout.component.ListView;
import todo.model.Store;
import todo.model.Todo;

using Lambda;

class TodoList extends View {

  @:attr var className:String = 'todo-list-wrapper';
  @:attr var store:Store;
  @:attr(child) var body:ListView<TodoItem> = new ListView({ className: 'todo-list' });

  @:init
  private function initializeViews() {
    for (todo in store.todos) {
      addTodo(todo);
    }
  }

  @:observe(store.todos.onAdd)
  public function addTodo(todo:Todo) {
    body.add(new TodoItem({ 
      sel: '#Todo-${todo.id}',
      id: 'Todo-${todo.id}',
      todo: todo, 
      store: store 
    }));
  }

  @:observe(store.todos.onRemove)
  public function removeTodo(todo:Todo) {
    var view = body.items.find(function (view) return view.todo == todo);
    if (view != null) body.delete(view);
  }

  @:js
  @:observe(store.states.todosRemaining)
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

  public function render() return Scout.html('
    ${body}

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
