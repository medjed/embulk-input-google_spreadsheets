require 'time_with_zone'
require_relative 'base'
require_relative 'timestamp_format_util'

module Embulk
  module Input
    class GoogleSpreadsheets < InputPlugin
      module Typecast
        class MinimalTypecast < Base

          def as_string(value)
            return nil if value.nil?
            return nil if null_string?(value)
            value.to_s
          rescue NoMethodError => e
            raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast #{value.class} to String: \"#{value}\" because of '#{e}'"
          end

          def as_long(value)
            return nil if value.nil?
            return nil if null_string?(value)
            value.to_i
          rescue NoMethodError => e
            raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast #{value.class} to Long: \"#{value}\" because of '#{e}'"
          end

          def as_double(value)
            return nil if value.nil?
            return nil if null_string?(value)
            value.to_f
          rescue NoMethodError => e
            raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast #{value.class} to Double: \"#{value}\" because of '#{e}'"
          end

          def as_boolean(value)
            return nil if value.nil?
            return nil if null_string?(value)

            case value
            when TrueClass, FalseClass
              value
            when String
              value = value.downcase
              case value
              when 'true'
                true
              when 'false'
                false
              else
                raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast '#{value}' to a boolean value."
              end
            else
              raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast #{value.class} to a boolean value: \"#{value}\""
            end
          end

          def as_timestamp(value, timestamp_format = nil, timezone = nil)
            return nil if value.nil?
            return nil if null_string?(value)

            if timestamp_format and TimestampFormatUtil.timezone_format?(timestamp_format)
              Time.strptime(value, timestamp_format)
            elsif timestamp_format and timezone
              TimeWithZone.strptime_with_zone(value, timestamp_format, timezone)
            elsif timezone
              TimeWithZone.parse_with_zone(value, timezone)
            elsif timestamp_format
              Time.strptime(value, timestamp_format)
            else
              Time.parse(value)
            end
          rescue ArgumentError, TypeError, NoMethodError => e
            raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast #{value.class} to Time: \"#{value}\" because of '#{e}'"
          end

          def as_json(value)
            return nil if value.nil?
            return nil if null_string?(value)

            # cf. https://github.com/embulk/embulk/blob/191ffd50e555565be77f810db15a21ba66cb7bf6/lib/embulk/page_builder.rb#L20
            # cf. https://github.com/embulk/embulk/blob/191ffd50e555565be77f810db15a21ba66cb7bf6/embulk-core/src/main/java/org/embulk/spi/util/DynamicPageBuilder.java#L97
            # cf. https://github.com/embulk/embulk/blob/191ffd50e555565be77f810db15a21ba66cb7bf6/embulk-core/src/main/java/org/embulk/spi/util/DynamicColumnSetterFactory.java#L66
            # cf. https://github.com/embulk/embulk/blob/997c7beb89d42122f7cb6fe844f8ca79a3cb666c/embulk-core/src/main/java/org/embulk/spi/util/dynamic/JsonColumnSetter.java#L50
            # cf. https://github.com/embulk/embulk/blob/191ffd50e555565be77f810db15a21ba66cb7bf6/embulk-core/src/main/java/org/embulk/spi/util/dynamic/AbstractDynamicColumnSetter.java#L47
            # cf. https://github.com/embulk/embulk/blob/191ffd50e555565be77f810db15a21ba66cb7bf6/embulk-core/src/main/java/org/embulk/spi/json/RubyValueApi.java#L57
            # NOTE: As long as reading the above code, any object can be set as Json
            #       (that must be primitive type or must have `to_msgpack` method.)
            case value
            when TrueClass, FalseClass, Integer, Float, Array, Hash
              value
            when String
              begin
                JSON.parse(value)
              rescue JSON::ParserError => e
                raise TypecastError.new "`embulk-input-google_spreadsheets`: cannot typecast #{value.class} to JSON: \"#{value}\" because of '#{e}'"
              end
            when Time
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
