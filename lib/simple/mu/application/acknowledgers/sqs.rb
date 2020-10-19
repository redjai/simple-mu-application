require 'aws-sdk-sqs'

module Simple
  module Mu
    module Application
      module Acknowledgers
        class Sqs

          def resource
            @resource ||= Aws::SQS::Resource.new(region: ENV['REGION'])
          end

          def queues
            @queues ||= {}
          end

          def queue(queue_name)
            queues[queue_name] ||= resource.get_queue_by_name(queue_name: queue_name)
          end

          def acknowledge(queue_name:, processed:)
            queue(queue_name).delete_messages(entries: entries(processed: processed)) 
          end

          def entries(processed:)
            processed.collect do |adapter|
              { id: adapter.message_id, receipt_handle: adapter.receipt_handle } 
            end
          end
        end
      end
    end
  end
end
