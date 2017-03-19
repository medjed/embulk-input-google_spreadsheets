require_relative 'helper'
require 'embulk/input/google_spreadsheets'
require_relative 'assert_embulk_raise'

module Embulk
  class Input::GoogleSpreadsheets < InputPlugin

    class TestConfigure < Test::Unit::TestCase

      setup do
        # TODO: to keep class instance variables' default value always
        @_default_format = CustomColumns.default_format
        @_default_timezone = CustomColumns.default_timezone
        @_default_typecast = CustomColumns.default_typecast
      end

      teardown do
        CustomColumns.default_format = @_default_format
        CustomColumns.default_timezone = @_default_timezone
        CustomColumns.default_typecast = @_default_typecast
      end

      include AssertEmbulkRaise

      GoogleSpreadsheets = Embulk::Input::GoogleSpreadsheets unless defined?(GoogleSpreadsheets)

      def least_config
        DataSource.new({
          'spreadsheets_url' => TEST_SPREADSHEETS_URL,
          'worksheet_title'  => TEST_WORKSHEET_TITLE,
          'columns'          => columns,
        })
      end

      def columns
        [
          {'name' => '_c1', 'type' => 'boolean'},
          {'name' => '_c2', 'type' => 'string'},
          {'name' => '_c3', 'type' => 'long'},
          {'name' => '_c4', 'type' => 'double'},
          {'name' => '_c5', 'type' => 'timestamp'},
        ]
      end

      def config(config = {})
        least_config.merge(config)
      end

      sub_test_case 'configure by buildin API' do
        test 'default' do
          task = GoogleSpreadsheets.configure(config)
          assert_equal(1, task['start_column'])
          assert_equal(1, task['start_row'])
          assert_equal(-1, task['end_row'])
          assert_equal(10000, task['max_fetch_rows'])
          assert_equal('', task['null_string'])
          assert_equal(true, task['stop_on_invalid_record'])
          assert_equal('%Y-%m-%d %H:%M:%S.%N %z', task['default_timestamp_format'])
          assert_equal('UTC', task['default_timezone'])
          assert_equal('strict', task['default_typecast'])
        end
      end

      sub_test_case 'end_column' do
        test 'end_column' do
          task = GoogleSpreadsheets.configure(config('start_column' => 5, 'columns' => [{},{},{}]))
          assert_equal(7, task['end_column'])
        end
      end

      sub_test_case 'LocalFile' do
        test 'not set json_keyfile' do
          task = GoogleSpreadsheets.configure(config)
          assert_equal(nil, task['json_keyfile'])
        end

        test 'set file path' do
          dummy = File.join(APP_ROOT, 'Gemfile')
          task = GoogleSpreadsheets.configure(config('json_keyfile' => dummy))
          assert_equal(File.read(dummy), task['json_keyfile'])
        end

        test 'set content' do
          dummy = 'hoge'
          task = GoogleSpreadsheets.configure(config('json_keyfile' => {'content' => dummy}))
          assert_equal(dummy, task['json_keyfile'])
        end
      end

      sub_test_case 'CustomColumns' do
        test 'not array' do
          assert_embulk_raise Embulk::ConfigError do
            GoogleSpreadsheets.configure(config('columns' => 'hoge'))
          end
        end

        test 'not array of hash' do
          assert_embulk_raise Embulk::ConfigError do
            GoogleSpreadsheets.configure(config('columns' => ['hoge']))
          end
        end

        test 'complete default' do
          task = GoogleSpreadsheets.configure(config('columns' => [{'name' => '_c5', 'type' => 'timestamp'}]))
          assert_equal('%Y-%m-%d %H:%M:%S.%N %z', task['columns'].first['format'])
          assert_equal('UTC', task['columns'].first['timezone'])
          assert_equal('strict', task['columns'].first['typecast'])
        end

        test 'complete default by user defined default' do
          task = GoogleSpreadsheets.configure(config(
            'default_timestamp_format' => '%N',
            'default_timezone' => 'Asia/Tokyo',
            'default_typecast' => 'loose',
            'columns' => [{'name' => '_c5', 'type' => 'timestamp'}]
          ))
          assert_equal('%N', task['columns'].first['format'])
          assert_equal('Asia/Tokyo', task['columns'].first['timezone'])
          assert_equal('loose', task['columns'].first['typecast'])
        end

        test 'not complete except timestamp' do
          task = GoogleSpreadsheets.configure(config(
            'columns' => [
              {'name' => '_c1', 'type' => 'boolean'},
              {'name' => '_c2', 'type' => 'string'},
              {'name' => '_c3', 'type' => 'long'},
              {'name' => '_c4', 'type' => 'double'},
              {'name' => '_c5', 'type' => 'json'},
            ]))
          5.times do |i|
            assert_equal(nil, task['columns'][i]['format'], i)
            assert_equal(nil, task['columns'][i]['timezone'], i)
          end
        end

        test 'complete typecast if any type' do
          task = GoogleSpreadsheets.configure(config(
            'columns' => [
              {'name' => '_c1', 'type' => 'boolean'},
              {'name' => '_c2', 'type' => 'string'},
              {'name' => '_c3', 'type' => 'long'},
              {'name' => '_c4', 'type' => 'double'},
              {'name' => '_c5', 'type' => 'json'},
            ]))
          5.times do |i|
            assert_equal('strict', task['columns'][i]['typecast'], i)
          end
        end
      end

    end

  end
end
