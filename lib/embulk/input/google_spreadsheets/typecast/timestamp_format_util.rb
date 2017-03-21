module Embulk
  module Input
    class GoogleSpreadsheets < InputPlugin
      module Typecast
        module TimestampFormatUtil

          def self.timezone_format?(format)
            @cache ||= {}
            return @cache[format.dup] if @cache.has_key?(format)
            @cache[format] = tz_regexp === format
          end

          private

          def self.tz_regexp
            # Time zone:
            #   %z - Time zone as hour and minute offset from UTC (e.g. +0900)
            #          %:z - hour and minute offset from UTC with a colon (e.g. +09:00)
            #          %::z - hour, minute and second offset from UTC (e.g. +09:00:00)
            #   %Z - Abbreviated time zone name or similar information.  (OS dependent)
            #
            # ref. https://docs.ruby-lang.org/en/2.3.0/Time.html#method-i-strftime
            @tz_regexp ||= %r{(?:\A|[^%]|(?:%%)+)%(?::?:?z|Z)}
          end
        end
      end
    end
  end
end
