# frozen_string_literal: true

require_relative '../app/controllers/products_controller'
require_relative '../app/controllers/users_controller'

# Routes - Routes for the application
class Routes
  class << self
    def routes
      @routes ||= {
        # Users routes
        ['POST', %r{^/users/sign_up$}] => UsersController.new.method(:sign_up),
        ['POST', %r{^/users/sign_in$}] => UsersController.new.method(:sign_in),
        ['DELETE', %r{^/users/sign_out$}] => UsersController.new.method(:sign_out),

        # Products routes
        ['GET', %r{^/products$}] => ProductsController.new.method(:index),
        ['GET', %r{^/products/(\d+)$}] => ProductsController.new.method(:show),
        ['POST', %r{^/products$}] => ProductsController.new.method(:create),
        ['DELETE', %r{^/products/(\d+)$}] => ProductsController.new.method(:delete)
      }
    end

    def match(method, path)
      routes.find do |(route_method, route_path), _handler|
        route_method == method && path.match?(route_path)
      end&.last
    end

    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new

      handler = match(request.request_method, request.path)

      if handler
        handler.call(request, response)
        response.finish
      else
        [404, { 'content-type' => 'application/json' }, [{ error: 'Not Found' }.to_json]]
      end
    end
  end
end
