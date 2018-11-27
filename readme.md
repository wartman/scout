Scout
=====

[![Build Status](https://travis-ci.com/wartman/scout.svg?branch=master)](https://travis-ci.com/wartman/scout)

Scout is a simple MVVC framework for Haxe that works something
like Backbone. Its biggest benefit is that it's designed
to work both on PHP and javascript using almost the
same code in both contexts.

Examples
--------

Check the [examples](/example) folder for a look at how this all works.

Signals
-------

Signals are at the core of Scout, although you probably will rarely
use them directly. Think of them as typed events. Here's an example:

```haxe
class SignalExamples {
  
  static final fooSignal:scout.Signal<String> = new scout.Signal();

  public static function main() {
    var foos:String = '';
    // Watch for changes. `add` also returns a scout.SignalSlot<T>, which
    // can be used to stop listening.
    var slot = fooSignal.add(foo -> foos ++ foo);
    
    // Dispatch the signal.
    fooSignal.dispatch('foo');
    trace(foos); // == "foo"

    // Remove the listener
    slot.remove();
    fooSignal.dispatch('foo');
    trace(foos); // == "foo" (no change)
  }

}
```

Built on top of `Signal` is `Observable`, which simply has an `observe(cb:(value:T)->Void)`
method that uses a signal internally, and `State`, which unifies with `Observable` and which
uses a `Signal` internally to keep track of changes in its bound value.

Models
------

Models are simple, reactive stores for your app's state. They look like this:

```haxe
class ExampleModel implements scout.Model {

  @:prop var greeting:String;
  @:prop var location:String;

  // Watch other props and compute a value when they change.
  @:computed(greeting, location) var fullGreeting = greeting + ' ' + location;

  // Observe props for changes.
  @:observe(greeting)
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
```

Every time a property changes in a model, it dispatches an `onChange` signal (unless
it happens in a `@:transition`). `Model` is an `Observable`, so you can track changes
using its `observe` method.  

Every var marked with `@:prop` is wrapped in a `scout.Property`. You can access these
properties directly with `Model#props`. Every `scout.Property` is an `Observable` as well,
so you can track changes on individual properties this way. For example:

```haxe
var model = new ExampleModel({ greeting: 'hello', location: 'space?' });
// watch all changes
model.observe(model -> trace(model));
// watch a single property
model.props.greeting.observe(greeting -> trace(greeting));
```

When using `@:observe` meta you can leave `props` off, like we did in the example
above, but this will ONLY work on props that belong to the model. 

Collections
-----------

Collections are recative, well, collections of models. Currently Scout can't handle arrays,
so Collections are the only way to properly manage groups of models. They're `Observable`,
and will dispatch a signal every time a model is added, removed or changed. `onAdd` and `onRemove`
signals are also available if you only want those.

(More will be added here soon)

Views
-----

Views are how you -- finally -- show stuff to people. They look like this:

```haxe
// `@:el` or `@:element` class meta describe the dom element that
// will be created for the view. You can put basically anything here
// and they will be used as attributes. The exceptions are `sel`,
// which will be used as a selector to try to find an existing element;
// `tag`, which will set the element tag; and `className`, which is 
// simply an alias for `class`.
@:el(
  sel, // Passing an identifier with no value will automatically create a
       // matching `attr` in the class.
  id = 'prefix' + cid, // Any expression is valid on the left hand side, so 
                       // long as it unifies with `String`.
                       // Note that `cid` is an automatic identifier provided
                       // by `scout.View`.
  className = 'my-name',
  "data-foo" = "bar" // You can quote names that would be invalid for Haxe if needed. 
)
class ExampleView extends scout.View {

  // Attrs can only be set in the constructor.
  @:attr var title:String;

  // `@:state` can be used if you want to have a reactive
  // property in your view. You should usually avoid this,
  // but it can make sense in some instances.
  //
  // Note that a view's state is internal to itself, unlike
  // with models.
  @:state var isVisible:Bool = true;

  @:attr var model:ExampleModel;
  @:attr var collection:Collection<ExampleModel>;

  // You can pass other views as attributes, like this:
  @:attr var header:ExampleHeaderView = new ExampleHeaderView({
    title: title // Scout ensures that views are initialized last, so `this.title`
                 // will be available here.
  });

  // ... and you can have many sub-views using `scout.Children`.
  @:attr var children:scout.Children<ExampleModelView>;

  // Here's a good example of how to use collections. We watch for new
  // models to get added, and update our `children` as needed. `scout.Children`
  // will re-render the parent view each time a new view is added,
  // so you might want to use `scout.EfficentChildren` (which has a
  // different strategy for adding sub-views) if you're going to be
  // updating the view a lot.
  @:observe(collection.onAdd)
  function addView(model:ExampleModel) {
    children.add(new ExampleModelView({
      model: model
    }));
  }

  // Actions can be bound like this, with `@:on` meta.
  // The first param is the kind of action you want, the
  // second is a selector.
  //
  // Note that you can omit the second param, which will
  // bind the action to this view's el.
  @:on('click', '[data-action="add-view"]')
  function doAddView(e) {
    e.preventDefault();
    addView(new ExampleModel({ greeting: 'Hey', location: 'this view' }));
  }

  // Rendering is done in the `render` method, which will automaically
  // be wrapped in `scout.Template.html` if the function body is just 
  // a `String` (with no return). `scout.Template.html` is a macro
  // function that will automatically escape strings, insert views,
  // and generally glue things together.
  //
  // Note that you just place child views directly into the template.
  public function render() '
    <button data-action="add-view">Add View</button>
    ${header}
    <ul class="children">
      ${children}
    </ul>
  ';

}
```

Constructing a view works much like it does with `scout.Model`:

```haxe
var view = new ExampleView({
  // `sel` is always optional, so we can skip it if we want, but
  // let's use it here.
  sel: '#Root',
  title: 'Foo',
  collection: new Collection([]),
  // scout.Children is an abstract, and can be cast from an array.
  // The same goes for scout.EfficientChildren.
  children: [
    new ExampleModelView({
      model: new ExampleModel({ greeting: 'What is up,', location: 'the world?' })
    })
  ]
});

// Assuming we didn't screw up and forget to add `#Root` to our HTML,
// calling `render` will render the view and set it's element's innerHTML.
// In `js` mode, anyway.
view.render();
```
