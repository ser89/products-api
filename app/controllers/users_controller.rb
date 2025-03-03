# frozen_string_literal: true

require 'bcrypt'
require 'pry'
require_relative '../repositories/user_repository'
require_relative '../../lib/formatters/response_formatter'

# UsersController - Handles user authentication and registration
class UsersController
  include ResponseFormatter
  include Repositories

  def sign_in(request, response)
    username, password, errors = parse_and_validate_params(request)
    return formatted_response(response, { errors: errors }, status: 400) if errors.any?

    return invalid_user(request, response) unless UserRepository.verify_credentials(username, password)

    valid_user(request, response, username)
  rescue JSON::ParserError
    formatted_response(response, { error: 'Invalid JSON format' }, status: 400)
  end

  def sign_up(request, response)
    username, password, errors = parse_and_validate_params(request)
    return formatted_response(response, { errors: errors }, status: 400) if errors.any?

    if UserRepository.exists?(username)
      return formatted_response(response, { message: 'User already exists' }, status: 422)
    end

    UserRepository.create(username, password)
    formatted_response(response, { message: 'User created successfully' }, status: 201)
  rescue JSON::ParserError
    formatted_response(response, { error: 'Invalid JSON format' }, status: 400)
  end

  def sign_out(request, response)
    request.session.clear
    formatted_response(response, { message: 'Logout successful' }, status: 200)
  end

  private

  def blank?(value)
    value.nil? || value.empty?
  end

  def validate_params(username, password)
    errors = []
    errors << 'Username is required' if blank?(username)
    errors << 'Username must be at least 3 characters long' if username.nil? || username.length < 3
    errors << 'Password is required' if blank?(password)
    errors << 'Password must be at least 8 characters long' if password.nil? || password.length < 8
    errors
  end

  def parse_and_validate_params(request)
    params = JSON.parse(request.body.read)
    username = params['username']
    password = params['password']
    errors = validate_params(username, password)

    [username, password, errors]
  end

  def valid_user(request, response, username)
    request.session[:username] = username
    formatted_response(response, { message: 'Login successful' }, status: 200)
  end

  def invalid_user(request, response)
    request.session.clear
    formatted_response(response, { message: 'Invalid credentials' }, status: 401)
  end
end
