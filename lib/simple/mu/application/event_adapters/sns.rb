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

          def event 
            message.deep_symbolize_keys!
          end

          def delete?
            false
          end

          def to_s 
            "sns::#{record['Sns']['MessageId']}"
          end

          private

          def message 
            JSON.parse(record['Sns']['Message'])
          end

        end
      end
    end
  end
end
