package todo.view;

import scout.View;
import todo.model.Todo;
import todo.model.Store;

@:el(
  sel = sel,
  tag = 'li',
  className = 'todo-item',
  id = id
)
class TodoItem extends View {

  @:attr @:optional var sel:String;
  @:attr var id:String;
  @:attr var todo:Todo;
  @:attr var store:Store;
  
  @:js
  @:init
  public function initializeVisibility() {
    isVisible(store.visible);
  }

  @:on('keydown', '.edit')
  public function doneEditing(e) {
    if (cast(e, js.html.KeyboardEvent).key == 'Enter') {
      e.preventDefault();
      update();
    }
  }

  @:on('blur', '.edit')
  public function bluredEdit(e) {
    update();
  }

  @:js
  public function update() {
    todo.label = cast(el.querySelector('.edit'), js.html.InputElement).value;
    todo.editing = false;
    render();
  }

  @:on('dblclick')
  public function edit(e) {
    todo.editing = true;
  }

  @:on('change', '.toggle')
  public function toggleCompleted(e) {
    e.stopPropagation();
    todo.completed = !todo.completed;
    if (todo.completed) {
      el.classList.add('completed');
    } else {
      el.classList.remove('completed');
    }
  }

  @:on('click', '.destroy')
  public function removeTodo(e) {
    e.preventDefault();
    store.todos.remove(todo);
  }

  @:js
  @:observe(todo.props.editing)
  public function toggleEditMode(_) {
    if (todo.editing) {
      el.classList.add('editing');
      el.querySelector('.edit').focus();
    } else {
      el.classList.remove('editing');
    }
  }

  @:js
  @:observe(store.props.visible)
  @:observe(todo.props.completed)
  public function isVisible(_:Dynamic) {
    switch (store.visible) {
      case VisibleAll: show();
      case VisibleCompleted: todo.completed ? show() : hide();
      case VisiblePending: todo.completed ? hide() : show();
    }
  }

  @:js
  public function show() {
    el.setAttribute('style', 'display:block;');
  }

  @:js
  public function hide() {
    el.setAttribute('style', 'display:none;');
  }

  public function render() '
    <input class="edit" type="text" value="${todo.label}" />
    <div class="view">
      <input class="toggle" type="checkbox"${ todo.completed ? " checked" : "" } />
      <label>${todo.label}</label>
      <button class="destroy"></button>
    </div>
  ';

}
