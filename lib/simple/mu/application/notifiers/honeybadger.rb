require 'honeybadger'
module Simple 
  module Mu
    module Application
      module Notifiers
        class Honeybadger
          def notify(standard_error)
            return if ENV['HONEYBADGER_API_KEY'].nil?

            opts = {sync: true} #sync true is important as we have no background worker thread

            if standard_error.respond_to?(:response)
              opts[:context] = { response:  standard_error.response }
            end

            ::Honeybadger.notify(standard_error, opts)
          end
        end
      end
    end
  end
end
