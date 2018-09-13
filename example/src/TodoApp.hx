import Scout;
import todo.model.*;
import todo.view.*;

class TodoApp {

  public static function main() {
    var store = new Store({
      todos: new TodoCollection()
    });
    store.todos.add(new Todo({
      label: 'Hey world!'
    }));

    var app = new App({}, [
      new Header({ 
        title: 'Todo',
        store: store 
      }),
      new TodoList({
        store: store
      })
    ]);

    Scout.mount('#Root', app);
  }

}
