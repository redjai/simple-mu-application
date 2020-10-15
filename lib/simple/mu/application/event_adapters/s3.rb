module Simple 
  module Mu
    module Application 
      module EventAdapters
        class S3Record

          attr_accessor :record

          def initialize(record)
            @record = record
          end

          def event_name
            metadata['event_name']
          end

          def payload
            { key: key, bucket: bucket }
          end

          def bucket
            record['s3']['bucket']['name']
          end

          def key
            record['s3']['object']['key']
          end
        end
      end
    end
  end
end
