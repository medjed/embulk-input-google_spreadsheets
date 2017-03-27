module Embulk
  module Input
    class GoogleSpreadsheets < InputPlugin
      module Typecast
        class Base

          attr_reader :null_string

          def initialize(task)
            @null_string = task['null_string']
          end

          def logger
            GoogleSpreadsheets.logger
          end

          def to_json(*args) # for logging
            spec = {JSON.create_id => self.class.name}
            spec = instance_variables.inject(spec) do |spec, v|
              spec.tap do |s|
                s[v] = instance_variable_get(v)
              end
            end
            spec.to_json(*args)
          end

          def as_string(value)
            raise NotImplementedError, '`embulk-input-google_spreadsheets`: override this.'
          end

          def as_long(value)
            raise NotImplementedError, '`embulk-input-google_spreadsheets`: override this.'
          end

          def as_double(value)
            raise NotImplementedError, '`embulk-input-google_spreadsheets`: override this.'
          end

          def as_boolean(value)
            raise NotImplementedError, '`embulk-input-google_spreadsheets`: override this.'
          end

          def as_timestamp(value, timestamp_format, timezone)
            raise NotImplementedError, '`embulk-input-google_spreadsheets`: override this.'
          end

          def as_json(value)
            raise NotImplementedError, '`embulk-input-google_spreadsheets`: override this.'
          end

          protected

          def null_string?(value)
            return false unless value.is_a?(String)
            return true if value == null_string
            return false
          end
        end
      end
    end
  end
end
