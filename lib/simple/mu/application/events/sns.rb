require 'json'

module Events 
  module V1
    module Adapters
      class SnsRecordAdapter

        attr_reader :record, :context

        def initialize(record)
          @record = record
        end

        def source
          message['source']
        end

        def event_version
          message['event_version']
        end
        
        def payload_version
          message['payload_version']
        end

        def event_name
          message['event_name']
        end

        def payload
          message['payload'].symbolize_keys
        end

        def message 
          JSON.parse(record['Sns']['Message'])
        end

      end
    end
  end
end
