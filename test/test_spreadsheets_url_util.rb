require_relative 'helper'
require 'embulk/input/google_spreadsheets/spreadsheets_url_util'

module Embulk
  class Input::GoogleSpreadsheets < InputPlugin
    class TestSpreadsheetsUrlUtil < Test::Unit::TestCase

      sub_test_case 'SpreadsheetsUrlUtil.capture_id' do
        test 'correct url' do
          assert_equal(TEST_SPREADSHEETS_ID, SpreadsheetsUrlUtil.capture_id(TEST_SPREADSHEETS_URL))
          assert_equal('a', SpreadsheetsUrlUtil.capture_id('https://docs.google.com/spreadsheets/d/a/'))
        end

        test 'incorrect url' do
          assert_equal(nil, SpreadsheetsUrlUtil.capture_id(''))
          assert_equal(nil, SpreadsheetsUrlUtil.capture_id('https://docs.google.com/spreadsheets/d/'))
          assert_equal(nil, SpreadsheetsUrlUtil.capture_id('https://docs.google.com/spreadsheets/d//'))
        end
      end

    end
  end
end
