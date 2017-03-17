require 'google/apis/sheets_v4'
require_relative 'spreadsheets_url_util'

module Embulk
  module Input
    class GoogleSpreadsheets < InputPlugin

      class SpreadsheetsClient

        attr_accessor :spreadsheet_url, :worksheet_title, :auth, :pager

        def initialize(task, auth:, pager:)
          @spreadsheet_url = task['spreadsheet_url']
          @worksheet_title = task['worksheet_title']
          @auth = auth
          @pager = pager
        end

        def logger
          GoogleSpreadsheets.logger
        end

        def application_name
          @application_name ||= 'embulk-input-google_spreadsheets'
        end

        def spreadsheet_id
          SpreadsheetsUrlUtil.capture_id(spreadsheet_url)
        end

        def spreadsheet
          service.get_spreadsheet(spreadsheet_id, ranges: worksheet_title, include_grid_data: false)
        end

        def worksheet
          spreadsheet.sheets.first
        end

        def worksheet_properties
          worksheet.properties
        end

        def worksheet_grid_properties
          worksheet_properties.grid_properties
        end

        def worksheet_max_row_num
          worksheet_grid_properties.row_count
        end

        def worksheet_max_column_num
          worksheet_grid_properties.column_count
        end

        def worksheet_values(range)
          range = "#{worksheet_title}!#{range}"
          logger.info { "`embulk-input-google_spreadsheets`: load data from spreadsheet: '#{spreadsheet_url}', range: '#{range}'" }
          service.get_spreadsheet_values(spreadsheet_id, range).values
        end

        def worksheet_each_record(&block)
          pager.each_record(self, &block)
        end

        def service
          @service ||= Google::Apis::SheetsV4::SheetsService.new.tap do |s|
            s.client_options.application_name = application_name
            s.authorization = auth.authenticate
          end
        end

      end
    end
  end
end
