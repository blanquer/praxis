---
title: Building CRUD
sidebar_label:  Building CRUD
---

The way that people build CRUD operations often varies more than the read-only `index` and `show` type ones. However, Praxis still brings in some best practices (and helper tools) you can decide to follow. You can always design your API actions and implement your controller code however you see fit otherwise. That's one of the main goals of Praxis: at the core, practice provides a solid Web API routing/parameter/controller Rack-based framework you can directly use (i.e., a la Sinatra), but you can easily opt in to all other extensions and practices as you want (and you can even do it on a controller by controller basis etc.)

But anyway, we were talking about implementing the CRUD operations weren't we? Let's go through it one by one `Create`, `Update` and `Delete`.

## Create

Like always, to start building a new action we turn to its API design first.

### Designing Create

The first thing to notice is the design choices that the scaffold generator did for us in the endpoint.
Specifically, if you look at the action definition for `posts` you'll see this:

```ruby
  action :create do
    description 'Create a new Post'
    routing { post '' }
    payload reference: MediaTypes::Post do
      # List the attributes you accept from the one existing in the Post Mediatype
      # and/or fully define any other ones you allow at creation time
      # attribute :name
    end
    response :created
    response :bad_request
  end
```
Which means, creation is gonna be done by a `POST` verb to the collection url (`/posts`), and expecting a `204 Created` response (with a Location header of the href for the created resource), or a `400 Bad Request` if the request couldn't be completed (which included information as to why not).

If we're good with this fairly standard practice, the only thing that this need to be completed is to define what payload attributes we want to accept to create a `Post`. The Praxis best practices suggest to accept a payload structure that mimics the `Post` mediatype (i.e., trying to have INPUTS == OUTPUTS as much as possible). If we follow that, it probably means that we want to accept a payload that has a `title`, a `contents` and an `author`. So, in the more pure Praxis style, here's how the payload would be designed:

```ruby
  payload reference: MediaTypes::Post do
    attribute :title
    attribute :content
    attribute :author do
      attribute :id, required: true
    end
    requires.at_least(1).of :title, :content
    requires.all :author 
  end
```

Now, let's take a look at a couple of this on this definition. 

The first one is that we didn't define types for any of the attributes. What's that all about? Well, the answer lies on the `reference: MediaTypes::Post` option. When a payload is given a `reference` MediaType, attributes defined that match that MediaType will inherit (i.e., copy paste) all of their types and options from it. Again a best practice that can reward you in terseness and avoid mistakes when you follow the (INPUTS==OUTPUTS paradigm). Any extra payload attribute that we might need, which does not exist in the MediaType can be define normally, with its Type an options. In fact, it is possible to also redefine the type and options even if the reference MediaType has it (that sounds like a bad practice, though, as it's not intuitive to the client)

The second thing to notice is how we've defined the way to specify the author of the post. Often times you see a payload having an `author_id` attribute, but following the (INPUTS==OUTPUTS paradigm) we need to change that to have an `author` struct, with only an `id` accepted inside. In the same fashion we can trivially start accepting other author information like `email` or `uuid` (even optionally within the `author` struct) to connect the `Post` to it. It's all about the consistency and the principle of least surprise to your users of the API.

Finally, just more for demonstration purposes than anything else, we have decided that we can accept a post without a `title` or without a `content`, but we need at least one of them. The `author` however is always required (and evidently its `id`).

So, now the Create API is designed, and Praxis will take 1) route that request to the `create` method in the `Posts` version 1 controller, and 2) to take full care to always parse and validate all the incoming parameters and respond with a failure 400 code (and an appropriate message as to why) to the client, if something does not match the spec.

In the case all checks out, our `create` code in the `Posts` controller will be invoked, and we can make sure that all of the method params and incoming request payload have properly been parsed and coerced to the our type spec. This means we never shall do any of those validations on our code, Praxis will never invoke the action method unless all of them pass.

### Implementating Create

