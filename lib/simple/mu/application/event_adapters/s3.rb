module Simple 
  module Mu
    module Application 
      module EventAdapters
        class S3Record

          attr_accessor :record

          def initialize(record)
            @record = record
          end

          def event 
            { key: key, bucket: bucket }
          end

          def bucket
            record['s3']['bucket']['name']
          end

          def delete?
            false
          end

          def key
            record['s3']['object']['key']
          end

          def to_s 
            "s3::#{record['responseElements']['x-amz-request-id']}"
          end
        end
      end
    end
  end
end
