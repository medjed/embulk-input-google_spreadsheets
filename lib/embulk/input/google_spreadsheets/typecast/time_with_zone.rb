require 'time'
require 'tzinfo'

module Embulk
  module Input
    class GoogleSpreadsheets < InputPlugin
      module Typecast
        class TimeWithZone
          # cf. http://qiita.com/sonots/items/2a318e1c9a52c0046751

          # [+-]HH:MM, [+-]HHMM, [+-]HH
          NUMERIC_PATTERN = %r{\A[+-]\d\d(:?\d\d)?\z}

          # UTC or Region/Zone, Region/Zone/Zone
          NAME_PATTERN = %r{\A(UTC|[^/]+/[^/]+(/[^/]+)?)\z}

          # NOTE: DO NOT use if your date string already has a timezone info like '+09:00'.
          def self.time_parse_with_zone(date, timezone)
            time = Time.parse(date)
            time_overwritten_by_zone(time, timezone)
          end

          def self.strptime_with_zone(date, format, timezone)
            time = Time.strptime(date, format)

            if include_zone_format?(format)
              _zone_offset = zone_offset(timezone)
              time.localtime(_zone_offset)
            else
              time_overwritten_by_zone(time, timezone)
            end
          end

          private

          def self.zone_offset(timezone)
            if NUMERIC_PATTERN === timezone
              Time.zone_offset(timezone)
            elsif NAME_PATTERN === timezone
              tz = TZInfo::Timezone.get(timezone)
              tz.current_period.utc_total_offset
            else
              raise ConfigError.new "`google_spreadsheets`: timezone format is invalid: #{timezone}"
            end
          end

          # http://docs.ruby-lang.org/en/2.3.0/Time.html#method-i-strftime
          # Time zone:
          #   %z - Time zone as hour and minute offset from UTC (e.g. +0900)
          #           %:z - hour and minute offset from UTC with a colon (e.g. +09:00)
          #           %::z - hour, minute and second offset from UTC (e.g. +09:00:00)
          #   %Z - Abbreviated time zone name or similar information.  (OS dependent)
          #
          # Literal string:
          #   %% - Literal `%` character
          ZONE_FORMAT_PATTERN = %r{([^%]|\A)%{2}*%:{,2}[zZ]}

          def self.include_zone_format?(format)
            ZONE_FORMAT_PATTERN === format
          end

          def self.time_overwritten_by_zone(time, timezone)
            _utc_offset = time.utc_offset
            _zone_offset = zone_offset(timezone)
            time.localtime(_zone_offset) + _utc_offset - _zone_offset
          end
        end
      end
    end
  end
end
