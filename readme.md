Scout
=====

Scout is a simple framework for Haxe that works something
like Backbone. Its biggest benefit is that it's designed
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

  // Observe states. Works the same as on Views.
  @:observe(states.greeting)
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

  // The `tag` attribute will set the HTML element
  // this view will be wrapped in.
  @:attr var tag:String = 'section'; 

  // `className` will be used as the element's `class`
  // attribute.
  @:attr var className:String = 'example'; 

  // To render an attribute in the view's tag, 
  // add `tag` as a meta param (`className` does not
  // require this).
  @:attr(tag) var id:String = 'Foo';

  // If you need to name the tag something that
  // Haxe can't handle, you can also give it 
  // an alias
  @:attr(tag = 'data-foo') var dataFoo:String = 'foo';

  // Watch for changes and re-render when needed.
  @:observe(model.states.greeting)
  @:observe(model.states.location)
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

    // Only works for JS targets for now -- not sure
    // how to best handle SYS targets yet.
    Scout.mount('#Root', view);
  }

}

```
