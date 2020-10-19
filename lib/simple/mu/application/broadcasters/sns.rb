require 'simple/mu/application/templates/validator'

module Simple
  module Mu
    module Application
      module Topics
        class Sns

          def region
            ENV['REGION']
          end

          def arn(topic_name)
            ENV[key(topic_name)]
          end

          def topics
            @topcs ||= {}
          end

          def topic(topic_name)
            topics[topic_name] ||= resource.topic(arn(topic_name))
          end
          
          def resource 
            @resource ||= Aws::SNS::Resource.new(region: ENV['REGION'])
          end

          def broadcast(topic_name, event_name, version, payload)
            Simple::Mu::Application::Templates::Validator.new(topic_name: topic_name, 
                                                              event_name: event_name,
                                                                 version: version,
                                                                 payload: payload).validate!
            topic(topic_name).publish(message: event_json(event_name: event_name, version: version, payload: payload))
          end
          
          def event(event_name:, version:, payload:)
            { event_name: event_name, version: version, payload: payload }    
          end

          def event_json(event_name:, version:, payload:)
            event(event_name: event_name, version: version, payload: payload).to_json
          end

          private

          def key(topic_name)
            "TOPIC_#{topic_name.to_s.upcase}_ARN"
          end
        end
      end
    end
  end
end
