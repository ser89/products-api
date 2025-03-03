# frozen_string_literal: true

require_relative '../repositories/product_repository'

module Services
  # ProductCreator - Service for creating a product
  class ProductCreator
    include Repositories

    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @params = params
    end

    def call
      validate_product_params
      validate_unique_name
      create_product
    end

    private

    attr_reader :params

    def validate_product_params
      return if params['name'].is_a?(String) && !params['name'].strip.empty?

      raise TypeError, 'Product name is required'
    end

    def validate_unique_name
      raise ArgumentError, 'Product name already exists' if ProductRepository.find_by_name?(params['name'])
    end

    def create_product
      ProductRepository.create(params['name'])
    end
  end
end
