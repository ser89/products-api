# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UsersController do
  let(:valid_credentials) do
    {
      username: 'testuser',
      password: 'password123'
    }
  end

  describe 'POST /users/sign_up' do
    context 'with valid parameters' do
      it 'creates a new user successfully' do
        post '/users/sign_up', valid_credentials.to_json

        expect(last_response.status).to eq(201)
        expect(json_response['message']).to eq('User created successfully')
      end
    end

    context 'with invalid parameters' do
      it 'returns error for missing username' do
        post '/users/sign_up', { password: 'password123' }.to_json

        expect(last_response.status).to eq(400)
        expect(json_response['errors']).to include('Username is required')
      end

      it 'returns error for short username' do
        post '/users/sign_up', { username: 'ab', password: 'password123' }.to_json

        expect(last_response.status).to eq(400)
        expect(json_response['errors']).to include('Username must be at least 3 characters long')
      end

      it 'returns error for missing password' do
        post '/users/sign_up', { username: 'testuser' }.to_json

        expect(last_response.status).to eq(400)
        expect(json_response['errors']).to include('Password is required')
      end

      it 'returns error for short password' do
        post '/users/sign_up', { username: 'testuser', password: '123' }.to_json

        expect(last_response.status).to eq(400)
        expect(json_response['errors']).to include('Password must be at least 8 characters long')
      end

      it 'returns error for invalid JSON' do
        post '/users/sign_up', 'invalid json'

        expect(last_response.status).to eq(400)
        expect(json_response['error']).to eq('Invalid JSON format')
      end
    end

    context 'when user already exists' do
      before do
        post '/users/sign_up', valid_credentials.to_json
      end

      it 'returns error for duplicate username' do
        post '/users/sign_up', valid_credentials.to_json

        expect(last_response.status).to eq(422)
        expect(json_response['message']).to eq('User already exists')
      end
    end
  end

  describe 'POST /users/sign_in' do
    context 'with valid credentials' do
      before do
        post '/users/sign_up', valid_credentials.to_json
      end

      it 'signs in user successfully' do
        post '/users/sign_in', valid_credentials.to_json

        expect(last_response.status).to eq(200)
        expect(json_response['message']).to eq('Login successful')
      end

      it 'sets session cookie' do
        post '/users/sign_in', valid_credentials.to_json

        expect(last_response.headers['Set-Cookie']).to include('_api_session')
      end
    end

    context 'with invalid credentials' do
      before do
        post '/users/sign_up', valid_credentials.to_json
      end

      it 'returns error for wrong password' do
        post '/users/sign_in', { username: 'testuser', password: 'wrongpass' }.to_json

        expect(last_response.status).to eq(401)
        expect(json_response['message']).to eq('Invalid credentials')
      end

      it 'returns error for non-existent user' do
        post '/users/sign_in', { username: 'nonexistent', password: 'password123' }.to_json

        expect(last_response.status).to eq(401)
        expect(json_response['message']).to eq('Invalid credentials')
      end

      it 'returns error for invalid JSON' do
        post '/users/sign_in', 'invalid json'

        expect(last_response.status).to eq(400)
        expect(json_response['error']).to eq('Invalid JSON format')
      end
    end

    context 'with validation errors' do
      it 'returns errors for missing credentials' do
        post '/users/sign_in', {}.to_json

        expect(last_response.status).to eq(400)
        expect(json_response['errors']).to include('Username is required', 'Password is required')
      end
    end
  end

  describe 'DELETE /users/sign_out' do
    context 'when user is signed in' do
      before do
        sign_in_user
      end

      it 'signs out user successfully' do
        delete '/users/sign_out'

        expect(last_response.status).to eq(200)
        expect(json_response['message']).to eq('Logout successful')
      end

      it 'clears session' do
        delete '/users/sign_out'
        
        get '/products'
        expect(last_response.status).to eq(401)
      end
    end
  end
end
