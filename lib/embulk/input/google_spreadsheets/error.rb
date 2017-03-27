module Embulk
  module Input

    class GoogleSpreadsheets < InputPlugin

      module Traceable
        def initialize(e, more_msg = nil)
          message = e.is_a?(String) ? '' : "(#{e.class}) "
          message << "#{e}#{more_msg}\n"
          message << "\tat #{e.backtrace.join("\n\tat ")}\n" if e.respond_to?(:backtrace)

          while e.respond_to?(:cause) and e.cause
            # Java Exception cannot follow the JRuby causes.
            message << "Caused by (#{e.cause.class}) #{e.cause}\n"
            message << "\tat #{e.cause.backtrace.join("\n\tat ")}\n" if e.cause.respond_to?(:backtrace)
            e = e.cause
          end

          super(message)
        end
      end

      class ConfigError < ::Embulk::ConfigError
        include Traceable
      end

      class DataError < ::Embulk::DataError
        include Traceable
      end

      class TypecastError < DataError
      end

    end
  end
end
