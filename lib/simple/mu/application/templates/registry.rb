module Simple
  module Mu
    module Application
      module Templates 
        module Registry 
          
          class ServiceRegisteryError < StandardError ; end
          
          @@templates = Hash.new{ |hash, key| raise("message #{key} not found") } 

          def self.register(topic_name, event_name, version, **payload_definition)
            raise "template already defined for #{key(topic_name, event_name, version)}" if @@templates.has_key?(key(topic_name, event_name, version))
            @@templates[key(topic_name,event_name,version)] = { event_name: event_name, version: version, payload_definition: payload_definition }
          end
          
          def self.deregister(topic_name, event_name, version)
            @@templates.delete(key(topic_name,event_name,version)) 
          end

          def self.template(topic_name, event_name, version)
            @@templates[key(topic_name,event_name,version)]
          end

          def self.key(topic_name, event_name, version)
            "#{topic_name}_#{event_name}_#{version}"
          end
        end
      end
    end
  end
end
