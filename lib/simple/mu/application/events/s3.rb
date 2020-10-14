require 'utils/s3/data_bucket'

module Events 
  module V1
    module Adapters 
      class S3RecordAdapter

        attr_accessor :record

        def initialize(record)
          @record = record
        end

        def source
          metadata['source']
        end

        def event_name
          metadata['event_name']
        end

        def event_version
          metadata['event_version'].to_i
        end
        
        def payload_version
          metadata['payload_version'].to_i
        end

        def payload
          { key: key, body: body }
        end

        def metadata
          bucket.metadata(key)
        end

        def body
          bucket.get(key)
        end

        def bucket
          @bucket ||= Utils::S3::DataBucket.new
        end

        def key
          @key ||= URI.decode(@record['s3']['object']['key'])
        end
      end
    end
  end
end
