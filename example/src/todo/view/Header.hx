package todo.view;

import scout.View;
import todo.model.Store;
import todo.model.Todo;

@:el(
  tag = 'header',
  className = 'header'
)
class Header extends View {

  @:attr var title:String;
  @:attr var store:Store;

  @:on('keydown', '.new-todo')
  public function handleSubmit(e:js.html.Event) {
    if (cast(e, js.html.KeyboardEvent).key == 'Enter') {
      e.preventDefault();
      var target:js.html.InputElement = cast e.target;
      store.todos.add(new Todo({
        label: target.value
      }));
      target.value = '';
    }
  }

  public function render() '
    <h1>${title}</h1>
    <input class="new-todo" placeholder="What needs doing?" />
  ';

}