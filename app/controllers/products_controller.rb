# frozen_string_literal: true

require 'concurrent'
require 'json'
require_relative '../repositories/product_repository'
require_relative '../../lib/formatters/response_formatter'
require_relative '../services/product_creator'

# ProductsController - Handles product operations
class ProductsController
  include ResponseFormatter
  include Repositories

  def index(_request, response)
    formatted_response(response, { products: ProductRepository.all }, status: 200)
  end

  def show(request, response)
    product_id = request.path_info.split('/').last.to_i
    product = ProductRepository.find(product_id)
    return formatted_response(response, { product: product }, status: 200) if product

    formatted_response(response, { error: 'Product not found' }, status: 404)
  end

  def create(request, response)
    params = JSON.parse(request.body.read)
    Services::ProductCreator.call(params)
    formatted_response(response, { message: 'Product creation in progress' }, status: 202)
  rescue JSON::ParserError
    formatted_response(response, { error: 'Invalid JSON format' }, status: 400)
  rescue TypeError => e
    formatted_response(response, { error: e.message }, status: 400)
  rescue ArgumentError => e
    formatted_response(response, { error: e.message }, status: 422)
  end

  def delete(request, response)
    id = request.path_info.split('/').last.to_i
    return formatted_response(response, { error: 'Product not found' }, status: 404) unless ProductRepository.find(id)

    ProductRepository.delete(id)
    formatted_response(response, { message: 'Product deleted successfully' }, status: 200)
  end
end
