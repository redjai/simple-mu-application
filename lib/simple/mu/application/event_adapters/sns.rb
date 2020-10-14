require 'json'

module Simple 
  module Mu
    module Application
      module EventAdapters
        class SnsRecord

          attr_reader :record, :context

          def initialize(record)
            @record = record
          end

          def event_name
            message['event_name']
          end

          def payload
            message.deep_symbolize_keys!
          end

          def message 
            JSON.parse(record['Sns']['Message'])
          end

        end
      end
    end
  end
end
