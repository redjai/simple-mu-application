require_relative 'http'
require_relative 's3'
require_relative 'sns'
require_relative 'sqs'

module Simple
  module Mu
    module Application
      module EventAdapters
        module Adapter

          def self.events(aws_event:, context:)
            if aws_event['httpMethod'] # annoyingly there is no aws::http event source in a lambda event generated by http
              [Simple::Mu::Application::EventAdapters::Http.new(aws_event)]
            elsif aws_event['Records']
              aws_event['Records'].collect do |record|
                if record['EventSource'] == 'aws:sns'
                  Simple::Mu::Application::EventAdapters::SnsRecord.new(record)
                elsif record['eventSource'] == 'aws:sqs'
                  Simple::Mu::Application::EventAdapters::SqsRecord.new(record)
                elsif record['eventSource'] == 'aws:s3'
                  Simple::Mu::Application::EventAdapters::S3Record.new(record)
                else
                  raise "unexpected aws event record"
                end
              end
            else
              raise "unexpected aws event #{aws_event}"
            end
          end
        end
      end
    end
  end
end

