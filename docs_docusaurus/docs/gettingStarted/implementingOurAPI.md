---
title: Implementing Our API
sidebar_label:  Implementing Our API
---

So here we are. We have designed our new API endpoints by specifying which actions we want to expose and the shapes of our Post and Comments. We have also taken care of creating our DB structure and filled in some data to play with. It is time to actually implement some code that can allow us to query for these resources.

Well, we hate to break it to you but the `index` and `show` actions (that search the collection and show a single element) are 100% implemented in the generated scaffolding code. Not only that, but they support field selection (a la GraphQL), ordering and pagination. Done and done. Don't quite believe it? Let's take our API for a spin shall we? Let's first start our Rack app by:

```shell
bundle exec rackup
```

And now we're ready to throw some queries at it. Here are some examples you can start trying from another terminal:

```shell
# Get all posts in the DB but only include:
#  -- id, contents and author (with only first_name)
curl 'http://localhost:9292/posts?api_version=1' -G \
      --data-urlencode "fields=id,content,author{first_name}"

# Retrieve DB Comment with id 1, but only include:
#  -- id, contents, related post (only id) and related user (only first_name)
curl 'http://localhost:9292/comments/1?api_version=1' -G \
  --data-urlencode "fields=id,content,post{id},user{first_name}"

# Retrieve the second page of users, ordering them by uuid first, and then last_name (page size of 5)
#  -- display only their id, email and first_name
curl 'http://localhost:9292/users?api_version=1' -G \
    --data-urlencode "fields=id,email,first_name" \
    --data-urlencode "order=uuid,last_name" \
    --data-urlencode "pagination=page=2,items=5"    
```

And there you go!, you have a fully functioning API that is able to query items related collections from a real DB, with full support for GraphQL-style field selection. You're more than welcome to enable SQL logging and see how efficient the queries are...Not too shabby having all this functionality without having written a single line of controller or ORM code! (To enable logging the easiest is to add `ActiveRecord::Base.logger = Logger.new(STDOUT)` towards the end of `config.ru`)

Did this leave you thirsty for more? Ok, challenge accepted, let's go for extra credit by showing you how you can trivially enable powerful query filtering on top of this


NOTE: Also about the other actions that are just scaffolded...