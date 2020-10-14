require_relative 'http'
require_relative 's3'
require_relative 'sns'

module Events 
  module V1
    module Adapters

      def self.events(aws_event:, context:)
        adapters =  if aws_event['httpMethod']
                      [Events::V1::Adapters::HttpEventAdapter.new(aws_event)]
                    elsif aws_event['Records']
                      aws_event['Records'].collect do |record|
                        if record['Sns']
                          Events::V1::Adapters::SnsRecordAdapter.new(record)
                        elsif record['s3']
                          Events::V1::Adapters::S3RecordAdapter.new(record)
                        else
                          raise "unexpected aws event record"
                        end
                      end
                    else
                      raise "unexpected aws event #{aws_event}"
                    end
        if 

        adapters.collect do |adapter|
          Events::V1::Event.new( event_name: adapter.event_name,
                                     source: adapter.source,
                              event_version: adapter.event_version,
                            payload_version: adapter.payload_version,
                                    payload: adapter.payload )
        end

      end
    end
  end
end

