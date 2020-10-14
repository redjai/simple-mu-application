module Simple
  module Mu
    module Application
      module Framework
        def self.handle(event:, context:, **options)
          begin
            options[:allow] ||= []
            events = RQ::Events::AWS.rq_events(aws_event, allowed: options[:allowed])
            yield events
          rescue StandardError => e

            # if we don't have honeybadger setup (e.g. test or dev)
            raise e unless ENV['HONEYBADER_API_KEY'].present?

            opts = {sync: true} #sync true is important as we have no background worker thread

            if e.is_a?(Faraday::ClientError)
               opts[:context] = { response:  err.response }
            end

            Honeybadger.notify(e, opts)
          end
        end
      end
    end
  end
end
