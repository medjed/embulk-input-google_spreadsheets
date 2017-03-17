module Embulk
  module Input
    class GoogleSpreadsheets < InputPlugin
      module SpreadsheetsUrlUtil

        def self.capture_id(url)
          url.scan(capture_id_regex).first.first
        end

        def self.base_url
          @base_url ||= 'https://docs.google.com/spreadsheets/d/'
        end

        def self.capture_id_regex
          @capture_id_regex ||= %r{#{base_url}([^/]+)/.*}
        end
      end
    end
  end
end

