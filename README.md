Ronflex is a Ruby gem that provides a middleware for managing requests and displaying a custom maintenance page during downtime or maintenance. It also offers configuration options to handle user access and authorization rules, making it easy to implement a custom maintenance mode in your application.

Installation
To install the Ronflex gem, add it to your Gemfile:

ruby
Copier le code
gem 'ronflex'
Then, run the following command to install the gem:

bash
Copier le code
bundle install
Alternatively, you can install it directly using gem:

bash
Copier le code
gem install ronflex
Configuration
After installing the gem, you need to configure Ronflex. To do so, add the following to an initializer file (e.g., config/initializers/ronflex.rb):

ruby
Copier le code
Ronflex.configure do |config|
  # The list of paths that are always accessible (no restrictions)
  config.excluded_path = ["/health_check", "/status"]

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
Configuration Options
excluded_path (Array): A list of paths that are always accessible, even when the application is in maintenance mode.

Default: ["/health_check"]

provider (Proc/Lambda): A function that returns the user model based on the request environment. This is used to determine which user is making the request.

Example:

ruby
Copier le code
config.provider = ->(env) { User.find_by(api_key: env['HTTP_API_KEY']) }
rules (Array): A collection of rules for user access authorization. You can add rules to control access based on the user type and request path.

Example:

ruby
Copier le code
config.add_rule :admin do |user, request|
  user.admin? && request.path.start_with?("/admin")
end
enable (Boolean): Enable or disable maintenance mode.

Default: true

maintenance_page (String): A path to a custom maintenance page (HTML or ERB). If not set, a default maintenance page will be used.

Example:

ruby
Copier le code
config.maintenance_page = "/path/to/maintenance_page.html"
Middleware
Ronflex includes a Rack middleware (Ronflex::Rest) that intercepts incoming requests and checks whether the application should be in maintenance mode.

If the enable flag is set to true and the user is not authorized or the system is under maintenance, the middleware will return a 503 response with the maintenance page.
If the request path is in the excluded_path list, it will always be allowed through.
Example usage in config/application.rb:
ruby
Copier le code
# Add Ronflex middleware to the stack
config.middleware.use Ronflex::Rest
Example of Request Handling with Middleware
The middleware checks the following conditions before allowing a request to proceed:

Always Accessible Paths: If the request path is in excluded_path, it is immediately allowed.
Maintenance Mode: If enable is true and the user is authorized, the request will be allowed to proceed. Otherwise, the middleware will return the maintenance page.
Authorization: If a user is authenticated and authorized to access the requested route, the request is allowed to continue.
Custom Maintenance Page
If you configure a custom maintenance_page path in your Ronflex.configure block, the middleware will load the file and return it as the response when the application is in maintenance mode.

The custom maintenance page can be either a static HTML file or an ERB template. If it's an ERB file, it will be rendered.
If the custom page is not found or if no maintenance_page is configured, a default maintenance page will be returned.
ruby
Copier le code
Ronflex.configure do |config|
  config.maintenance_page = "/path/to/custom/maintenance_page.html"
end
Customization and Extensibility
Adding Custom Authorization Rules
You can add custom rules to control which users are allowed to access specific parts of your application. For example:

ruby
Copier le code
Ronflex.configure do |config|
  # Only admin users can access /admin routes
  config.add_rule :admin do |user, request|
    user.admin? && request.path.start_with?("/admin")
  end
end
Handling User Model
Ronflex uses a provider (a lambda or Proc) to determine which user is making the request based on the request environment. This allows you to integrate with your own user authentication system.

ruby
Copier le code
Ronflex.configure do |config|
  config.provider = ->(env) { User.find_by(api_key: env['HTTP_API_KEY']) }
end
Example Flow
Request Access: When a request is made, the middleware checks if the request path is in the list of excluded_path.
Maintenance Mode: If the application is in maintenance mode (Ronflex.configuration.enable = true) and the user is not authorized, a maintenance page is returned with a 503 status.
Authorization: If the request is for an authorized route, the request proceeds as normal.
Example Output of Maintenance Page
When the application is in maintenance mode, the user will see a page like the following:

html
Copier le code
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
Error Handling
In case of issues loading the custom maintenance page (e.g., if the file does not exist), Ronflex will fallback to a default maintenance page.

Contributing
We welcome contributions! Please fork the repository, create a new branch, and submit a pull request with your changes.