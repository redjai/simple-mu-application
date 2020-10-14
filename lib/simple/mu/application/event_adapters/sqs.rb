require 'json'

module Simple 
  module Mu
    module Application
      module EventAdapters

        class SqsRecord

          attr_reader :record

          def initialize(record)
            @record = record
          end

          def payload
            body.deep_symbolize_keys!
          end

          def body 
            JSON.parse(record['body'])
          end

        end
      end
    end
  end
end
