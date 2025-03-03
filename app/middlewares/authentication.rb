# frozen_string_literal: true

require 'json'
require_relative '../../lib/formatters/response_formatter'

module Middlewares
  # Authentication - Middleware for user authentication
  class Authentication
    include ResponseFormatter
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new
      return @app.call(env) if authenticated?(request)

      LOGGER.warn('Unauthorized access attempt')
      formatted_response(response, { error: 'You need to sign in before continuing' }, status: 401)
      response.finish
    end

    private

    def authenticated?(request)
      return true unless require_authentication?(request)

      request.session[:username]
    end

    def require_authentication?(request)
      request.path.match?(%r{^/products})
    end
  end
end
