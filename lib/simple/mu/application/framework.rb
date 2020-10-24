require 'aws-sdk-sqs'
require 'honeybadger'
require 'simple/mu/application/acknowledgers/sqs'
require 'simple/mu/application/event_adapters/adapter'
require 'simple/mu/application/notifiers/honeybadger'

module Simple
  module Mu
    module Application

      class FrameworkError < StandardError; end

      class Framework

        attr_accessor :event, :context

        def initialize(event:, context:)
          @event = event
          @context = context
        end

        def handle
          adapters.each do |adapter| 
            begin
              yield adapter
              adapter.processed = true
            rescue StandardError => standard_error
              adapter.errored = true
              notifier.notify(standard_error)
            end 
          end

          if errors?
            acknowledge_processed_adapters!
            raise Simple::Mu::Application::FrameworkError.new error_messages.join(",") #ids of events that failed, if we don't return an erro then aws will assume all messages have been processed and delete them all.
          end

          #if there are no errors let AWS delete the SQS messages naturally

        end

        def adapters
          @adapters ||= Simple::Mu::Application::EventAdapters::Adapter.events(aws_event: event, context: context)
        end
        
        def errors?
          adapters.find{ |adapter| adapter.errored }
        end

        def acknowledge_processed_adapters!
          acknowledger.acknowledge(processed: ackable_adapters)
        end

        def ackable_adapters
          adapters.select do |adapter|
            adapter.ackable? && adapter.processed
          end
        end

        def acknowledger
          @acknowledger ||= Simple::Mu::Application::Acknowledgers::Sqs.new
        end

        def errored
          adapters.select do |adapter|
            adapter.errored
          end
        end

        def error_messages
          errored(&:to_s)
        end

        def notifier
          @notifier ||= Simple::Mu::Application::Notifiers::Honeybadger.new
        end

        def broadcast(topic_name:, event_name:, version:, payload:)
          broadcaster.broadcast(topic_name, event_name, version, payload)
        end

        def broadcaster
          @broadcaster ||= Simple::Mu::Broadcasters::Sns.new
        end
      end
    end
  end
end
