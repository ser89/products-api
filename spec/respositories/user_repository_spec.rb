# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Repositories::UserRepository do
  let(:username) { 'testuser' }
  let(:password) { 'testpass123' }

  before do
    described_class.instance_variable_set(:@users, Concurrent::Map.new)
  end

  describe '.create' do
    it 'creates a new user with encrypted password' do
      described_class.create(username, password)
      
      stored_password = described_class.instance_variable_get(:@users)[username]
      expect(stored_password).to be_a(BCrypt::Password)
      expect(stored_password).to start_with('$2a$')
    end

    it 'stores the user in the users map' do
      described_class.create(username, password)
      expect(described_class.exists?(username)).to be true
    end
  end

  describe '.exists?' do
    context 'when user exists' do
      before do
        described_class.create(username, password)
      end

      it 'returns true' do
        expect(described_class.exists?(username)).to be true
      end
    end

    context 'when user does not exist' do
      it 'returns false' do
        expect(described_class.exists?('nonexistent')).to be false
      end
    end
  end

  describe '.verify_credentials' do
    context 'when user exists' do
      before do
        described_class.create(username, password)
      end

      context 'with correct password' do
        it 'returns true' do
          expect(described_class.verify_credentials(username, password)).to be true
        end
      end

      context 'with incorrect password' do
        it 'returns false' do
          expect(described_class.verify_credentials(username, 'wrongpass')).to be false
        end
      end

      context 'with case-sensitive password' do
        it 'returns false for different case' do
          expect(described_class.verify_credentials(username, password.upcase)).to be false
        end
      end
    end

    context 'when user does not exist' do
      it 'returns false' do
        expect(described_class.verify_credentials('nonexistent', password)).to be false
      end
    end
  end

  describe 'password encryption' do
    it 'uses BCrypt for password encryption' do
      expect(BCrypt::Password).to receive(:create).with(password).and_call_original
      described_class.create(username, password)
    end

    it 'creates different hashes for the same password' do
      described_class.create('user1', password)
      described_class.create('user2', password)
      
      hash1 = described_class.instance_variable_get(:@users)['user1']
      hash2 = described_class.instance_variable_get(:@users)['user2']
      
      expect(hash1).not_to eq(hash2)
    end
  end
end