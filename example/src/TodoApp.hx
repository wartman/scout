import todo.model.*;
import todo.view.App;

class TodoApp {

  public static function main() {
    var store = new Store({
      todos: new TodoCollection()
    });

    var app = new App({
      sel: '#Root',
      title: 'Todo',
      store: store
    });

    #if js
      app.render();
    #else
      Sys.print('
        <!DOCTYPE html>
        <html>
          <head>
            <title>ToDo</title>
            <link rel="stylesheet" href="assets/app.css">
          </head>
          <body>
            <div id="Root">${ app.render().content }</div>
            <script type="text/javascript" src="assets/app.js"></script>
          </body>
        </html>
      ');
    #end
  }

}
