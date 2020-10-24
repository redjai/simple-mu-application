require 'simple/mu/application/support/hash'
require 'simple/mu/application/support/array'

module Simple
  module Mu
    module Application
      module EventAdapters
        class Http

          attr_accessor :processed, :errored

          def initialize(event)
            @event = event
          end

          def path 
            @event['requestContext']['path']  
          end

          def method
            @event['requestContext']['httpMethod']
          end

          def event 
            JSON.parse(body).deep_symbolize_keys! 
          end

          def body 
            @event['body']
          end

          def delete?
            false
          end

          def to_s 
            "http::#{@event['requestContext']['requestId']}"
          end
        end
      end
    end
  end
end
