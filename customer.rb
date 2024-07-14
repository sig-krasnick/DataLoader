# frozen_string_literal: true

require 'active_model'
require_relative 'data_service'
require_relative 'address'

class Customer
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :integer
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :email, :string
  attr_accessor :addresses

  @customers = []

  def initialize(attributes = {})
    super
    @addresses ||= []
  end

  def addresses
    @addresses.sort_by(&:id)
  end

  def billing_address
    @addresses.find { |address| address.billing_address == true }
  end

  class << self
    def load_data
      data = DataService.load_customers_and_addresses
      @customers = data[:customers]
      puts "Loaded #{@customers.size} customers"
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
        return find(value) if key.to_sym == :id

        normalized_value = value.is_a?(String) ? value.downcase : value
        result = result.select { |customer| customer.send(key).to_s.downcase == normalized_value.to_s }
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
end

class Array
  def order(attribute, direction = :asc)
    sorted = sort_by do |item|
      value = item.send(attribute)
      case value
      when nil
        [3, nil] # nil values are placed last
      when ''
        [2, ''] # empty strings are placed before nil
      when ' '
        [1, ' '] # single space strings are placed before empty strings
      else
        [0, value.to_s.downcase == value.to_s ? 0 : 1, value] # lowercase values come after proper-cased
      end
    end

    direction == :desc ? sorted.reverse : sorted
  end
end
