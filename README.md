# UserQ: Simple User Queues for Rails

UserQ allows you to **very quickly** integrate awesome user-based queues into your Rails application. Many large ticketing websites such as [Ticketmaster](http://www.ticketmaster.com) use queues as a means of user experience.

![Screenshot](http://i.imgur.com/uqYjMyF.gif)

### Example code
```
queue = UserQ::Queue.new(capacity: 50)

## Can we enter the queue?
if queue.enter_into_queue?
	entry = queue.enter
	# entry.code is the ID of the user
	# They have a place in the queue. Sell them a ticket!
else
	# No place in queue. Run this block again after 5 seconds.
end

# Default expiry: 180 seconds
puts entry.expires # => 180
sleep(5)
puts entry.expires # => 175
```

### How does it work?
The capacity you want to distribute (i.e. how many available tickets are left) and then UserQ does its magic (and heavy lifting). Some questions you can ask UserQ:

* How many "people" are in the queue?
* When does the current users spot in the queue expire?
* When do you think another spot in the queue will open? (i.e. average wait time)
* Can I extend/shorten the current users spot in the queue?

### Install
```
Install the gem:
$ gem install userq

Install the database model (automatically migrates):
$ rails generate userq:install

You're all setup!
```


### UserQ Documentation
See the [full documentation on the Wiki](#) to see what you can do with UserQ.


### Uninstall UserQ
```
Revoke the UserQ migration:
$ rake db:rollback

Remove everything UserQ:
$ rails destroy userq:install
```


### Development
Directly clone the repository (or fork it and clone your fork):
```
$ git clone https://github.com/studenthack/userq.git
```

Do some awesome stuff. To test simply run
```
rake test
```

We love pull requests! Make sure you write a test for your contribution.

### Roadmap
- Lots of more awesome looking tests
- Develop the UserQ Wiki
- Assign queue places in a chronological order (first into queue = first entry) instead of randomly

### Release History
- 23/12/13: First version

### LICENCE
Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.