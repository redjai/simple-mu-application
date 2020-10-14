require_relative 'registry'

module Simple
  module Mu
    module Application
      module Templates 
        class Validator

          attr_accessor :topic_name, :event_name, :version, :payload

          def initialize(topic_name:, event_name:, version:, payload:)
            @topic_name = topic_name
            @event_name = event_name
            @version = version
            @payload = payload
          end

          def validate!
            validate
            raise (["validation errors:"] + errors).join("\n") unless errors.empty? 
          end

          def validate
            validate_bad_keys
            validate_values
          end

          def template
            @template  ||= Registry.template(topic_name, event_name, version)
          end

          def validate_bad_keys
            if !(payload.keys - template[:payload_definition].keys).empty? 
              errors << "unexpected payload keys #{payload.keys - template[:payload_definition].keys}"
            end
          end

          def validate_values
            merged_payload.each do |key, value|
              if value[:message].nil?
                errors << "#{key} is a required value" if value[:template][-1] == "!"
              else
                if [:string,:string!].include?(value[:template]) && !value[:message].is_a?(String)
                  errors << "expected [#{key}] #{value[:message]} to be a string"
                elsif [:numeric,:numeric!].include?(value[:template]) && !value[:message].is_a?(Numeric)
                  errors << "expected [#{key}] #{value[:message]} to be a number"
                elsif [:hash,:hash!].include?(value[:template]) && !value[:message].is_a?(Hash)
                  errors << "expected [#{key}] #{value[:message]} to be a hash"
                elsif [:array,:array!].include?(value[:template]) && !value[:message].is_a?(Array)
                  errors << "expected [#{key}] #{value[:message]} to be an array"
                end
              end 
            end          
          end

          def errors
            @errors ||= []
          end

          private

          def merged_payload
            @merged ||= begin
              merged = {}
              template[:payload_definition].each do |key,value|
                merged[key] = { message: payload[key], template: value }
              end
              merged
            end
          end
        end
      end
    end
  end
end
