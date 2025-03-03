# frozen_string_literal: true

require_relative '../../app/repositories/user_repository'

# Seeds - Seeds for the application
module Seeds
  include Repositories

  DEFAULT_USERNAME = 'admin'
  DEFAULT_PASSWORD = 'password123'

  def self.create
    return if UserRepository.exists?(DEFAULT_USERNAME)

    UserRepository.create(DEFAULT_USERNAME, DEFAULT_PASSWORD)
    LOGGER.info('=== Defuault user created ===')
    LOGGER.info('=== Read documentation for more information ===')
  end
end
