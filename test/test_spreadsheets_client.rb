require_relative 'helper'
require 'embulk/input/google_spreadsheets'
require_relative 'assert_embulk_nothing_raised'

if !File.exist?(JSON_KEYFILE_AUTHORIZED_USER) and !File.exist?(JSON_KEYFILE_SERVICE_ACCOUNT)
  puts "Neither '#{JSON_KEYFILE_AUTHORIZED_USER}' nor '#{JSON_KEYFILE_SERVICE_ACCOUNT}' is not found. Skip test/test_spreadsheets_client.rb"
else
  module Embulk
    class Input::GoogleSpreadsheets < InputPlugin
      class TestSpreadsheetsClient < Test::Unit::TestCase

        include AssertEmbulkNothingRaised

        def auth_config
          if File.exist?(JSON_KEYFILE_AUTHORIZED_USER)
            {
              'auth_method'  => 'authorized_user',
              'json_keyfile' => File.read(JSON_KEYFILE_AUTHORIZED_USER)
            }
          elsif File.exist?(JSON_KEYFILE_SERVICE_ACCOUNT)
            {
              'auth_method'  => 'service_account',
              'json_keyfile' => File.read(JSON_KEYFILE_SERVICE_ACCOUNT)
            }
          else
            raise "Neither '#{JSON_KEYFILE_AUTHORIZED_USER}' nor '#{JSON_KEYFILE_SERVICE_ACCOUNT}' is not found."
          end
        end

        def least_task
          {
            'spreadsheets_url' => TEST_SPREADSHEETS_URL,
            'worksheet_title'  => TEST_WORKSHEET_TITLE,
            'start_column'     => 1,
            'start_row'        => 2,
            'end_row'          => -1,
            'end_column'       => 6,
            'max_fetch_rows'    => 10000,
            'columns'          => columns,
          }.merge(auth_config)
        end

        def columns
          [
            {'name' => '_c1', 'type' => 'boolean', 'typecast' => 'strict'},
            {'name' => '_c2', 'type' => 'string', 'typecast' => 'strict'},
            {'name' => '_c3', 'type' => 'long', 'typecast' => 'strict'},
            {'name' => '_c4', 'type' => 'double', 'typecast' => 'strict'},
            {'name' => '_c5', 'type' => 'timestamp', 'format' => '%Y-%m-%d %H:%M:%S.%N', 'timezone' => 'Asia/Tokyo', 'typecast' => 'strict'},
            {'name' => '_c6', 'type' => 'timestamp', 'format' => '%Y-%m-%d', 'timezone' => 'Asia/Tokyo', 'typecast' => 'strict'}
          ]
        end

        def client(task = {})
          task = least_task.merge(task)
          SpreadsheetsClient.new(task, auth: Auth.new(task), pager: Pager.new(task))
        end

        test 'parse spreadsheets id' do
          expect = TEST_SPREADSHEETS_ID
          result = client.spreadsheets_id
          assert_equal(expect, result)
        end

        test 'get spreadsheet' do
          assert_embulk_nothing_raised do
            client.spreadsheets
          end
        end

        test 'worksheet values' do
          expect = [%w(_c1 _c2 _c3)]
          result = client.worksheet_values('A1:C1')
          assert_equal(expect, result)
        end

        test 'multi byte worksheet title' do
          omit 'Skip until closing this issue https://github.com/sporkmonger/addressable/issues/258'

          assert_embulk_nothing_raised do
            client('worksheet_title' => TEST_WORKSHEET_TITLE_MULTI_BYTE).worksheet_values('A1:C1')
          end
        end
      end
    end
  end
end
