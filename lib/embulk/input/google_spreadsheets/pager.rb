require_relative 'pager_util'

module Embulk
  module Input
    class GoogleSpreadsheets < InputPlugin
      class Pager
        attr_reader :start_row, :start_column, :end_row, :end_column, :max_fetch_rows

        def initialize(task)
          @start_row = task['start_row']
          @start_column = task['start_column']
          @end_row = task['end_row']
          @end_column = task['end_column']
          @max_fetch_rows = task['max_fetch_rows']

          validate!
        end

        def logger
          GoogleSpreadsheets.logger
        end

        def each_record(client, &block)
          max_row_num = max_accessible_row_num(client)

          total_fetched_rows = 0
          last_fetched_row_num = start_row - 1
          while true do
            start_row_num = last_fetched_row_num + 1
            end_row_num = last_fetched_row_num + max_fetch_rows
            if end_row_num >= max_row_num
              end_row_num = max_row_num
            end

            range = range(start_row_num, end_row_num)
            page = client.worksheet_values(range)
            unless page # no values
              logger.warn { '`embulk-input-google_spreadsheets`: no data is found.' } if total_fetched_rows <= 0
              break
            end

            num_fetched_rows = 0
            page.each do |record|
              break false if no_limit? and empty_record?(record)
              num_fetched_rows += 1
              yield(record)
            end
            total_fetched_rows = total_fetched_rows + num_fetched_rows
            logger.info { "`embulk-input-google_spreadsheets`: fetched #{num_fetched_rows} rows in #{range} (tatal: #{total_fetched_rows} rows)" }
            break if num_fetched_rows < max_fetch_rows

            last_fetched_row_num = end_row_num
            break if last_fetched_row_num >= max_row_num
          end
        end

        private

        def validate!
          if (has_limit? && start_row > end_row) || start_column > end_column
            raise ConfigError.new("`embulk-input-google_spreadsheets`: Area does not exist. Please check start & end for row and column. start_row: '#{start_row}', end_row: '#{end_row}', start_col: '#{start_column}', end_col: '#{end_column}'")
          end
          if max_fetch_rows <= 0
            raise ConfigError.new('`embulk-input-google_spreadsheets`: `max_fetch_rows` must be positive integer.')
          end
        end

        def max_accessible_row_num(client)
          sheets_max = client.worksheet_max_row_num
          if start_row > sheets_max
            raise ConfigError.new("`embulk-input-google_spreadsheets`: start_row `#{start_row}` is larger than spreadsheets max row `#{sheets_max}`")
          end

          if end_row > sheets_max
            raise ConfigError.new("`embulk-input-google_spreadsheets`: end_row `#{end_row}` is larger than spreadsheets max row `#{sheets_max}`")
          end

          return sheets_max if no_limit?

          end_row
        end

        def empty_record?(record)
          return true unless record
          return true if record.empty?
          record.all? do |v|
            next true if v.nil?
            next true if v.is_a?(String) and v.empty?
            false
          end
        end

        def no_limit?
          end_row <= 0
        end

        def has_limit?
          !no_limit?
        end

        def start_column_name
          @start_column_name ||= PagerUtil.num2col(start_column)
        end

        def end_column_name
          @end_column_name ||= PagerUtil.num2col(end_column)
        end

        def range(start_row_num, end_row_num)
          "#{start_column_name}#{start_row_num}:#{end_column_name}#{end_row_num}"
        end
      end
    end
  end
end
