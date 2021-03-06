require 'json'

module Simple 
  module Mu
    module Application
      module EventAdapters

        class SqsRecord

          attr_accessor :record, :context, :processed, :errored

          def initialize(record)
            @record = record
          end

          def queue_name
            record['eventSourceARN'].split(":").last
          end

          def event 
            body.deep_symbolize_keys!
          end

          def body 
            JSON.parse(record['body'])
          end

          def to_s 
            "sqs::#{record['messageId']}"
          end

          def message_id
            record['messageId']
          end

          def receipt_handle
            record['receiptHandle']
          end

          def ackable?
            true 
          end

        end
      end
    end
  end
end
