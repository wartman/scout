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
}

class ExampleView extends View {

  @:attr var model:ExampleModel;

  // Watch for changes and re-render when needed.
  @:onSignal(model.signals.greeting)
  @:onSignal(model.signals.location)
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
      Sys.print('<div id="Root"$>{ view.render().content }</div>');
      // Although this part is not really ready yet.
    #end
  }

}

```