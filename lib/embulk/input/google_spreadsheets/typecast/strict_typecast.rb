require_relative 'base'
require_relative 'time_with_zone'

module Embulk
  module Input
    class GoogleSpreadsheets < InputPlugin
      module Typecast
        class StrictTypecast < Base
          # It has assumed that argument `value` is an instance of any of the below classes.
          # NilClass
          # String
          # TrueClass
          # FalseClass
          # Integer
          # Float
          # Array
          # Hash
          # Time

          def as_string(value)
            return nil if null_string?(value)

            case value
            when nil
              nil
            when String
              value
            when TrueClass
              value.to_s
            when FalseClass
              value.to_s
            when Integer
              value.to_s
            when Float
              value.to_s
            when Array
              value.to_json
            when Hash
              value.to_json
            when Time
              # TODO: support Time class
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast Time to String: \"#{value}\""
            else
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast #{value.class} to String: \"#{value}\""
            end
          end

          def as_long(value)
            return nil if null_string?(value)

            # `to_i` issue incorrect typecast, so use Integer()
            # example
            #   [1] pry(main)> '111:222:333'.to_i
            #   => 111
            #   [2] pry(main)> Integer('111:222:333')
            #   ArgumentError: invalid value for Integer(): "111:222:333"
            #   from (pry):2:in `Integer'
            case value
            when nil
              nil
            when String
              return nil if value.is_a?(String) and value.empty?
              begin
                Integer(value)
              rescue ArgumentError => e
                raise TypecastError.new "`embulk-input-google_spreadsheets`: #{e}"
              end
            when TrueClass
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast true to Integer: \"#{value}\""
            when FalseClass
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast false to Integer: \"#{value}\""
            when Integer
              value
            when Float
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast Float to Integer: \"#{value}\""
            when Array
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast Array to Integer: \"#{value}\""
            when Hash
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast Hash to Integer: \"#{value}\""
            when Time
              value.to_i
            else
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast #{value.class} to Integer: \"#{value}\""
            end
          end

          def as_double(value)
            return nil if null_string?(value)

            # `to_f` issue incorrect typecast, so use Float()
            # example
            #   [1] pry(main)> '111:222:333'.to_f
            #   => 111.0
            #   [2] pry(main)> Float('111:222:333')
            #   ArgumentError: invalid value for Float(): "111:222:333"
            #   from (pry):2:in `Float'
            case value
            when nil
              nil
            when String, Integer
              return nil if value.is_a?(String) and value.empty?
              begin
                Float(value)
              rescue ArgumentError => e
                raise TypecastError.new "`embulk-input-google_spreadsheets`: #{e}"
              end
            when TrueClass
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast true to Float: \"#{value}\""
            when FalseClass
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast false to Float: \"#{value}\""
              # when Integer then ...
              # => merge with String case
            when Float
              value
            when Array
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast Array to Float: \"#{value}\""
            when Hash
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast Hash to Float: \"#{value}\""
            when Time
              value.to_f
            else
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast #{value.class} to Float: \"#{value}\""
            end
          end

          BOOLEAN_TRUE_VALUES = %w(yes y true t 1)
          BOOLEAN_FALSE_VALUES = %w(no n false f 0)

          def as_boolean(value)
            return nil if null_string?(value)

            case value
            when nil
              nil
            when String, Integer
              return nil if value.is_a?(String) and value.empty?
              value = value.to_s unless value.is_a?(String)
              return true if BOOLEAN_TRUE_VALUES.include?(value.downcase)
              return false if BOOLEAN_FALSE_VALUES.include?(value.downcase)
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast '#{value}' to a boolean value." \
                  " A boolean value must be one of #{BOOLEAN_TRUE_VALUES + BOOLEAN_FALSE_VALUES}: \"#{value}\""
            when TrueClass
              true
            when FalseClass
              false
              # when Integer then ... => merge with String case
            when Float
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast Float to a boolean value: \"#{value}\""
            when Array
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast Array to a boolean value: \"#{value}\""
            when Hash
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast Hash to a boolean value: \"#{value}\""
            when Time
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast Time to String: \"#{value}\""
            else
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast #{value.class} to a boolean value: \"#{value}\""
            end
          end

          def as_timestamp(value, timestamp_format = nil, timezone = nil)
            return nil if null_string?(value)

            case value
            when nil
              nil
            when String, Integer, Float
              return nil if value.is_a?(String) and value.empty?
              value = value.to_s unless value.is_a?(String)
              begin
                if timestamp_format and timezone
                  TimeWithZone.strptime_with_zone(value, timestamp_format, timezone)
                elsif timezone
                  TimeWithZone.time_parse_with_zone(value, timezone)
                elsif timestamp_format
                  Time.strptime(value, timestamp_format)
                else
                  Time.parse(value)
                end
              rescue ArgumentError => e
                raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast #{value.class} to Time: \"#{value}\" because of '#{e}'"
              end
            when TrueClass
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast true to Time: \"#{value}\""
            when FalseClass
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast false to Time: \"#{value}\""
              # when Integer
              # ... => merge with String case
              # when Float
              # ... => merge with String case
            when Array
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast Array to Time: \"#{value}\""
            when Hash
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast Hash to Time: \"#{value}\""
            when Time
              value
            else
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast #{value.class} to Time: \"#{value}\""
            end
          end

          def as_json(value)
            return nil if null_string?(value)

            # NOTE: This method must do `JSON.parse` if `value` is String. ref. https://github.com/embulk/embulk/issues/499
            case value
            when nil, Array, Hash
              value
            when String
              begin
                JSON.parse(value)
              rescue JSON::ParserError => e
                raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast #{value.class} to JSON: \"#{value}\" because of '#{e}'"
              end
              # when TrueClass  then ... => merge with Time case
              # when FalseClass then ... => merge with Time case
              # when Integer    then ... => merge with Time case
              # when Float      then ... => merge with Time case
              # when Array      then ... => merge with nil case
              # when Hash       then ... => merge with nil case
            when TrueClass, FalseClass, Integer, Float, Array, Hash, Time
              # TODO: support Time class. Now call Exception to avoid format/timezone trouble.
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast Time to JSON: \"#{value}\""

            else
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast #{value.class} to JSON: \"#{value}\""
            end
          end

        end
      end
    end
  end
end
