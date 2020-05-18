# HandleSystem

A Ruby library for interfacing with the [Handle System](http://handle.net/) JSON REST API.

## Handle server requirements

This library works with Handle System version 8 or higher.  For older versions of the Handle System, which didn't have a JSON API, consider using mbklien's [Handle](https://github.com/mbklein/handle) library.

### Private key conversion

Before you start using the library, you need to convert your Handle server's private key into PEM format.  The Handle Server distribution directory (e.g., `/hs/handle-9.2.0`) has a utility, `hdl-convert-key`, for doing this.  Your private key (`admpriv.bin`) is in the server directory (e.g., `/hs/svr_1`).

On the Handle server, Run this command to convert the file:

```
/hs/handle-9.2.0/bin/hdl-convert-key /hs/svr_1/admpriv.bin -o /hs/svr_1/admpriv.pem
```

Download that `admpriv.pem` file for use with this library.

## Installation

Add this line to your application's Gemfile:

    gem 'handle-system-rest'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install handle-system-rest

## Usage

```ruby
require 'handle_system'

server = '216.58.217.206:8000'        # server in the form of ip-address:port
hs_admin = '300:0.NA/20.123.4567'     # the handle server admin
private_key = '/path/to/admpriv.pem'  # path to private key we downloaded above

# connect to the handle server
handle_client = HandleSystem::Client.new(server, hs_admin, private_key)

# the url we want to register with the handle system
hyrax_url = 'https://hyrax.example.edu/concern/theses/6h440t294'

# we need to create a unique handle identifier in the form of 'prefix/suffix'

prefix = '20.123.45678'         # your handle.net registered prefix
suffix = '2'                    # this can be any unique identifier
handle = prefix + '/' + suffix

# register our url and get back a new persistent url
handle_url = handle_client.create(handle, hyrax_url)

puts handle_url  #=> "http://hdl.handle.net/20.123.45678/2"

# get back our original url if we supply the handle
hyrax_url = handle_client.get(handle).url

puts hyrax_url  #=> "https://hyrax.example.edu/concern/theses/6h440t294"

# we can also delete our handle entry
result = handle_client.delete(handle)

puts result.to_s  #=> true

# client will throw an AuthenticationError if something went wrong while
# authenticating with the handle server

begin
  HandleSystem::Client.new(server, 'bad-admin', private_key)
rescue HandleSystem::AuthenticationError => e
  puts 'AuthenticationError'
  puts '  message: ' + e.message
end

# client will throw an Error if something went wrong while creating, updating,
# or deleting a handle

begin
  handle_client.create('bad-handle', hyrax_url)
rescue HandleSystem::Error => e
  puts 'Error for bad handle id'
  puts '  code: ' + e.response_code.to_s
  puts '  handle: ' + e.handle
  puts '  message: ' + e.message
end

begin
  handle_client.delete('bad-handle')
rescue HandleSystem::Error => e
  puts 'Error when trying to delete a non-existant handle'
  puts '  code: ' + e.response_code.to_s
  puts '  handle: ' + e.handle
  puts '  message: ' + e.message
end

```
