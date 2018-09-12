import todo.model.*;
import todo.view.*;

class TodoClient {

  public static function main() {
    var store = new Store({
      todos: new TodoCollection()
    });
    store.todos.add(new Todo({
      label: 'Hey world!'
    }));

    var app = new App({
      sel: '#Root'
    }, [
      new Header({ 
        title: 'Todo',
        store: store 
      }),
      new TodoList({
        store: store
      })
    ]);
    app.render();
  }

}
