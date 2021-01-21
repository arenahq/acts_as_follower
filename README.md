![Ruby](https://github.com/aredotna/acts_as_follower/workflows/Ruby/badge.svg)

# acts_as_follower

`acts_as_follower` is a gem to allow any model to follow any other model.
This is accomplished through a double polymorphic relationship on the Follow model.

There is also built in support for blocking/un-blocking follow records. **not supported here**

Main uses would be for Users to follow other Users or for Users to follow Books, etc …



## Installation

### The master branch supports Rails 5

Add the gem to the gemfile:
```ruby
gem 'acts_as_follower', github: 'aredotna/acts_as_follower', branch: 'master'
```


## Usage

### Setup

Make your model(s) that you want to allow to be followed acts_as_followable, just add the mixin:
```ruby
class User < ActiveRecord::Base
  ...
  acts_as_followable
  ...
end

class Book < ActiveRecord::Base
  ...
  acts_as_followable
  ...
end
```

Make your model(s) that can follow other models acts_as_follower
```ruby
class User < ActiveRecord::Base
  ...
  acts_as_follower
  ...
end
```


### acts_as_follower methods

To have an object start following another use the following:
```ruby
book = Book.find(1)
user = User.find(1)
user.follow(book) # Creates a record for the user as the follower and the book as the followable
```
To stop following an object use the following
```ruby
user.stop_following(book) # Deletes that record in the Follow table
```

You can check to see if an object that acts_as_follower is following another object through the following:
```ruby
user.following?(book) # Returns true or false
```

To get the total number (count) of follows for a user use the following on a model that acts_as_follower
```ruby
user.follow_count # Returns an integer
```

To get follow records that have not been blocked use the following
```ruby
user.all_follows # returns an array of Follow records
```

To get all of the records that an object is following that have not been blocked use the following
```ruby
user.all_following
# Returns an array of every followed object for the user, this can be a collection of different object types, eg: User, Book
```

To get all Follow records by a certain type use the following
```ruby
user.follows_by_type('Book') # returns an array of Follow objects where the followable_type is 'Book'
```

To get all followed objects by a certain type use the following.
```ruby
  user.following_by_type('Book')
  # Returns an array of all followed objects for user where followable_type is 'Book', this can be a collection of different object types, eg: User, Book
```

There is also a method_missing to accomplish the exact same thing a following_by_type('Book') to make you life easier
```ruby
user.following_users # exact same results as user.following_by_type('User')
```

To get the count of all Follow records by a certain type use the following
```ruby
user.following_by_type_count('Book') # Returns the sql count of the number of followed books by that user
```

There is also a method_missing to get the count by type
```ruby
user.following_books_count # Calls the user.following_by_type_count('Book') method
```

There is now a method that will just return the Arel scope for follows so that you can chain anything else you want onto it:
```ruby
book.follows_scoped
```
This does not return the actual follows, just the scope of followings including the followables, essentially:  book.follows.unblocked.includes(:followable)

The following methods take an optional hash parameter of ActiveRecord options (:limit, :order, etc...)
```ruby
follows_by_type, all_follows, all_following, following_by_type
```


### acts_as_followable methods

To get all the followers of a model that acts_as_followable
```ruby
book.followers
# Returns an array of all the followers for that book, a collection of different object types (eg. type User or type Book)
```

There is also a method that will just return the Arel scope for followers so that you can chain anything else you want onto it:
```ruby
book.followers_scoped
```
This does not return the actual followers, just the scope of followings including the followers, essentially:  book.followings.includes(:follower)

To get just the number of follows use
```ruby
book.followers_count
```

To get the followers of a certain type, eg: all followers of type 'User'
```ruby
book.followers_by_type('User') # Returns an array of the user followers
```

There is also a method_missing for this to make it easier:
```ruby
book.user_followers # Calls followers_by_type('User')
```

To get just the sql count of the number of followers of a certain type use the following
```ruby
book.followers_by_type_count('User') # Return the count on the number of followers of type 'User'
```

Again, there is a method_missing for this method as well
```ruby
book.count_user_followers # Calls followers_by_type_count('User')
```

To see is a model that acts_as_followable is followed by a model that acts_as_follower use the following
```ruby
book.followed_by?(user)
# Returns true if the current instance is followed by the passed record
# Returns false if the current instance is blocked by the passed record or no follow is found
```

To block a follower call the following **this method is not available here**
```ruby
book.block(user)
# Blocks the user from appearing in the followers list, and blocks the book from appearing in the user.all_follows or user.all_following lists
```

To unblock is just as simple
```ruby
book.unblock(user)
```

To get all blocked records
```ruby
book.blocks # Returns an array of blocked follower records (only unblocked) (eg. type User or type Book)
```

If you only need the number of blocks use the count method provided
```ruby
book.blocked_followers_count
```

Unblocking deletes all records of that follow, instead of just the :blocked attribute => false the follow is deleted.  So, a user would need to try and follow the book again.
I would like to hear thoughts on this, I may change this to make the follow as blocked: false instead of deleting the record.

The following methods take an optional hash parameter of ActiveRecord options (:limit, :order, etc...)
```ruby
followers_by_type, followers, blocks
```

### Follow Model

The Follow model has a set of named_scope's.  In case you want to interface directly with the Follow model you can use them.
```ruby
Follow.unblocked # returns all "unblocked" follow records
Follow.blocked # returns all "blocked" follow records
Follow.descending # returns all records in a descending order based on created_at datetime
```

This method pulls all records created after a certain date.  The default is 2 weeks but it takes an optional parameter.
```ruby
Follow.recent
Follow.recent(4.weeks.ago)
```
`Follow.for_follower` is a named_scope that is mainly there to reduce code in the modules but it could be used directly.
It takes an object and will return all Follow records where the follower is the record passed in.
Note that this will return all blocked and unblocked records.
```ruby
Follow.for_follower(user)
```
If you don't need the blocked records just use the methods provided for this:
```ruby
user.all_follows
# or
user.all_following
```
Follow.for_followable acts the same as its counterpart (for_follower).
It is mainly there to reduce duplication, however it can be used directly.
It takes an object that is the followed object and return all Follow records where that record is the followable.
Again, this returns all blocked and unblocked records.
```ruby
Follow.for_followable(book)
```
Again, if you don't need the blocked records use the method provided for this:
```ruby
book.followers
```
If you need blocked records only
```ruby
book.blocks
```

## Comments/Requests

If anyone has comments or questions please let me know (tom dot cocca at gmail dot com).
If you have updates or patches or want to contribute I would love to see what you have or want to add.


## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally (acts_as_follower uses Shoulda and Factory Girl)
* Send me a pull request. Bonus points for topic branches.


## Contributers

Thanks to everyone for their interest and time in committing to making this plugin better.

* dougal (Douglas F Shearer) - https://github.com/dougal
* jdg (Jonathan George) - https://github.com/jdg
* m3talsmith (Michael Christenson II) - https://github.com/m3talsmith
* joergbattermann (Jörg Battermann) - https://github.com/joergbattermann
* TomK32 (Thomas R. Koll) - https://github.com/TomK32
* drcapulet (Alex Coomans) - https://github.com/drcapulet
* jhchabran (Jean Hadrien Chabran) - https://github.com/jhchabran
* arthurgeek (Arthur Zapparoli) - https://github.com/arthurgeek
* james2m (James McCarthy) - https://github.com/james2m
* peterjm (Peter McCracken) - https://github.com/peterjm
* merqlove (Alexander Merkulov) - https://github.com/merqlove

Please let me know if I missed you.


## Copyright

Copyright (c) 2008 - 2010 ( tom dot cocca at gmail dot com ), released under the MIT license.

Copyright (c) 2021 - today [Are.na](https://github.com/aredotna), released under the MIT license.
