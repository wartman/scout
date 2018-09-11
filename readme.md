Scout
=====

Scout is a simple framework for Haxe that works something
like Backbone. It's biggest benefit is that it's designed
to work both on PHP and javascript using almost the
same code in both contexts.

Example
-------

```haxe
import Scout;

class ExampleModel implements Model {

  @:prop var id:Int;
  @:prop var greeting:String;
  @:prop var location:String;

  // Watch other props and compute a value when they change.
  @:computed(greeting, location) var fullGreeting = greeting + ' ' + location;

  // Observe other signals. Works the same as on Views.
  @:observe(signals.greeting)
  public function traceGreeting(greeting:String) {
    trace(greeting);
  }

  // Change a number of properties at once without
  // dispatching signals for all of them. In this case, 
  // only one `onChange` signal will be dispatched instead of
  // two.
  @:transition
  public function changeGreeting(greeting:String, location:String) {
    this.greeting = greeting;
    this.location = location;
  }

}

class ExampleView extends View {

  @:attr var model:ExampleModel;

  // Watch for changes and re-render when needed.
  @:observe(model.signals.greeting)
  @:observe(model.signals.location)
  public function updateOnChange(_) {
    render();
  }

  // Bind DOM events to selectors.
  // Will simply be removed when compiling for PHP.
  @:on('click', '.click-me')
  public function handleButtonClick(e) {
    e.preventDefault();
    trace('clicked');
  }

  public function template() return Scout.html('
    <button class='click-me'>Clicky</button>
    <p>${model.greeting} ${model.location}</p>
  ');

}

class Main {

  public static function main() {
    var model = new ExampleModel({
      id: 0,
      greeting: 'Hello',
      location: 'World'
    });
    var view = new ExampleView({ 
      model: model
    });

    #if js
      Dom.select('#Root').appendChild(view.render().el);
    #else
      // Something like this:
      Sys.print('<div id="Root">${ view.render().content }</div>');
      // Although this part is not really ready yet.
    #end
  }

}

```