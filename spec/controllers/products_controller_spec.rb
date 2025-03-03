# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProductsController do
  let(:valid_headers) { { 'content-type' => 'application/json' } }


  before do
    stub_sync_creation
  end

  shared_examples 'unauthenticated user' do
    it 'returns 401 unauthorized' do
      expect(last_response.status).to eq(401)
      expect(json_response['error']).to eq('You need to sign in before continuing')
    end
  end

  describe 'GET /products' do
    context 'when authenticated' do
      before { stub_authentication }

      context 'when there are no products' do
        it 'returns an empty array' do
          get '/products'
          
          expect(last_response.status).to eq(200)
          expect(json_response['products']).to eq([])
        end
      end

      context 'when there are products' do
        before do
          Repositories::ProductRepository.create('Test Product')
        end

        it 'returns all products' do
          get '/products'
          
          expect(last_response.status).to eq(200)
          expect(json_response['products']).to be_an(Array)
          expect(json_response['products'].first['name']).to eq('Test Product')
        end
      end
    end

    context 'when not authenticated' do
      before do
        stub_authentication(authenticated: false)
        get '/products'
      end

      it_behaves_like 'unauthenticated user'
    end
  end

  describe 'GET /products/:id' do
    context 'when authenticated' do
      before { stub_authentication }

      context 'when product exists' do
        let(:product_id) do
          Repositories::ProductRepository.create('Test Product')
        end

        it 'returns the product' do
          get "/products/#{product_id}"
          
          expect(last_response.status).to eq(200)
          expect(json_response['product']['id']).to eq(product_id)
          expect(json_response['product']['name']).to eq('Test Product')
        end
      end

      context 'when product does not exist' do
        it 'returns 404' do
          get '/products/999'
          
          expect(last_response.status).to eq(404)
          expect(json_response['error']).to eq('Product not found')
        end
      end
    end

    context 'when not authenticated' do
      before do
        stub_authentication(authenticated: false)
        get '/products/1'
      end

      it_behaves_like 'unauthenticated user'
    end
  end

  describe 'POST /products' do
    context 'when authenticated' do
      before { stub_authentication }

      context 'with valid parameters' do
        it 'creates a product asynchronously' do
          post '/products', { name: 'New Product' }.to_json, valid_headers
          
          expect(last_response.status).to eq(202)
          expect(json_response['message']).to eq('Product creation in progress')
          expect(Repositories::ProductRepository.all.any? { |p| p[:name] == 'New Product' }).to be true
        end
      end

      context 'with invalid JSON' do
        it 'returns 400 when JSON is malformed' do
          post '/products', 'invalid{json', valid_headers
          
          expect(last_response.status).to eq(400)
          expect(json_response['error']).to eq('Invalid JSON format')
        end
      end

      context 'with invalid parameters' do
        it 'returns 400 when name is missing' do
          post '/products', {}.to_json, valid_headers
          
          expect(last_response.status).to eq(400)
          expect(json_response['error']).to eq('Product name is required')
        end

        it 'returns 422 when name already exists' do
          Repositories::ProductRepository.create('Duplicate')
          post '/products', { name: 'Duplicate' }.to_json, valid_headers
          
          expect(last_response.status).to eq(422)
          expect(json_response['error']).to eq('Product name already exists')
        end
      end
    end

    context 'when not authenticated' do
      before do
        stub_authentication(authenticated: false)
        post '/products', { name: 'Test' }.to_json, valid_headers
      end

      it_behaves_like 'unauthenticated user'
    end
  end

  describe 'DELETE /products/:id' do
    context 'when authenticated' do
      before { stub_authentication }

      context 'when product exists' do
        let(:product_id) { Repositories::ProductRepository.create('To Delete') }

        it 'deletes the product' do
          delete "/products/#{product_id}"
          
          expect(last_response.status).to eq(200)
          expect(json_response['message']).to eq('Product deleted successfully')
          expect(Repositories::ProductRepository.find(product_id)).to be_nil
        end
      end

      context 'when product does not exist' do
        it 'returns 404' do
          delete '/products/999'
          
          expect(last_response.status).to eq(404)
          expect(json_response['error']).to eq('Product not found')
        end
      end
    end

    context 'when not authenticated' do
      before do
        stub_authentication(authenticated: false)
        delete '/products/1'
      end

      it_behaves_like 'unauthenticated user'
    end
  end

  private

  def stub_authentication(authenticated: true)
    allow_any_instance_of(Middlewares::Authentication).to receive(:authenticated?)
      .and_return(authenticated)
  end
end
