module Ronflex
  class Rest
    # Initializes the middleware with the given app
    #
    # @param app [Object] The application instance that this middleware wraps
    #   It will call the next middleware or application in the stack.
    def initialize(app)
      @app = app
    end

    # Rack middleware call method that processes the incoming request.
    #
    # It checks if the request should be granted access, and if not, it returns
    # the maintenance page or proceeds with the normal request handling.
    #
    # @param env [Hash] Rack environment hash which contains information about
    #   the incoming request, such as headers, parameters, etc.
    #
    # @return [Array] Rack response in the form of [status, headers, body]
    #   If access is allowed, the request is passed to the next middleware/application.
    #   Otherwise, a 503 status with the maintenance page is returned.
    def call(env)
      request = Rack::Request.new(env)
      model = Ronflex.configuration.provider.call(env)

      # If the request is always accessible (excluded path), pass the request to the next app
      return @app.call(env) if always_access?(request)

      # If the system is enabled and the model is present and authorized, proceed with the request
      if Ronflex.configuration.enable
        if model_present?(model) && routes_authorized?(model, request)
          return @app.call(env)
        else
          # If conditions are not met, return maintenance page
          return [503, { "Content-Type" => "text/html" }, [maintenance_page]]
        end
      end

      # Default pass-through for the request
      @app.call(env)
    end

    private

    # Checks if the request path is always accessible, i.e., excluded from any restrictions.
    #
    # @param request [Rack::Request] The current HTTP request object
    #
    # @return [Boolean] Returns `true` if the request path is in the list of excluded paths.
    def always_access?(request)
      Ronflex.configuration.excluded_path.include?(request.path)
    end

    # Checks if the model (user or entity) is present and valid.
    #
    # @param model [Object] The model (typically a user) retrieved from the provider.
    #
    # @return [Boolean] Returns `true` if the model is present and valid as per the configuration.
    def model_present?(model)
      Ronflex.configuration.model_present?(model)
    end

    # Checks if the current route is authorized for the given model.
    #
    # @param model [Object] The model (user or entity) for which access needs to be authorized.
    # @param request [Rack::Request] The current HTTP request object containing the route.
    #
    # @return [Boolean] Returns `true` if the model is allowed to access the requested route.
    def routes_authorized?(model, request)
      Ronflex.configuration.allowed?(model, request)
    end

    # Returns the content of the maintenance page, either custom or default.
    #
    # @return [String] The HTML content to be displayed on the maintenance page.
    def maintenance_page
      if Ronflex.configuration.maintenance_page
        load_custom_maintenance_page(Ronflex.configuration.maintenance_page)
      else
        default_maintenance_page
      end
    end

    # Loads a custom maintenance page if a path is provided.
    #
    # If the path is an ERB file, it renders the template. Otherwise, it reads and returns the HTML file.
    #
    # @param path [String] The file path to the custom maintenance page (could be HTML or ERB).
    #
    # @return [String] The rendered HTML content of the custom maintenance page.
    def load_custom_maintenance_page(path)
      if path.end_with?(".erb")
        template = ERB.new(File.read(path))
        template.result
      else
        File.read(path)
      end
    rescue Errno::ENOENT
      default_maintenance_page
    end

    # Provides the default maintenance page content.
    #
    # This is a basic HTML page shown when no custom page is configured or when
    # there is an issue loading the custom maintenance page.
    #
    # @return [String] The default HTML content for the maintenance page.
    def default_maintenance_page
      <<~HTML
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
      HTML
    end
  end
end
