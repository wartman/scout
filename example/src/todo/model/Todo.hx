package todo.model;

import scout.Model;

class Todo implements Model {
  @:prop var label:String;
  @:prop var completed:Bool = false;
  @:prop var editing:Bool = false;
}