So let's now focus our efforts on building the implementation of creating a `Post` based on the incoming payload. To do so, let's take a look at the scaffolded code for the `create` action that our generator built for us:

```ruby
      # Creates a new Post
      def create
        # A good pattern is to call the same name method on the corresponding resource, 
        # passing the incoming payload, or massaging it first
        created_resource = Resources::Post.create(request.payload)

        # Respond with a created if it successfully finished
        Praxis::Responses::Created.new(location: created_resource.href)
      end
```

Simplicity is, again, the key to Praxis' best practices. In particular we would like our controller code to only have to deal with HTTP concepts and transformations (requests and response params, payload, headers, http codes and errors...etc) and not on any business logic. There are many reasons for this but the most important ones have to do with separation of concerns, testability and Business logic reuse.

So with that in mind, what Praxis proposes us with this approach is to simply call the business logic to create a `Post`, using the same action name (i.e., `create`) and passing all of the necessary parameters (possibly massaged), and then simply return the `201 Created` response with the appropriate Location header containing the href of the created resource.

The concept of "Resources" play an important role in all this. They should be the associated objects that sit in between the Controllers and the Data access, which contain the important business logic. In other words: at the top level Controllers simply deal with HTTP in and out concerns, at the lowest level Models deal only with retrieving and saving data from or to the DB. Resources are reusable components of business logic that sit on top and abstract the underlying related model (or other related resources).

With that in mind, we're done with our controller! Let's build the actual business logic shall we? 

To do so, let's turn to our scaffolded `Post` resource in `app/v1/resources/post.rb`. As you can see, for now there is no extra logic other than actuall creating a row in the DB and return an instance of the resource that wraps it:

```ruby
  def self.create(payload)
    # Assuming the API field names directly map the the model attributes. Massage if appropriate.
    self.new(model.create(*payload.to_h))
  end
```

This scaffolded code assumes that the payload attributes of the API have the same name as the model attributes. Obviously, that's certainly not the case in all situations, so the resource might need to massage and transform them appropriately before calling the ORM's create. In our case, though, the scaffolded code is correct, and nothing needs to be changes. Yay!

Next up is how to build the update action for our `Posts`.

## Update

The `update` action has many similarities with the `create` action, so we'll move along much faster. Let's design the endpoint first.

### Designing Update

For that, let's take a look at the scaffolded code from our generator:

```ruby
  action :update do
    description 'Update one or more attributes of an existing Post'
    routing { patch '/:id' }
    params do
      attribute :id, required: true
    end
    payload reference: MediaTypes::Post do
      # List the attributes you accept from the one existing in the Post Mediatype
      # and/or fully define any other ones you allow to change
      # attribute :name
    end
    response :no_content
    response :bad_request
  end
```

This defines that an update is gonna be done through a `PATCH` verb to the member url of the posts collection (`/posts/:id`), where `:id` is the given identifier of the post to update. As a response, the client must expect a `204 No Content` when successful update, or a `400 Bad Request` if the request couldn't be completed (which included information as to why not).

Notice that query-string parameters are defined separately from body parameters. Query string parameters are defined in the `params` block, while the body structure is defined in the `payload` block. In this case we're defining the payload again as an incoming hash-type structure, but know that it can be designed to accept arrays, and/or complex multipart bodies, etc.

The only thing that we need to change from the scaffold is the attributes we want the client to update. It feels right to allow all of the direct attributes to be updatable, but perhaps not the author, as that's something we might want to keep immutable. So if we want to go this way, we can simply define it as:

```ruby
  payload reference: MediaTypes::Post do
    attribute :title
    attribute :content
  end
```

Note that no attribute is really required. That is because this `update` action (through the `PATCH` HTTP verb) only changes the attributes that are passed in, and leaves the rest untouched. If you wanted an update-type action that can change a member of the collection fully, we recommend using a `PUT` verb to the same member url, and call it something like `replace` so it clearly denotes that it will replace all values of the object.

So all in all, we only needed to add a couple of attributes to the payload. Good times. Let's move to the implementation.

