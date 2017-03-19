require_relative 'strict_typecast'

module Embulk
  module Input
    class GoogleSpreadsheets < InputPlugin
      module Typecast
        class LooseTypecast < StrictTypecast
          def as_string(value)
            begin
              super
            rescue => e
              if e.is_a?(TypecastError)
                logger.trace{"`embulk-input-google_spreadsheets`: Fallback to nil, because of '#{e}'"}
                return nil
              end
              raise e
            end
          end

          def as_long(value)
            begin
              super
            rescue => e
              if e.is_a?(TypecastError)
                logger.trace{"`embulk-input-google_spreadsheets`: Fallback to nil, because of '#{e}'"}
                return nil
              end
              raise e
            end
          end

          def as_double(value)
            begin
              super
            rescue => e
              if e.is_a?(TypecastError)
                logger.trace{"`embulk-input-google_spreadsheets`: Fallback to nil, because of '#{e}'"}
                return nil
              end
              raise e
            end
          end

          def as_boolean(value)
            begin
              super
            rescue => e
              if e.is_a?(TypecastError)
                logger.trace{"`embulk-input-google_spreadsheets`: Fallback to nil, because of '#{e}'"}
                return nil
              end
              raise e
            end
          end

          def as_timestamp(value, timestamp_format = nil, timezone = nil)
            begin
              super
            rescue => e
              if e.is_a?(TypecastError)
                logger.trace{"`embulk-input-google_spreadsheets`: Fallback to nil, because of '#{e}'"}
                return nil
              end
              raise e
            end
          end

          def as_json(value)
            begin
              super
            rescue => e
              if e.is_a?(TypecastError)
                logger.trace{"`embulk-input-google_spreadsheets`: Fallback to nil, because of '#{e}'"}
                return nil
              end
              raise e
            end
          end

        end
      end
    end
  end
end
