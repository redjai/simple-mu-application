require 'simple/mu/application/templates/validator'
require_relative 'message'

module Simple
  module Mu
    module Application
      module Topics
        class Sns
        include Simple::Mu::Application::Topics::Message

          def initialize(topic_name)
            @topic_name = topic_name
          end

          def region
            ENV['TOPIC_REGION']
          end

          def resource
            @resource ||= Aws::SNS::Resource.new(region: region)
          end

          def arn
            raise "expected ENV to define #{key}" if ENV[key].nil?
            ENV[key]
          end

          def topic
            @topic ||= resource.topic(arn)
          end

          def broadcast(event_name, version, payload)
            Simple::Mu::Application::Templates::Validator.new(topic_name: @topic_name, 
                                                         event_name: event_name,
                                                              version: version,
                                                              payload: payload).validate!
            topic.publish(message: message_json(event_name: event_name, version: version, payload: payload))
          end

          private

          def key
            "TOPIC_#{@topic_name.to_s.upcase}_ARN"
          end
        end
      end
    end
  end
end
