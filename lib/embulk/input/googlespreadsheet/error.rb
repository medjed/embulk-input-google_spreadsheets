module Embulk
  module Input
    class Googlespreadsheet < InputPlugin

      class ConfigError < ::Embulk::ConfigError
        def initialize(e)
          message = "(#{e.class}) #{e}.\n\t#{e.backtrace.join("\t\n")}\n"
          while e.respond_to?(:cause) and e.cause
            # Java Exception cannot follow the JRuby causes.
            message << "Caused by (#{e.cause.class}) #{e.cause}\n\t#{e.cause.backtrace.join("\t\n")}\n"
            e = e.cause
          end

          super(message)
        end
      end

      class DataError < ::Embulk::DataError
        def initialize(e)
          message = "(#{e.class}) #{e}.\n\t#{e.backtrace.join("\t\n")}\n"
          while e.respond_to?(:cause) and e.cause
            # Java Exception cannot follow the JRuby causes.
            message << "Caused by (#{e.cause.class}) #{e.cause}\n\t#{e.cause.backtrace.join("\t\n")}\n"
            e = e.cause
          end

          super(message)
        end
      end

      class CompatibilityError < DataError; end
      class TypeCastError      < DataError; end
      class UnknownTypeError   < DataError; end
    end
  end
end
