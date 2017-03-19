require_relative 'helper'
require 'embulk/input/google_spreadsheets/pager_util'

module Embulk
  class Input::GoogleSpreadsheets < InputPlugin
    class TestPagerUtil < Test::Unit::TestCase

      sub_test_case 'PagerUtil.num2col' do
        test 'positive value' do
          assert_equal('A', PagerUtil.num2col(1))
          assert_equal('Z', PagerUtil.num2col(26))
          assert_equal('AA', PagerUtil.num2col(27))
        end

        test '0 or negative value' do
          assert_equal('', PagerUtil.num2col(0))
          assert_equal('', PagerUtil.num2col(-1))
          assert_equal('', PagerUtil.num2col(-26))
        end
      end

    end
  end
end
