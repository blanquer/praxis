---
title: Intro
---
So you're new to Praxis, you've read some of the cool stuff that it can do and
you're ready to see it to believe it? Great! You're in the right place.

Let's show you how easy it is to create a fully functioning API from scratch, capable to serve Posts (that are authored by Users), each of which can contain comments where each comment is also made by one of the existing users.

To simplify the setup we will use the embedded sequel Lite DB, but you can easily configure
the app later on to work against a real MySQL or Postgres if you'd like.

The first thing to do is to create a base Praxis application. To do so, let's use the Praxis
example generator to build us a simple API which can serve Users.

```shell
gem install praxis # Let's make sure we have Praxis installed in the system
bundle exec praxis example firstapp && cd firstapp
bundle
```

At this point we already have a fully bundled Praxis app. We can trivially start on port 9292 it by migrating it and starting rack (i.e., bundle exec rake db:recreate && bundle rackup). But since we'll add more resources, we can do that at the end.

