require "googleauth"
require "google/apis/sheets_v4"
require "json"
require_relative 'error'


module Embulk
  module Input
    class Googlespreadsheet < InputPlugin

      class GssSession
        OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
        APPLICATION_NAME = 'embulk-input-googlespreadsheet'
        SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY
        FETCH_MAX = 10000 # rows

        def initialize(task)
          @task = task

          @auth_method = @task["auth_method"]
          @account = @task["account"]
          @json_keyfile = @task["json_keyfile"]
          @credentials = nil

          @gss_key = @task["spreadsheet_key"]
          @ws_title = @task["worksheet_title"]
        end

        def session
          return @session if @session

          begin
            key = JSON.parse(@json_keyfile)
          rescue => e
            Embulk.logger.error { "embulk-input-googlespreadsheet: failed to process keyfile:#{@keyfile}" }
            raise ConfigError.new(e)
          end

          case @auth_method
          when 'json_key'
            @credentials = Google::Auth::ServiceAccountCredentials.new(
              token_credential_uri: key['token_uri'],
              audience:             key['token_uri'],
              scope:                SCOPE,
              issuer:               key['client_email'],
              signing_key:          OpenSSL::PKey::RSA.new(key['private_key'])
            )

          when 'refresh_token'
            @credentials = Google::Auth::UserRefreshCredentials.new(
              client_id:     key['client_id'],
              client_secret: key['client_secret'],
              refresh_token: key['refresh_token'],
              scope:         SCOPE,
              redirect_uri:  OOB_URI
            )

          else
            raise ConfigError.new("Unknown auth_method: #{@auth_method}")
          end

          begin
            @credentials.fetch_access_token!
            @session = Google::Apis::SheetsV4::SheetsService.new.tap do |svc|
              svc.client_options.application_name = APPLICATION_NAME
              svc.authorization = @credentials
            end

          rescue => e
            raise ConfigError.new(e)
          end
        end

        def fetch(start_row, start_col, end_row, end_col, &block)
          if (end_row != -1 && start_row > end_row) || start_col > end_col
            raise ConfigError.new("Area not exist. Please check start&end for row and column.")
          end

          begin
            last_fatch_row_num = start_row - 1
            while true do
              start_row_num = last_fatch_row_num + 1
              end_row_num = last_fatch_row_num + FETCH_MAX
              if end_row != -1 and end_row_num >= end_row
                end_row_num = end_row
              end

              range = "#{@ws_title}!#{convert_col_name(start_col)}#{start_row_num}:#{convert_col_name(end_col)}#{end_row_num}"

              breakable = false
              @session.get_spreadsheet_values(@gss_key, range).values.each do |row|
                if end_row == -1 and row.all?{|v| v.nil? or v.empty?}
                  breakable = true
                  break
                end
                yield(row)
              end
              break if breakable

              if end_row != -1 and end_row_num >= end_row
                break
              end

              last_fatch_row_num += FETCH_MAX
            end
          rescue => e
            Embulk.logger.error { "embulk-input-googlespreadsheet: failed to fetch data from spreadsheet:#{@gss_key}, worksheet:#{@ws_title}, start_row:#{start_row}, end_row:#{end_row}, start_column:#{start_col}, end_column:#{end_col}, error:#{e}" }
            raise DataError.new(e)
          end
        end

        COL_START_OFFSET = 'A'.ord
        COL_NAME_BASE = 26
        def convert_col_name(num)
          [].tap do |r|
            while num > 0
              num -= 1
              r.unshift (num % COL_NAME_BASE + COL_START_OFFSET).chr
              num /= COL_NAME_BASE
            end
          end.join
        end


      end

    end
  end
end