### Implementing Update

This is the scaffolded code we find for `update` in the controller:

```ruby
  def update(id:)
    # A good pattern is to call the same name method on the corresponding resource, 
    # passing the incoming id and payload (or massaging it first)
    updated_resource = Resources::Post.update(
      id: id,
      payload: request.payload,
    )
    return Praxis::Responses::NotFound.new unless updated_resource

    Praxis::Responses::NoContent.new
  end
```

The first thing to notice is that the parameter (i.e., query-string parameter) is passed in neatly as a keyword argument to the function. It is also accessible through `request.params` but it is much cleaner and self-documenting to be a function argument.

The body of the function follows the same patter as create. It calls the same-name class method of the related resource, and gives it the necessary information to perform the job. In addition, it also returns a `404 Not Found` if the update call yield no resource, but otherwise it will return a `204 No Content` to indicate success. Some APIs like to return a `200 OK` with the resulting body of the updated resource. While this is perfectly fine and valid we believe it is much cleaner (and cheaper) to just signal success and make the client request the latest copy in a subsequent request, where it can clearly specify which of the fields (including nested resources) he wants. If we had to return the updated object in an update call, we'd either have to choose what fields to return, or somehow accept a `fields` parameter to know what to render. All are perfectly acceptable options, it's more a matter of preference.

Ok, so nothing for us to change here either, so let's finally look at this `update` method of the resource, where seemingly the business logic lives at:

```ruby
  def self.update(id:, payload:)
  record = model.find_by(id: id)
  return nil unless record
  # Assuming the API field names directly map the the model attributes. Massage if appropriate.
  record.update(*payload.to_h)
  self.new(record)
end
```

Well, it doesn't seem that we need to change anything here either since the API attributes have the same name as the ORM model. This scaffolded code is responsible from loading the model by `id` from the DB and return `nil` to signal it didn't find it. If found, it simply updates the model attributes with the received values and returns the updated record wrapped in a resource instance. Done.

And finally, let's look at the `delete` action.
## Delete

The delete action is probably the easiest one, let's design it first.

### Designing Delete

From a design perspective, a delete is very similar to the `update`, except that it does not need any payload information, it only needs the `id` of the post to delete. Here's the scaffolded endpoint for delete:

```ruby
  action :delete do
    description 'Deletes a Post'
    routing { delete '/:id' }
    params do
      attribute :id, required: true
    end
    response :no_content
    response :not_found
  end
```

It all looks exactly how we want it. This defines that a delete is gonna be done through a `DELETE` verb to the member url of the posts collection (`/posts/:id`), where `:id` is the given identifier of the post. As a response, the client must expect a `204 No Content` when successful update, or a `400 Bad Request` if the request couldn't be completed (which included information as to why not).

Ok then, nothing to be added...moving along to the implementation.

### Implementing Delete

Looking at the Controller implementation for delete also reveals a structure almost identical to `update`:

```ruby
  def delete(id:)
    # A good pattern is to call the same name method on the corresponding resource,
    # maybe passing the already loaded model
    deleted_resource = Resources::Post.delete(
      id: id
    )
    return Praxis::Responses::NotFound.new unless deleted_resource

    Praxis::Responses::NoContent.new
  end
```

In fact, it is exactly the same code but calling the `delete` method of the resource, which obviously does not need a payload. Good, nothing to do here either. How about the `delete` method where the business logic lives?

```ruby
  def self.delete(id:)
    record = model.find_by(id: id)
    return nil unless record
    record.destroy
    self.new(record)
  end
```

Well, nothing to be done here either as it simply loads and destroys the model, or returns nil if it couldn't find it. Nice job scaffolder!

# Summary of sorts??

So, just like that, we have build a full-on read plus CRUD API for Posts, by literally just pasting a few lines of code (really just to define media type structures and payload attributes). We can see how it all works by starting the server `bundle exec rackup` and launching a few `curl` requests at it. For example:

```shell
TODO things for Create, Update and Delete...
```