# frozen_string_literal: true

# data_service.rb

require_relative 'customer'
require_relative 'address'
require_relative 'data_loader'

class DataService
  class << self
    def load_customers_and_addresses
      data = DataLoader.load_data
      customers_data, addresses_data = data.partition { |record| record[:type] == 'Customer' }

      customers = customers_data.map { |record| Customer.new(record.except(:type)) }
      addresses = addresses_data.map { |record| Address.new(record.except(:type)) }

      associate_addresses_with_customers(customers, addresses)
      associate_customers_with_addresses(customers, addresses)

      { customers: customers, addresses: addresses }
    end

    private

    def associate_addresses_with_customers(customers, addresses)
      customers.each do |customer|
        customer.addresses = addresses.select { |address| address.customer_id == customer.id }
      end
    end

    def associate_customers_with_addresses(customers, addresses)
      addresses.each do |address|
        address.customer = customers.select { |cust| cust.id == address.customer_id }.first
      end
    end
  end
end
