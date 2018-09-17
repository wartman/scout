package todo.model;

import scout.Model;

enum VisibleTodos {
  VisibleAll;
  VisibleCompleted;
  VisiblePending;
}

class Store implements Model {
  @:prop(auto) var id:Int;
  @:prop var todos:TodoCollection;
  @:prop(optional) var editing:Todo;  
  @:prop var visible:VisibleTodos = VisibleAll;
  @:computed(todos) var todosRemaining:Int = todos.filter(function (todo) return !todo.completed).length;
}
