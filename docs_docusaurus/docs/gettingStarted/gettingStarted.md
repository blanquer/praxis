---
title: Design our API resources
sidebar_label: Design our API resources
---

Ok, so our goal was to build an API that contains `Posts` and embedded `Comments`. So let's first scaffold the design for them. To do so, the easiest way is to use the Praxis scaffold generator, so let's do that:

```shell
bundle exec praxis g posts --model
bundle exec praxis g comments --model
```

Each of these scaffold generation commands will create the design files (MediaType and Endpoint) that are necessary to specify the API actions and resource shapes we want to expose. By default the generator will create an `index`, `show` and all CRUD actions for each endpoin. This can be controlled by passing extra flags as well.

Since we didn't specify the `--no-implementation` the genarator above also has also created the corresponding implementation files that go with the given design (Controller and Resource). We commonly would want to generate the implementation side of the API after we're happy with the design, but for the sake of this guide we'll just generate them all at once. Also, since we know we're gonna use a DB, we also explicitly asked the generator to create the model file for us with `--model` (defaults to an ActiveRecord model, but Sequel is also supported)

So with all that scaffolding in place, it's time to put on our Design hat to fill in the API attributes that we want `Posts` and `Comments` to have. For now, let's assume that a Post simply has an `id` (Integer), a `title` (String), some `contents` (String) and an author (a `User`). So let's add these attributes into the Post MediaType so that it looks like:

```ruby
attributes do
  attribute :id, Integer
  attribute :title, String
  attribute :content, String  
  attribute :author, MediaTypes::User
end
```

Similarly, let's assume that beyond its `id`, we want a `Comment` to have some `contents` (String), a related `Post` and the `User` that wrote it. To achieve that we need our `Comment`'s attributes to look like this:

```ruby
attributes do
  attribute :id, Integer
  attribute :content, String
  attribute :post, MediaTypes::Post
  attribute :user, MediaTypes::User
end
```

To make those changes you can either edit the `post.rb` and `comment.rb` inside the `design/v1/media_types/` directory, or can copy paste this shell snippet to do exacly the same for you:

```shell
sed -i '' '/.*<INSERT MORE ATTRIBUTES HERE>.*/i \
  attribute :title, String \
  attribute :content, String \
  attribute :author, MediaTypes::User \
' design/v1/media_types/post.rb

sed -i '' '/.*<INSERT MORE ATTRIBUTES HERE>.*/i \
  attribute :content, String \
  attribute :post, MediaTypes::Post \
  attribute :user, MediaTypes::User \
' design/v1/media_types/comment.rb
```

At this point, we might feel this is a good starting point for our API. Do you want to see the full API documentation of what we just built? no problem, let's generate the OpenAPI docs and view them using ReDoc by:
 
 ```shell
bundle exec praxis docs browser
 ```

Nice huh? well, we might be feeling good about our design, but we need to actually implement something. Before we do so, we need to make sure we have a properly built DB and configure our models.


