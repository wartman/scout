package todo.view;

import Scout;
import todo.model.Todo;
import todo.model.Store;

class TodoItem extends View {

  @:attr var className:String = 'todo-item';
  @:attr var tag:String = 'li';
  @:attr var todo:Todo;
  @:attr var store:Store;
  
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
  }

  @:on('click', '.destroy')
  public function removeTodo(e) {
    e.preventDefault();
    store.todos.remove(todo);
  }

  @:observe(todo.signals.editing)
  public function toggleEditMode(_) {
    if (todo.editing) {
      el.classList.add('editing');
      el.querySelector('.edit').focus();
    } else {
      el.classList.remove('editing');
    }
  }

  @:observe(store.signals.visible)
  @:observe(todo.signals.completed)
  public function isVisible(_:Dynamic) {
    switch (store.visible) {
      case VisibleAll: show();
      case VisibleCompleted: todo.completed ? show() : hide();
      case VisiblePending: todo.completed ? hide() : show();
    }
  }

  public function show() {
    el.setAttribute('style', 'display:block;');
  }

  public function hide() {
    el.setAttribute('style', 'display:none;');
  }

  public function template() return Scout.html('
    <input class="edit" type="text" value="${todo.label}" />
    <div class="view">
      <input class="toggle" type="checkbox"${ todo.completed ? " checked" : "" } />
      <label>${todo.label}</label>
      <button class="destroy"></button>
    </div>
  ');

}
