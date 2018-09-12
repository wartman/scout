package todo.view;

import Scout;

class App extends View {

  public function template() return Scout.html('
    <section class="todoapp">
      ${children}
    </section>
    
    <footer class="info">
      <p>Double-click to edit a todo.</p>
      <p>Written by <a href="https://github.com/wartman">wartman</a></p>
      <p>Part of <a href="http://todomvc.com">TodoMVC</a></p>
    </footer>
  ');

}
