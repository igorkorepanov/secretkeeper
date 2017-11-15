# Secretkeeper
Token based authentication.

## Installation
-----------------

Add this line to your application's Gemfile:

```ruby
gem 'secretkeeper'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install secretkeeper
```

Run the installation generator with:
```bash
rails generate secretkeeper:install
```

## Usage
-----------------

### Authorizing requests

``` ruby
class Api::BaseController < ActionController::API
  before_action :secretkeeper_authorize!
end
```

### Authenticating

`config/initializers/secretkeeper.rb`:

``` ruby
Secretkeeper.reflect do |on|
  on.resource_owner do |params|
    User.authenticate!(params[:name], params[:password])
  end
end
```

### Routes

The installation script will also automatically add the Secretkeeper routes into your app.

``` ruby
Rails.application.routes.draw do
  secretkeeper
end
```

## License
-----------------

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
