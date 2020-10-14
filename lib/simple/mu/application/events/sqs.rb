require 'json'

module Simple 
  module Mu
    module Application
      module Events

        class SnsRecordAdapter

          attr_reader :record

          def initialize(record)
            @record = record
          end

          def event_name
            message['event_name']
          end

          def payload
            message['payload'].deep_symbolize_keys!
          end

          def message 
            JSON.parse(record['body'])
          end

        end
      end
    end
  end
end
