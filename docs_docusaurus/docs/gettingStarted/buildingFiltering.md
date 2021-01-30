---
title: Building Attribute Filters
sidebar_label:  Building Filters
---

So to build filters with which to query elements inn the `index` action we need to do a couple of things:

 * Enable the `filters` parameter in the API endpoint, and specify which attributes we're allowed to filter by.
 * Tell Praxis how each of the API filters map into which resource properties.

So let's get started.

## Enable the filters parameter in the API

Luckily, since we've generated the endpoint using our Praxis generator, we already have a commented out example of the filters attribute. We can just uncomment those lines, and simply list the attributes we allow to filter by. So, for example, a `Post` MediaType has an `id`, `title`, `content` and an `author`, so for demonstration purposes we could allow you to filter by `title` (allowing wildcards), and by author's `email` or `id`. In these cases we'll only enable the `=` and `!=` operators, but there are many others that are supported. To do so, we need replace the already existing (commented out due to scaffolding) `filters` parameter in the `design/v1/endpoints/posts.rb` file to look exactly like this:

```ruby
    attribute :filters, Praxis::Types::FilteringParams.for(MediaTypes::Post) do
       filter 'title', using: ['=', '!='], fuzzy: true
       filter 'author.email', using: ['=', '!=']
       filter 'author.id', using: ['=', '!=']
    end
```

And now that the endpoint is ready to accept and validate that new parameter, we simply need to inform the associated Resource object about how to map this API-level attribute names into ORM-level models and associations. To do so, we simply need to fill it in the `filters_mapping` function in the `Post` resource (in `app/v1/resources/post.rb`). In this case, we've designed the DB fields basically for the purposes of the API, so the names in the DB are very much the API attributes. However, for APIs that have to deal with already existing DBs and ORMs, that is often not the case, and the mappings might look a little more purposeful. But anyway, for our `title` filter, the mapping is the same as that's exactly the same method in the underlying `Post` model. For our `author.email` filter, we don't need to remap anything either, as the `author` relationship is called the same in the model, and once we're in the `User` model there is an `email` attribute as well. For `author.id` we could perfectly do the same as they mapp properly to the underlying ORM world, but for demonstration purposes we can also show that we can map it to the `author_id` attribute of the `Post` model itself (that way we don't even need to pay the prize of an inner join with users). Anyway, all of this simply means that you'll need to delete the commented out scaffolding of the `filters_mapping` in the `Post` resource, and past this instead:

```ruby
  filters_mapping(
    'title': 'title',
    'author.email': 'author.email',
    'author.id': 'author_id',
  )
```

We can similarly do the same thing for `Comments`. For example, we can allow to filter comments by `post.id` and `user.id` so we can easily list comments for specific posts and/or made by certain users. We're leaving this as an excercise for the reader ;)

So, that's essentially it. What!? There is still no need to build any controller or ORM queries? Nope, that's the power of following the best practices and adding the extensions. Let's give it a whirl! 

First let's make sure we start (or restart) out API server with `praxis start`. Then, from another terminal, let's get all `posts` that were written by `peter@pan.com` (We know there are some with this email in our seeds):

```shell
# Get all posts written by an author with email=peter@pan.com:
#  -- id, contents and author (with only first_name)
curl 'http://localhost:9292/posts?api_version=1' -G \
      --data-urlencode "filters=author.email=peter@pan.com" \
      --data-urlencode "fields=id,title,content,author{first_name}"
```

Or we can combine multiple filters at once, which Praxis will AND them. For example, let's get posts that contain the word `first` in the `title` AND that have been written by authors with `id` 11 OR 12 (which we know they are Peter and Alice, from the seeds).

```shell
# Get all posts that contain `first` in the title, written by an author with id 11 or 12:
#  -- id, contents and author (with only first_name)
curl 'http://localhost:9292/posts?api_version=1' -G \
      --data-urlencode "filters=title=*first*&author.id=11,12" \
      --data-urlencode "fields=id,title,content,author{first_name}"
```

And there you go. Notice two things here: one is that multiple filters are separated by an `&`, and also equality filters support an array of values, separated by commas (`author.id=11,12`) which will translate into something like `...WHERE authod_id IN (11,12)...`.

Well, at this point we have build a fully featured read-only API which allows us to retrieve users, posts and comments, which supports field selection (including nested relationships), which can paginate and sort and which supports the filtering capabilities we designed for...all, without writing a single line of controller code or any explicit ORM queries. Talk about development efficiency!

The next logical step you might be thinking of is: what about the CRUD operations? I'm glad you asked, let's dig in.