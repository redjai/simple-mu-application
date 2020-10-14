require 'json'

module Simple
  module Mu
    module Application
      module Topics
        module Event 
          def event(event_name:, version:, payload:)
            { event_name: event_name, version: version, payload: payload }    
          end

          def event_json(event_name:, version:, payload:)
            event(event_name: event_name, version: version, payload: payload).to_json
          end
        end
      end
    end
  end
end
