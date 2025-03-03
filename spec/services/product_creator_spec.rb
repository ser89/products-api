# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::ProductCreator do
  before do
    stub_sync_creation
  end

  describe '.call' do
    subject(:create_product) { described_class.call(params) }

    context 'when params are valid' do
      let(:params) { { 'name' => 'Valid Product' } }

      it 'creates a new product' do
        expect { create_product }.to change { 
          Repositories::ProductRepository.all.count 
        }.by(1)
      end

      it 'returns the created product id' do
        expect(create_product).to be_a(Integer)
      end

      it 'creates product with correct name' do
        product_id = create_product
        product = Repositories::ProductRepository.find(product_id)
        expect(product[:name]).to eq('Valid Product')
      end
    end

    context 'when validating product params' do
      context 'when name is missing' do
        let(:params) { {} }

        it 'raises TypeError' do
          expect { create_product }.to raise_error(
            TypeError,
            'Product name is required'
          )
        end
      end

      context 'when name is nil' do
        let(:params) { { 'name' => nil } }

        it 'raises TypeError' do
          expect { create_product }.to raise_error(
            TypeError,
            'Product name is required'
          )
        end
      end

      context 'when name is empty string' do
        let(:params) { { 'name' => '' } }

        it 'raises TypeError' do
          expect { create_product }.to raise_error(
            TypeError,
            'Product name is required'
          )
        end
      end

      context 'when name contains only whitespace' do
        let(:params) { { 'name' => '   ' } }

        it 'raises TypeError' do
          expect { create_product }.to raise_error(
            TypeError,
            'Product name is required'
          )
        end
      end

      context 'when name is not a string' do
        let(:params) { { 'name' => 123 } }

        it 'raises TypeError' do
          expect { create_product }.to raise_error(
            TypeError,
            'Product name is required'
          )
        end
      end
    end

    context 'when validating unique name' do
      before do
        Repositories::ProductRepository.create('Existing Product')
      end

      context 'when name already exists' do
        let(:params) { { 'name' => 'Existing Product' } }

        it 'raises ArgumentError' do
          expect { create_product }.to raise_error(
            ArgumentError,
            'Product name already exists'
          )
        end
      end

      context 'when name exists with different case' do
        let(:params) { { 'name' => 'EXISTING PRODUCT' } }

        it 'raises ArgumentError' do
          expect { create_product }.to raise_error(
            ArgumentError,
            'Product name already exists'
          )
        end
      end
    end
  end

  describe '#initialize' do
    it 'sets params instance variable' do
      params = { 'name' => 'Test Product' }
      creator = described_class.new(params)
      expect(creator.send(:params)).to eq(params)
    end
  end

  describe 'private methods' do
    let(:creator) { described_class.new(params) }

    describe '#validate_product_params' do
      subject(:validate_params) { creator.send(:validate_product_params) }

      context 'when params are valid' do
        let(:params) { { 'name' => 'Valid Product' } }

        it 'does not raise error' do
          expect { validate_params }.not_to raise_error
        end
      end

      context 'when params are invalid' do
        let(:params) { { 'name' => '' } }

        it 'raises TypeError' do
          expect { validate_params }.to raise_error(
            TypeError,
            'Product name is required'
          )
        end
      end
    end

    describe '#validate_unique_name' do
      subject(:validate_name) { creator.send(:validate_unique_name) }
      
      before do
        Repositories::ProductRepository.create('Existing Product')
      end

      context 'when name is unique' do
        let(:params) { { 'name' => 'New Product' } }

        it 'does not raise error' do
          expect { validate_name }.not_to raise_error
        end
      end

      context 'when name already exists' do
        let(:params) { { 'name' => 'Existing Product' } }

        it 'raises ArgumentError' do
          expect { validate_name }.to raise_error(
            ArgumentError,
            'Product name already exists'
          )
        end
      end
    end

    describe '#create_product' do
      subject(:create) { creator.send(:create_product) }
      
      let(:params) { { 'name' => 'New Product' } }

      it 'delegates creation to ProductRepository' do
        expect(Repositories::ProductRepository).to receive(:create).with('New Product')
        create
      end

      it 'returns the created product id' do
        expect(create).to be_a(Integer)
      end
    end
  end
end