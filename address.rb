# frozen_string_literal: true

require 'json'
require_relative 'customer'
require_relative 'data_service'

class Address
  attr_accessor :customer
  attr_reader :id, :customer_id, :street, :city, :state, :postalcode, :billing_address

  @addresses = []

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
      data = DataService.load_customers_and_addresses
      @addresses = data[:addresses]
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
  end
end
