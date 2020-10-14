require 'simple/mu/application/support/hash'
require 'simple/mu/application/support/array'

module Simple
  module Mu
    module Application
      module Events
        class HttpEventAdapter

          def initialize(event)
            @event = event
          end

          def path 
            @event['requestContext']['path']  
          end

          def method
            @event['requestContext']['httpMethod']
          end

          def payload
            JSON.parse(body).deep_symbolize_keys! 
          end

          def body 
            @event['body']
          end

        end
      end
    end
  end
end
