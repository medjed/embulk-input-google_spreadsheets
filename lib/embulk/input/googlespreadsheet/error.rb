module Embulk
  module Input
    class Googlespreadsheet < InputPlugin
      module Traceable
        def initialize(e)
          message = "(#{e.class}) #{e}\n"
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

      class CompatibilityError < DataError; end
      class TypeCastError      < DataError; end
      class UnknownTypeError   < DataError; end
    end
  end
end
