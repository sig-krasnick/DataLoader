# frozen_string_literal: true

require_relative '../address'
require 'debug'

describe 'Address' do
  before(:all) do
    Address.load_data # Ensure data is loaded before tests
  end

  describe '.all' do
    it 'returns all addresses ordered by ID' do
      addresses = Address.all
      expect(addresses.size).to eq(10)

      address_ids = addresses.map(&:id)
      expect(address_ids).to eq([101, 102, 103, 104, 105, 106, 107, 108, 109, 110])
    end
  end

  describe '.find(id)' do
    it 'returns the correct address when passed an integer' do
      address = Address.find(101)
      expect(address.id).to eq(101)
    end

    it 'returns the correct address when passed a string' do
      address = Address.find('101')
      expect(address.id).to eq(101)
    end

    it 'returns nil when there is no address with the id passed' do
      address = Address.find(123_123)
      expect(address).to be_nil
    end
  end

  describe '.find_by(params)' do
    it 'returns the correct address when searching by id' do
      address = Address.find_by(id: '101')
      expect(address.id).to eq(101)
    end

    it 'returns the correct address when searching by street' do
      address = Address.find_by(street: '123 main st')
      expect(address.id).to eq(101)
      expect(address.street).to eq('123 Main St')
    end

    it 'returns the correct address when searching for multiple attributes' do
      address = Address.find_by(state: 'nh', postalcode: '03244')
      expect(address.id).to eq(107)
      expect(address.state).to eq('NH')
      expect(address.postalcode).to eq('03244')
    end

    it 'returns the first address ordered by ID when searching for a common attribute' do
      address = Address.find_by(state: 'nh')
      expect(address.id).to eq(101)
    end

    it 'returns nil if there is no address matching the params passed' do
      address = Address.find_by(street: '123 Main St', state: 'CT')
      expect(address).to be_nil
    end
  end

  describe '.where(params)' do
    it 'returns all addresses matching the params passed ordered by ID' do
      addresses = Address.where(city: 'Franklin')
      expect(addresses.size).to eq(5)
      expect(addresses.map(&:id)).to eq([101, 102, 103, 104, 106])
    end

    it 'returns no results if there are no address matching the params passed' do
      addresses = Address.where(state: 'CA')
      expect(addresses).to be_empty
    end
  end

  describe '#customer' do
    it 'returns the customer referenced by customer_id' do
      address = Address.find(105)
      customer = address.customer
      expect(customer.id).to eq(4)
      expect(customer.first_name).to eq('Joanne')
      expect(customer.last_name).to eq('SMITH')
    end
  end

  describe 'ordering results' do
    it 'allows chaining an order method to change the result order of the .all method' do
      addresses = Address.all.order(:id, :desc)
      expect(addresses.size).to eq(10)
      expect(addresses.map(&:id)).to eq([110, 109, 108, 107, 106, 105, 104, 103, 102, 101])

      addresses = Address.all.order(:street)
      expect(addresses.size).to eq(10)
      expect(addresses.map(&:street)).to eq([
                                              '123 Main St',
                                              '13 West Ave',
                                              '15 Apple Ave',
                                              '1655 Plum St',
                                              '3114 Creek Lane',
                                              '414 7th St',
                                              '455 Main St',
                                              '698 1st St',
                                              '895 Adams Ave',
                                              ''
                                            ])
    end

    it 'allows chaining an order method to change the result order of the .where method' do
      addresses = Address.where(city: 'Franklin').order(:id, :desc)
      expect(addresses.size).to eq(5)
      expect(addresses.map(&:id)).to eq([106, 104, 103, 102, 101])
    end
  end
end
