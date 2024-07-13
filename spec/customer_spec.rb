require_relative '../customer'
require 'debug'

# rubocop:disable Metrics/BlockLength
describe 'Customer' do
  before(:all) do
    # Load data only once
    @data_loaded ||= begin
      Customer.load_data
      # binding.break # Add a breakpoint for debugging
      true
    end
  end

  describe '.all' do
    it 'returns all of the customers ordered by ID' do
      customers = Customer.all
      expect(customers.size).to eq(10)

      customer_ids = customers.map(&:id)
      expect(customer_ids).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    end
  end

  describe '.find(id)' do
    it 'returns the correct customer when passed an integer' do
      customer = Customer.find(1)
      expect(customer.id).to eq(1)
    end

    it 'returns the correct customer when passed a string' do
      customer = Customer.find('1')
      expect(customer.id).to eq(1)
    end

    it 'returns nil when there is no customer with the id passed' do
      customer = Customer.find(123123)
      expect(customer).to be_nil
    end
  end

  describe '.find_by(params)' do
    it 'returns the correct customer when searching by id' do
      customer = Customer.find_by(id: '1')
      expect(customer.id).to eq(1)
    end

    it 'returns the correct customer when searching by email address' do
      customer = Customer.find_by(email: 'DSMITH@example.com')
      expect(customer.id).to eq(1)
      expect(customer.email).to eq('dsmith@example.com')
    end

    it 'returns the correct customer when searching for multiple attributes' do
      customer = Customer.find_by(first_name: 'adam', last_name: 'JONES')
      expect(customer.id).to eq(2)
      expect(customer.first_name).to eq('Adam')
      expect(customer.last_name).to eq('Jones')
    end

    it 'returns the first customer ordered by ID when searching for a common attribute' do
      customer = Customer.find_by(last_name: 'smith')
      expect(customer.id).to eq(1)
    end

    it 'returns nil if there is no customer matching the params passed' do
      customer = Customer.find_by(first_name: 'unknown', last_name: 'JONES')
      expect(customer).to be_nil
    end
  end

  describe '.where(params)' do
    it 'returns all customers matching the params passed ordered by ID' do
      customers = Customer.where(last_name: 'smith')
      expect(customers.size).to eq(2)
      expect(customers[0].id).to eq(1)
      expect(customers[1].id).to eq(4)
    end

    it 'returns no results if there are no customer matching the params passed' do
      customers = Customer.where(first_name: 'Juan')
      expect(customers.size).to eq(0)
    end
  end

  describe '#addresses' do
    it 'returns each of the addresses associated with the customer ordered by ID' do
      customer = Customer.find(1)
      addresses = customer.addresses
      expect(addresses.size).to eq(2)
      expect(addresses[0].id).to eq(101)
      expect(addresses[1].id).to eq(102)
    end

    it 'returns no results if there are no addresses associated with the customer' do
      customer = Customer.find(10)
      addresses = customer.addresses
      expect(addresses.size).to eq(0)
    end
  end

  describe '#billing_address' do
    it 'returns the billing address associated with the customer' do
      customer = Customer.find(1)
      billing_address = customer.billing_address
      expect(billing_address.id).to eq(102)
    end

    it 'returns nil if there is no billing address associated with the customer' do
      customer = Customer.find(3)
      expect(customer.billing_address).to be_nil
    end

    it 'returns nil if there are no addresses associated with the customer' do
      customer = Customer.find(10)
      expect(customer.billing_address).to be_nil
    end
  end

  describe 'ordering results' do
    it 'allows chaining an order method to change the result order of the .all method' do
      customers = Customer.all.order(:id, :desc)
      expect(customers.size).to eq(10)
      customer_ids = customers.map(&:id)
      expect(customer_ids).to eq([10, 9, 8, 7, 6, 5, 4, 3, 2, 1])

      customers = Customer.all.order(:first_name)
      expect(customers.size).to eq(10)
      customer_first_names = customers.map(&:first_name)
      expect(customer_first_names).to eq([
        'Adam',
        'adam',
        'Anna',
        'Brian',
        'Dan',
        'David',
        'Janet',
        'Joanne',
        ' ',
        nil
      ])
    end

    it 'allows chaining an order method to change the result order of the .where method' do
      customers = Customer.where(first_name: 'Adam').order(:id, :desc)
      expect(customers.size).to eq(2)
      customer_ids = customers.map(&:id)
      expect(customer_ids).to eq([5, 2])
    end

    it 'allows chaining an order method to change the result order of the #addresses method' do
      addresses = Customer.find(1).addresses.order(:street, :desc)
      expect(addresses.size).to eq(2)
      expect(addresses[0].id).to eq(102)
      expect(addresses[1].id).to eq(101)
    end
  end
end
# rubocop:enable Metrics/BlockLength
