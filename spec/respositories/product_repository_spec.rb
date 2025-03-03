# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Repositories::ProductRepository do
  describe '.all' do
    context 'when there are no products' do
      it 'returns an empty array' do
        expect(described_class.all).to be_empty
      end
    end

    context 'when there are products' do
      before do
        allow(described_class).to receive(:create) do |name|
          id = described_class.instance_variable_get(:@last_id).increment
          products = described_class.instance_variable_get(:@products)
          products[id] = { id: id, name: name }
          id
        end
        
        described_class.create('Test Product 1')
        described_class.create('Test Product 2')
      end

      it 'returns all products' do
        products = described_class.all
        
        expect(products.length).to eq(2)
        expect(products.map { |p| p[:name] }).to contain_exactly('Test Product 1', 'Test Product 2')
      end
    end
  end

  describe '.find' do
    context 'when product exists' do
      let(:product_id) do
        allow(described_class).to receive(:create) do |name|
          id = described_class.instance_variable_get(:@last_id).increment
          products = described_class.instance_variable_get(:@products)
          products[id] = { id: id, name: name }
          id
        end
        
        described_class.create('Test Product')
      end

      it 'returns the product' do
        product = described_class.find(product_id)
        
        expect(product).to include(
          id: product_id,
          name: 'Test Product'
        )
      end
    end

    context 'when product does not exist' do
      it 'returns nil' do
        expect(described_class.find(999)).to be_nil
      end
    end
  end

  describe '.create' do
    context 'when queue is not full' do
      before do
        allow_any_instance_of(Object).to receive(:sleep)
        allow(described_class::POOL_EXECUTOR).to receive(:post) do |&block|
          block.call
        end
      end

      it 'creates a product asynchronously' do
        described_class.create('Async Product')
        
        described_class::POOL_EXECUTOR.shutdown
        described_class::POOL_EXECUTOR.wait_for_termination

        product = described_class.all.find { |p| p[:name] == 'Async Product' }
        expect(product).not_to be_nil
      end

      it 'logs product creation' do
        described_class.create('Logged Product')

        described_class::POOL_EXECUTOR.shutdown
        described_class::POOL_EXECUTOR.wait_for_termination

        product = described_class.all.find { |p| p[:name] == 'Logged Product' }
        expect(product).not_to be_nil
      end
    end

    context 'when queue is full' do
      before do
        allow(described_class::POOL_EXECUTOR).to receive(:post).and_raise(Concurrent::RejectedExecutionError)
      end

      it 'logs error when creation is rejected' do
        expect(LOGGER).to receive(:error).with(/Product creation rejected/)
        described_class.create('Rejected Product')
      end
    end
  end

  describe '.delete' do
    let(:product_id) do
      allow(described_class).to receive(:create) do |name|
        id = described_class.instance_variable_get(:@last_id).increment
        products = described_class.instance_variable_get(:@products)
        products[id] = { id: id, name: name }
        id
      end
      
      described_class.create('To Delete')
    end

    it 'removes the product' do
      expect { described_class.delete(product_id) }
        .to change { described_class.find(product_id) }
        .from(hash_including(id: product_id))
        .to(nil)
    end
  end

  describe '.find_by_name?' do
    before do
      allow(described_class).to receive(:create) do |name|
        id = described_class.instance_variable_get(:@last_id).increment
        products = described_class.instance_variable_get(:@products)
        products[id] = { id: id, name: name }
        id
      end
      
      described_class.create('Existing Product')
    end

    context 'when name exists' do
      it 'returns true for exact match' do
        expect(described_class.find_by_name?('Existing Product')).to be true
      end

      it 'returns true for case-insensitive match' do
        expect(described_class.find_by_name?('EXISTING PRODUCT')).to be true
        expect(described_class.find_by_name?('existing product')).to be true
      end
    end

    context 'when name does not exist' do
      it 'returns false' do
        expect(described_class.find_by_name?('Non-existent Product')).to be false
      end
    end
  end
end