# frozen_string_literal: true

require 'logger'
require 'rack'
require 'rack/session'
require_relative 'config/routes'
require_relative 'config/initializers/seeds'
require_relative 'app/middlewares/authentication'

LOGGER = Logger.new($stdout)
LOGGER.level = Logger::DEBUG

# App - Main application class
class App
  def initialize # rubocop:disable Metrics/MethodLength
    Seeds.create
    @app = Rack::Builder.new do
      use Rack::Session::Cookie,
          secret: SecureRandom.hex(64),
          same_site: true,
          expire_after: 86_400,
          key: '_api_session',
          path: '/'

      use Middlewares::Authentication
      use Rack::Deflater
      use Rack::Static,
          urls: %w[/AUTHORS /openapi.yml],
          root: 'public',
          header_rules: [
            [:all, { 'cache-control' => 'public, max-age=86400' }],
            ['/openapi.yml', {
              'content-type' => 'application/yaml',
              'cache-control' => 'no-store, no-cache, must-revalidate',
              'pragma' => 'no-cache',
              'expires' => '0'
            }]
          ]
      run Routes
    end
  end

  def call(env)
    @app.call(env)
  end
end
