# frozen_string_literal: true

class BlockNotGivenError < StandardError; end

def test1
  puts 'inside method'
  yield if block_given?
  puts 'finishing method'
end

test1 { puts 'hello from block' }
test1

def test2
  raise BlockNotGivenError, 'Block not provided' unless block_given?

  yield [1, 2, 3].sample
end

test2 { |n| puts "I received #{n}" }

class Array
  def r_each(&block)
    raise BlockNotGivenError unless block_given?

    each { |item| block.call(item) }
  end
end

[1, 2, 3].r_each { |item| puts item }

class Client
  class << self
    def config
      @config ||= Struct.new(:api_key, :logger, :ssl).new
    end

    def configure
      raise BlockNotGivenError unless block_given?

      yield(config)
    end

    def api_key
      config.api_key
    end

    def logger
      config.logger
    end

    def ssl
      config.ssl
    end
  end
end

Client.configure do |config|
  config.api_key = 'abc'
  config.logger  = true
  config.ssl     = false
end

puts Client.config.api_key
# Or
puts Client.api_key

# In Rails Application
require 'active_support'

class ApiClient
  include ActiveSupport::Configurable
end

client = ApiClient.new
client.config.api_key = 'abc'
client.config.ssl = true

puts client.config.api_key
puts client.config.ssl

# Or
ApiClient.configure do |config|
  config.api_key = 'abc'
  config.ssl = true
end

puts ApiClient.config.api_key
puts ApiClient.config.ssl

# You can provide cofig accessor
class XeroClient
  include ActiveSupport::Configurable

  config_accessor :client_id, :client_secret
end

XeroClient.configure do |config|
  config.api_key = 'abc'
  config.client_id = 1
  config.client_secret = 'foo'
end

puts XeroClient.client_id # 1
puts XeroClient.client_secret # foo
