require 'aws-sdk-sqs'
require 'honeybadger'

module Simple
  module Mu
    module Application
      module Framework

        @@errored = []
        @@processed = []

        def self.handle(event:, context:)
          setup!
          begin
            Simple::Mu::Application::EventAdapters::Adapter.events(aws_event: event, context: context).each do |adapter| 
              begin
                yield adapter.event
                event_processed(adapter) 
              rescue StandardError => standard_error
                event_errored(adapter, standard_error)
                notify_honeybadger(standard_error) 
              end 
            end
          rescue StandardError => e
            notify_honeybadger(e)
          end

          if errors?
            delete_processed_messages!
            raise "events #{error_ids.join(",")}" #ids of events that failed, if we don't return an erro then aws will assume all messages have been processed and delete them all.
          end

          #if there are no errors let AWS delete the SQS messages naturally

        end

        def self.sqs

        end

        def self.errors?
          @@errored.any?
        end

        def self.setup!
          @@processed.clear
          @@errored.clear
        end

        def self.delete_processed_messages!
          @@errored.each do |errored|
            
          end
        end

        def self.processed_sqs_adapters
          @@processed.select do |adapter|
            adapter.is_a?(Simple::Mu::Application::EventAdapters::Sqs)
          end
        end

        def self.error_ids
          @@errored.collect do |err|
            err.first.to_s
          end
        end

        def self.errored_event(adapter, error)
          @@errored << [adapter, error]
        end

        def self.processed_event(adapter)
          @@processed = []
        end

        def self.notify_honeybadger(standard_error)
          return if ENV['HONEYBADGER_API_KEY'].nil?

          opts = {sync: true} #sync true is important as we have no background worker thread

          if e.respond_to?(:response)
             opts[:context] = { response:  err.response }
          end

          Honeybadger.notify(e, opts)
        end

        def self.broadcast(topic_name:, event_name:, version:, payload:)
          broadcaster.broadcast(topic_name, event_name, version, payload)
        end

        def self.broadcaster
          @broadcaster ||= Simple::Mu::Broadcasters::Sns.new
        end

        def self.acknowledge(message_id

        def self.acknowledger

        end

      end
    end
  end
end
