module Embulk
  module Input
    class GoogleSpreadsheets < InputPlugin
      module PagerUtil

        def self.num2col(num, base = default_base, offset = default_offset)
          [].tap do |r|
            while num > 0
              num -= 1
              r.unshift((num % base + offset).chr)
              num /= base
            end
          end.join
        end

        private

        def self.default_offset
          @default_offset ||= 'A'.ord
        end

        def self.default_base
          @default_base ||= 26 # number of alphabet
        end
      end
    end
  end
end
