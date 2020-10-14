require 'json'

module Simple
  module Mu
    module Application
      module Topics
        module Message
          def message(event_name:, version:, payload:)
            { event_name: event_name, version: version, payload: payload }    
          end

          def message_json(event_name:, version:, payload:)
            message(event_name: event_name, version: version, payload: payload).to_json
          end
        end
      end
    end
  end
end
