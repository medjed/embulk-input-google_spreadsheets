require "google_drive"
require "signet/oauth_2/client"
require "json"
require_relative 'error'


module Embulk
  module Input
    class Googlespreadsheet < InputPlugin

      class GssSession

        def initialize(task)
          @task = task

          @auth_method = @task["auth_method"]
          @account = @task["account"]
          @json_keyfile = @task["json_keyfile"]
          @client = nil

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
          when "json_key"
            @client = Signet::OAuth2::Client.new(
              :token_credential_uri => "https://accounts.google.com/o/oauth2/token",
              :audience             => "https://accounts.google.com/o/oauth2/token",
              :scope                => "https://www.googleapis.com/auth/drive" << " https://spreadsheets.google.com/feeds/",
              :issuer               => @account,
              :signing_key          => OpenSSL::PKey::RSA.new(key["private_key"])
            )

          when "refresh_token"
            @client = Signet::OAuth2::Client.new(
              :token_credential_uri => "https://accounts.google.com/o/oauth2/token",
              :audience             => "https://accounts.google.com/o/oauth2/token",
              :scope                => "https://www.googleapis.com/auth/drive" << " https://spreadsheets.google.com/feeds/",
              :redirect_uri         => "urn:ietf:wg:oauth:2.0:oob",
              :client_id            => key["client_id"],
              :client_secret        => key["client_secret"],
              :refresh_token        => key["refresh_token"]
            )

          else
            raise ConfigError.new("Unknown auth_method: #{@auth_method}")
          end

          begin
            @client.fetch_access_token!
            @session = GoogleDrive.login_with_oauth(@client.access_token)
          rescue => e
            raise ConfigError.new(e)
          end
        end

        def fetch(start_row, start_col, end_row, end_col)
          if (end_row != -1 && start_row > end_row) || start_col > end_col
            raise ConfigError.new("Area not exist. Please check start&end for row and column.")
          end

          begin
            ws = session.spreadsheet_by_key(@gss_key).worksheet_by_title(@ws_title)
            if ws.nil?
              Embulk.logger.info { "embulk-input-googlespreadsheet: target worksheet does not exist." }
              return
            end

            if end_row == -1
              (start_row..ws.num_rows + 1).each do |row|
                all_empty = 1
                (start_col..end_col).each do |col|
                  if ws[row, col] != ""
                    all_empty = 0
                    break
                  end
                end
                if all_empty == 1
                  end_row = row - 1
                  break
                end
              end
            end

            Embulk.logger.debug { "embulk-input-googlespreadsheet: fetch data from spreadsheet:#{@gss_key}, worksheet:#{@ws_title}, start_row:#{start_row}, end_row:#{end_row}, start_column:#{start_col}, end_column:#{end_col}" }

            result = Array.new
            (start_row..end_row).each do |row|
              line = Array.new
              (start_col..end_col).each do |col|
                if ws[row, col].to_s.empty?
                  line << String.new
                else
                  line << ws[row, col].gsub(/(\n|\t)/, " ") unless ws[row, col].to_s.empty?
                end
              end
              result << line
            end
            result
          rescue => e
            Embulk.logger.error { "embulk-input-googlespreadsheet: failed to fetch data from spreadsheet:#{@gss_key}, worksheet:#{@ws_title}, start_row:#{start_row}, end_row:#{end_row}, start_column:#{start_col}, end_column:#{end_col}, error:#{e}" }
            raise DataError.new(e)
          end
        end

      end

    end
  end
end
