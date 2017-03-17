require_relative 'base'

module Embulk
  module Input
    class GoogleSpreadsheets < InputPlugin
      module Typecast
        class MinimalTypecast < Base

          def as_string(value)
            return nil if null_string?(value)
            value
          end

          def as_long(value)
            return nil if null_string?(value)
            value.to_i
          end

          def as_double(value)
            return nil if null_string?(value)
            value.to_f
          end

          def as_boolean(value)
            return nil if null_string?(value)
            case value.downcase
            when 'true'
              true
            when 'false'
              false
            else
              nil
            end
          end

          def as_timestamp(value, timestamp_format, timezone)
            return nil if null_string?(value)
            Time.parse(value)
          rescue ArgumentError => e
            raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast #{value.class} to Time: \"#{value}\" because of '#{e}'"
          end

          def as_json(value)
            return nil if null_string?(value)
            JSON.parse(value)
          rescue JSON::ParserError => e
            raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast #{value.class} to JSON: \"#{value}\" because of '#{e}'"
          end

        end
      end
    end
  end
end
