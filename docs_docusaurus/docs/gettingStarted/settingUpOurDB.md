---
title: Setting Up Our Database
sidebar_label:  Setting Up Our Database
---

So obviously, to have our API serve data, we need to have a DB with the proper posts and comments tables, hopefully filled with some interesting data. This part has nothing to do with Praxis, but it still needs to be done! Note that if you're building a Praxis API to serve already existing DB data, the only thing you need to do is to configure your models. Or even better, if you're building a Praxis API to serve already existing models within a Rails app, none of this needs to be done, as it's already in place.

But we digress, let's first create the tables we want with a migration. Here's a quick and dirty thing you can copy past to generate that. Note that we're simply adding a `title` and `content` field to the posts, as well as a "foreign key" to the users table for the `author` of the post. For the comments, we're only adding a `content` field, and a couple of keys to point back to the id of the `post` it belongs, and the `user` that made the comment. All very straightforward.

```shell title="Create an ActiveRecord migration for posts and comments"
cat <<EOT > db/migrate/20210101010111_create_posts_and_comments_table.rb
class CreatePostsAndCommentsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.column :title, :string
      t.column :content, :text
      t.column :author_id, :integer
    end
    create_table :comments do |t|
      t.column :content, :string
      t.column :post_id, :integer
      t.column :user_id, :integer
    end
  end
end
EOT
```

Next, we need to tell our ActiveRecord models about those tables and existing "foreign keys" to build associations. Here's another simple shell script you can copy to add those lines to our model files.

```shell title="Define the associations to the Post and Comment models"
sed -i '' '/.*end/i \
  belongs_to :author, class_name: "User" \
  has_many :comments \
' app/models/post.rb

sed -i '' '/.*end/i \
  belongs_to :post \
  belongs_to :user \
' app/models/comment.rb
```

And the last thing we might want to do to setup the storage layer, is to fill in the DB with some interesting data that we can query through the API. We'll keep it very short, but at least we'll have a couple of posts, authored by a couple of users, with one comment for each one. Feel free to spice this up once you're starting having fun! Copy this shell snippet to add this code into `db/seeds.rb` which is always run when we seed the DB.

```shell title="Create some useful data when seeding the DB"
cat <<EOT >> db/seeds.rb
peter = ::User.find(11)
alice = ::User.find(12)
post1 = ::Post.create(title: 'My first post', content:'Post from Peter', author: peter)
post1.comments.create(content: 'Nice post!', user: alice)
::Post.create(content:'Post2 from Peter', author: peter)
post2 = ::Post.create(title: 'My first post', content:'Post from Alice', author: alice)
post2.comments.create(content: 'Good one Alice!', user: peter)
post3 = ::Post.create(title: 'My other post', content:'Peter Post No Comments', author: peter)
EOT
```

and with that, we are not ready to recreate the DB, which will run the migration and seed our data:

```shell
# Rebuild the DB, with the new seeds
bundle exec rake db:recreate
```

We are now ready to return to Praxis-land and see about interacting with this data through our new API.

