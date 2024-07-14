# frozen_string_literal: true

require 'json'
require_relative 'customer'
require_relative 'data_loader'

class Address
  attr_accessor :customer
  attr_reader :id, :customer_id, :street, :city, :state, :postalcode, :billing_address

  @addresses = []
  @customers = []

  def initialize(attributes = {})
    @id = attributes[:id]
    @customer_id = attributes[:customer_id]
    @billing_address = attributes[:billing_address]
    @street = attributes[:street]
    @city = attributes[:city]
    @state = attributes[:state]
    @postalcode = attributes[:postalcode]
    @customer = nil
  end

  class << self
    def load_data
      customers, addresses = DataLoader.load_data.partition { |record| record[:type] == 'Customer' }

      @customers = customers.map { |record| Customer.new(record) }
      @addresses = addresses.map { |record| Address.new(record) }

      associate_customers_with_addresses

      puts "Loaded #{@customers.size} customers and #{@addresses.size} addresses"
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
        return find(value) if key.to_sym == :id

        normalized_value = value.is_a?(String) ? value.downcase : value
        result = result.select { |address| address.send(key).to_s.downcase == normalized_value.to_s }
      end

      result.first
    end

    def where(params)
      result = @addresses
      params.each do |key, value|
        result = result.select { |address| address.send(key)&.casecmp?(value.to_s) }
      end
      result.sort_by(&:id)
    end

    private

    def associate_customers_with_addresses
      @addresses.each do |address|
        address.customer = @customers.find { |cust| cust.id == address.customer_id }
      end
    end
  end
end
