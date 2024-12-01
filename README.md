# Ronflex Gem

[![Gem Version](https://badge.fury.io/rb/ronflex.svg)](http://badge.fury.io/rb/ronflex)

`Ronflex` is a Ruby gem that provides a middleware for managing requests and displaying a custom maintenance page during downtime or maintenance. It also offers configuration options to handle user access and authorization rules, making it easy to implement a custom maintenance mode in your application.

## Installation

Run:

    bundle add ronflex

Or install it yourself as:

    $ gem install ronflex

## Configuration

```ruby
Ronflex.configure do |config|
  # The list of paths that are always accessible by default "/health_check" and "/favicon.ico"(no restrictions)
  config.excluded_path += ["/status"]

  # Define a provider for user model (can be a Proc or Lambda)
  config.provider = ->(env) { User.find_by(api_key: env['HTTP_API_KEY']) }

  # Define rules for which routes users are authorized to access
  config.add_rule :admin do |user, request|
    request.path.start_with?("/admin") && user.admin?
  end

  # Enable or disable the maintenance mode
  config.enable = true

  # Optional: Set a custom maintenance page (HTML or ERB template)
  config.maintenance_page = "/path/to/maintenance_page.html"  # Or "/path/to/maintenance_page.erb"
end
```

## Enable or disable ronflex
```ruby
# Playing the pokeflute, Ronflex wakes up and no longer blocks the road
Ronflex.play_pokeflute

# Stop the pokeflute, Ronflex falls asleep and blocks the road again
Ronflex.stop_pokeflute
```

## Configuration Options

- excluded_path (Array): A list of paths that are always accessible, even when the application is in maintenance mode.

Default: ["/health_check"]

- provider (Proc/Lambda): A function that returns the user model based on the request environment. This is used to determine which user is making the request.

exemple:
```ruby
config.provider = ->(env) { User.find_by(api_key: env['HTTP_API_KEY']) }
```

- rules (Array): A collection of rules for user access authorization. You can add rules to control access based on the user type and request path.

Example:
```ruby
config.add_rule :admin do |user, request|
  user.admin? && request.path.start_with?("/admin")
end
```

- enable (Boolean): Enable or disable maintenance mode.
Default: false

- maintenance_page (String): A path to a custom maintenance page (HTML or ERB). If not set, a default maintenance page will be used.

Example:
```ruby
config.maintenance_page = "/path/to/maintenance_page.html"
```

## Middleware
Ronflex includes a Rack middleware (Ronflex::Rest) that intercepts incoming requests and checks whether the application should be in maintenance mode.

- If the enable flag is set to true and the user is not authorized or the system is under maintenance, the middleware will return a 503 response with the maintenance page.
- If the request path is in the excluded_path list, it will always be allowed through.

Example usage in config/application.rb:
```ruby
# Add Ronflex middleware to the stack
config.middleware.use Ronflex::Rest
```

Example of Request Handling with Middleware
The middleware checks the following conditions before allowing a request to proceed:

1. Always Accessible Paths: If the request path is in excluded_path, it is immediately allowed.
2. Maintenance Mode: If enable is true and the user is not authorized, the request will return the maintenance page.
3. Authorization: If a user is authenticated and authorized to access the requested route, the request proceeds as normal.

## Custom Maintenance Page
If you configure a custom maintenance_page path in your Ronflex.configure block, the middleware will load the file and return it as the response when the application is in maintenance mode.

- The custom maintenance page can be either a static HTML file or an ERB template. If it's an ERB file, it will be rendered.
- If the custom page is not found or if no maintenance_page is configured, a default maintenance page will be returned.

```ruby
Ronflex.configure do |config|
  config.maintenance_page = "/path/to/custom/maintenance_page.html"
end
```

## Customization and Extensibility

Adding Custom Authorization Rules
You can add custom rules to control which users are allowed to access specific parts of your application. For example:
```ruby
Ronflex.configure do |config|
  # Only admin users can access /admin routes
  config.add_rule :admin do |user, request|
    user.admin? && request.path.start_with?("/admin")
  end
end
```

## Handling User Model
Ronflex uses a provider (a lambda or Proc) to determine which user is making the request based on the request environment. This allows you to integrate with your own user authentication system.
```ruby
Ronflex.configure do |config|
  config.provider = ->(env) { User.find_by(api_key: env['HTTP_API_KEY']) }
end
```

## Example Flow
1. Request Access: When a request is made, the middleware checks if the request path is in the list of excluded_path.
2. Maintenance Mode: If enable is true and the user is not authorized, the request will return the maintenance page.
3. Authorization: If the request is for an authorized route, the request proceeds as normal.

## Example Output of Maintenance Page
When the application is in maintenance mode, the user will see a page like the following:
```html
<!DOCTYPE html>
<html>
  <head>
    <title>Maintenance</title>
  </head>
  <body>
    <h1>The site is currently under maintenance</h1>
    <p>Please try again later</p>
  </body>
</html>
```

## Contributors Helps
How to allow modification of the snorlax instance directly in the application to reflect changes made in the Rails console?


## Error Handling
In case of issues loading the custom maintenance page (e.g., if the file does not exist), Ronflex will fallback to a default maintenance page.
