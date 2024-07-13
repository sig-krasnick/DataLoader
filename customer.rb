require_relative 'data_loader'
require_relative 'address'

class Customer
  attr_accessor :id, :first_name, :last_name, :email, :billing_address
  attr_accessor :addresses

  @customers = []
  @addresses = []

  class << self
    def load_data
      data = DataLoader.load_data
      data.each do |record|
        if record[:type] == 'Customer'
          customer = new(record)
          @customers << customer
        elsif record[:type] == 'Address'
          address = Address.new(record)
          @addresses << address
          customer = find(address.customer_id )
          customer.addresses << address if customer
        end
      end
      all.each do |record|
        record.addresses = @addresses.select { |address| address.customer_id == record.id }
      end
      puts "Loaded #{@customers.size} customers and #{@addresses.size} addresses"
    end

    def all
      @customers.sort_by(&:id)
    end

    def find(id)
      @customers.find { |customer| customer.id == id.to_i }
    end

    def find_by(params)
      result = all
    
      params.each do |key, value|
        if key.to_sym == :id
          return find(value)
        else
          normalized_value = value.is_a?(String) ? value.downcase : value
          result = result.select { |customer| customer.send(key).to_s.downcase == normalized_value.to_s }
        end
      end
    
      result.first
    end

    def where(params)
      result = @customers
      params.each do |key, value|
        result = result.select { |customer| customer.send(key)&.casecmp?(value.to_s) }
      end
      result.sort_by(&:id)
    end
  end

  def initialize(attributes)
    @id = attributes[:id]
    @first_name = attributes[:first_name]
    @last_name = attributes[:last_name]
    @email = attributes[:email]
    @addresses = []
  end

  def addresses
    @addresses.sort_by(&:id)
  end

  def billing_address
    @addresses.find { |address| address.billing_address.billing_address==true }
  end

  def addresses=(new_addresses)
    @addresses = new_addresses
  end

end

class Array
  def order(attribute, direction = :asc)
    sorted = sort_by { |item| item.send(attribute) }
    direction == :desc ? sorted.reverse : sorted
  end
end

# Load data initially
# Customer.load_data
