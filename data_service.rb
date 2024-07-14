# frozen_string_literal: true

class DataService
  def initialize(data)
    @data = data
    @customers = []
    @addresses = []
    parse_data
  end

  def parse_data
    @data.each do |record|
      if record[:type] == 'Customer'
        customer = Customer.new(record)
        @customers << customer
      elsif record[:type] == 'Address'
        address = Address.new(record)
        customer = @customers.find { |cust| cust.id == address.customer_id }
        customer.addresses << address if customer
        @addresses << address
      end
    end
  end

  def find_customer_by_id(id)
    @customers.find { |customer| customer.id == id }
  end

  def find_address_by_id(id)
    @addresses.find { |address| address.id == id }
  end
end
