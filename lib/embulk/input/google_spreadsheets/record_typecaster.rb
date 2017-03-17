require_relative 'typecast_factory'

module Embulk
  module Input
    class GoogleSpreadsheets < InputPlugin
      class RecordTypecaster

        attr_reader :column_names, :column_details

        def initialize(task)
          @column_names = task['columns'].map{|c| c['name']}
          @column_details = configure_column_details(task)
        end

        def configure_column_details(task)
          _column_details = task['columns'].dup.each_with_index.inject({}) do |details, column_with_index|
            c, i = *column_with_index
            details.tap do |ds|
              ds[c['name']] = {}.tap do |d|
                d['index'] = i
                d['name'] = c['name']
                d['type'] = c['type'].to_sym
                d['format'] = c['format']
                d['timezone'] = c['timezone']
                d['typecast'] = TypecastFactory.create(c['typecast'], task)
              end
            end
          end

          logger.debug { "`embulk-input-google_spreadsheets`: configured column details '#{_column_details.to_json}'"}
          _column_details
        end

        def logger
          GoogleSpreadsheets.logger
        end

        def transform_by_columns(record)
          column_names.map do |n|
            d = column_details[n]
            typecast = d['typecast']
            value = record[d['index']]
            type = d['type']

            begin
              case type
              when :string
                typecast.as_string(value)
              when :long
                typecast.as_long(value)
              when :double
                typecast.as_double(value)
              when :boolean
                typecast.as_boolean(value)
              when :timestamp
                typecast.as_timestamp(value, d['format'], d['timezone'])
              when :json
                typecast.as_json(value)
              else
                raise ConfigError.new("`google_spreadsheets`: Unsupported type `#{type}`")
              end
            rescue => e
              # for adding column information
              raise TypecastError.new(e, ", column: #{n}, column_detail: #{d.to_json}")
            end
          end
        end

      end
    end
  end
end
