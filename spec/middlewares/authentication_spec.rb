# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Middlewares::Authentication do
  let(:app) { ->(env) { [200, env, 'OK'] } }
  let(:middleware) { described_class.new(app) }
  let(:env) { { 'rack.session' => {} } }

  describe '#call' do
    context 'when path does not require authentication' do
      it 'skips authentication for non-protected routes' do
        env['PATH_INFO'] = '/auth/login'
        status, = middleware.call(env)
        
        expect(status).to eq(200)
      end
    end

    context 'when path requires authentication' do
      before do
        env['PATH_INFO'] = '/products'
      end

      context 'when user is authenticated' do
        before do
          env['rack.session'][:username] = 'admin'
        end

        it 'allows access to protected routes' do
          status, = middleware.call(env)
          
          expect(status).to eq(200)
        end
      end

      context 'when user is not authenticated' do
        it 'returns unauthorized status' do
          status, _, body = middleware.call(env)
          response = JSON.parse(body.first)
          
          expect(status).to eq(401)
          expect(response['error']).to eq('You need to sign in before continuing')
        end
      end
    end
  end

  describe '#require_authentication?' do
    context 'when path starts with /products' do
      it 'requires authentication' do
        env['PATH_INFO'] = '/products'
        expect(middleware.send(:require_authentication?, Rack::Request.new(env))).to be true
      end

      it 'requires authentication for nested routes' do
        env['PATH_INFO'] = '/products/1'
        expect(middleware.send(:require_authentication?, Rack::Request.new(env))).to be true
      end
    end

    context 'when path does not start with /products' do
      it 'does not require authentication' do
        env['PATH_INFO'] = '/auth/login'
        expect(middleware.send(:require_authentication?, Rack::Request.new(env))).to be false
      end
    end
  end
end