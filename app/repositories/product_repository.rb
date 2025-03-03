# frozen_string_literal: true

require 'concurrent'

module Repositories
  # ProductRepository - Repository for products
  class ProductRepository
    POOL_EXECUTOR = Concurrent::ThreadPoolExecutor.new(
      min_threads: 2,
      max_threads: 8,
      max_queue: 100,
      fallback_policy: :abort
    )

    @products = Concurrent::Map.new
    @last_id = Concurrent::AtomicFixnum.new(0)

    class << self
      def all
        @products.values
      end

      def find(id)
        @products[id]
      end

      def create(name)
        LOGGER.info("Starting product async creation for '#{name}'")
        POOL_EXECUTOR.post do
          sleep 5
          product_id = create_product(name)
          LOGGER.info("Product '#{name}' created successfully with id #{product_id}")
        end
      rescue Concurrent::RejectedExecutionError => e
        LOGGER.error("Product creation rejected: #{e.message}")
      end

      def delete(id)
        @products.delete(id)
      end

      def find_by_name?(name)
        @products.values.any? { |product| product[:name].downcase == name.downcase }
      end

      private

      def create_product(name)
        id = @last_id.increment
        @products[id] = {
          id: id,
          name: name
        }
        id
      end
    end
  end
end
