require 'json'
require_relative 'customer'
require_relative 'data_loader'

class Address
  attr_reader :id, :customer_id, :street, :city, :state, :postalcode, :billing_address
  attr_reader :customer

  @addresses = []
  @customers = []

  class << self
    def load_data
      data = DataLoader.load_data
      data.each do |record|
        if record[:type] == 'Customer'
          customer = Customer.new(record)
          @customers << customer
        elsif record[:type] == 'Address'
          address = Address.new(record)
          address.customer = @customers.find { |cust| cust.id == address.customer_id }
          @addresses << address
        end
      end
      puts "Loaded #{@addresses.size} addresses"
    end

    def all
      @addresses.sort_by(&:id)
    end

    def find(id)
      @addresses.find { |address| address.id == id.to_i }
    end

    def find_by(params)
      result = all
    
      params.each do |key, value|
        if key.to_sym == :id
          return find(value)
        else
          normalized_value = value.is_a?(String) ? value.downcase : value
          result = result.select { |address| address.send(key).to_s.downcase == normalized_value.to_s }
        end
      end
    
      result.first
    end

    def where(params)
      result = @addresses
      params.each do |key, value|
        result = result.select{ |address| address.send(key)&.casecmp?(value.to_s) }
      end
      result.sort_by(&:id)
    end
  end

  def initialize(attributes = {})
    @id = attributes[:id]
    @customer_id = attributes[:customer_id]
    @street = attributes[:street]
    @city = attributes[:city]
    @state = attributes[:state]
    @postalcode = attributes[:postalcode]
    @customer = nil
  end

  def customer=(new_customer)
    @customer = new_customer
  end
end
