# frozen_string_literal: true

require 'concurrent'
require 'bcrypt'

module Repositories
  # UserRepository - Repository for user management
  class UserRepository
    @users = Concurrent::Map.new

    class << self
      def create(username, password)
        encrypted_password = BCrypt::Password.create(password)
        @users[username] = encrypted_password
      end

      def exists?(username)
        @users.key?(username)
      end

      def verify_credentials(username, password)
        stored_password = @users[username]
        return false unless stored_password

        BCrypt::Password.new(stored_password) == password
      end
    end
  end
end
