require "json"
require "time"
require "tzinfo"


module Embulk
  module Input
    class Googlespreadsheet < InputPlugin
      class CompatibilityError < StandardError; end
      class TypeCastError < StandardError; end
      class UnknownTypeError < StandardError; end

      class TypeConverter

        DEFAULT_TIMESTAMP_FORMAT = "%Y-%m-%d %H:%M:%S"
        DEFAULT_TIMEZONE = "Asia/Tokyo"

        def convert(columns, values)
          results = Array.new
          if columns.length != values.length
            raise CompatibilityError, "Columns defined and data fetched are imcompatible."
          end

          (0...columns.length).each do |index|
            # empyty values still go empty
            if values[index] == ""
              results << ""
              next
            end

            type = columns[index]["type"].downcase
            case type
            when "boolean"
              results << to_boolean(values[index].to_s)
            when "long"
              results << values[index].to_s.to_i
            when "double"
              results << values[index].to_s.to_f
            when "string"
              results << values[index].to_s
            when "timestamp"
              results << to_timestamp(values[index].to_s, columns[index])
            when "json"
              results << to_json(values[index].to_s)
            else
              raise UnknownTypeError, "Type `#{type}` is not supported by Embulk."
            end
          end
          results
        end

        def to_boolean(value)
          if value.downcase == "true" || value == "1"
            true
          elsif value.downcase == "false" || value == "0"
            false
          else
            raise TypeCastError, "Cannot cast #{value} to embulk type boolean"
          end
        end

        def to_timestamp(value, definition)
          format = definition["format"] || DEFAULT_TIMESTAMP_FORMAT
          timezone = definition["timezone"] || DEFAULT_TIMEZONE

          begin
            strptime_with_zone(value, format, timezone)
          rescue => e
            raise TypeCastError, e.message
          end
        end

        def to_json(value)
          begin
            JSON.generate(JSON.parse(value))
          rescue => e
            raise TypeCastError, e.message
          end
        end

        private
        # strptime with timezone
        # http://qiita.com/sonots/items/2a318e1c9a52c0046751

        # [+-]HH:MM, [+-]HHMM, [+-]HH
        NUMERIC_PATTERN = %r{\A[+-]\d\d(:?\d\d)?\z}
        # Region/Zone, Region/Zone/Zone
        NAME_PATTERN = %r{\A[^/]+/[^/]+(/[^/]+)?\z}

        def strptime_with_zone(date, format, timezone)
          time = Time.strptime(date, format)
          _utc_offset = time.utc_offset
          _zone_offset = zone_offset(timezone)
          time.localtime(_zone_offset) + _utc_offset - _zone_offset
        end

        def zone_offset(timezone)
          if NUMERIC_PATTERN === timezone
            Time.zone_offset(timezone)
          elsif NAME_PATTERN === timezone
            tz = TZInfo::Timezone.get(timezone)
            tz.current_period.utc_total_offset
          elsif "UTC" == timezone # special treatment
            0
          else
            raise ArgumentError, "timezone format is invalid: #{timezone}"
          end
        end

      end
    end
  end
end
