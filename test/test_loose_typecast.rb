require_relative 'helper'
require 'embulk/input/google_spreadsheets'
require 'embulk/input/google_spreadsheets/typecast/loose_typecast'

module Embulk
  class Input::GoogleSpreadsheets < InputPlugin
    class TestStrictTypecast < Test::Unit::TestCase
      def least_task
        {
          'null_string' => ''
        }
      end

      sub_test_case 'as_string' do
        test 'value is unknown class' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_string(self)
          assert_equal(expect, result)
        end
      end

      sub_test_case 'as_long' do
        test 'value is TrueClass' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_long(true)
          assert_equal(expect, result)
        end

        test 'value is FalseClass' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_long(false)
          assert_equal(expect, result)
        end

        test 'value is Float: the first decimal place < 5' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_long(1.1)
          assert_equal(expect, result)
        end

        test 'value is Float: the first decimal place >= 5' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_long(1.9)
          assert_equal(expect, result)
        end

        test 'value is unable to typecast to String' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_long('111:222:333')
          assert_equal(expect, result)
        end

        test 'value is Hash' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_long({'test' => 1})
          assert_equal(expect, result)
        end
        test 'value is Array' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_long([1, 2, 3])
          assert_equal(expect, result)
        end
      end

      sub_test_case 'as_double' do
        test 'value is TrueClass' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_double(true)
          assert_equal(expect, result)
        end

        test 'value is FalseClass' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_double(false)
          assert_equal(expect, result)
        end

        test 'value is unable to typecast to String' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_double('44:55:3.6')
          assert_equal(expect, result)
        end

        test 'value is Hash' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_double({'test' => 1})
          assert_equal(expect, result)
        end

        test 'value is Array' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_double([1, 2, 3])
          assert_equal(expect, result)
        end
      end

      sub_test_case 'as_boolean' do
        test 'value is unable to typecast to String' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_boolean('test')
          assert_equal(expect, result)
        end

        test 'value is Hash' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_boolean({'test' => 1})
          assert_equal(expect, result)
        end

        test 'value is Array' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_boolean([1, 2, 3])
          assert_equal(expect, result)
        end
      end

      sub_test_case 'as_timestamp' do
        test 'value is TrueClass' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_timestamp(true)
          assert_equal(expect, result)
        end

        test 'value is FalseClass' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_timestamp(false)
          assert_equal(expect, result)
        end

        test 'value is unable to typecast to String' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_timestamp('test')
          assert_equal(expect, result)
        end

        test 'value is Hash' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_timestamp({'test' => 1})
          assert_equal(expect, result)
        end

        test 'value is Array' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_timestamp([1, 2, 3])
          assert_equal(expect, result)
        end
      end

      sub_test_case 'as_json' do
        test 'value is true' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_json(true)
          assert_equal(expect, result)
        end

        test 'value is false' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_json(false)
          assert_equal(expect, result)
        end

        test 'value is Fixnum' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_json(10)
          assert_equal(expect, result)
        end

        test 'value is Bignum' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_json(10000000000000000000)
          assert_equal(expect, result)
        end

        test 'value is Float' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_json(5.5)
          assert_equal(expect, result)
        end

        test 'value is Time class' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_json(Time.at(1475572099))
          assert_equal(expect, result)
        end

        test 'value is unknown class' do
          expect = nil
          result = Typecast::LooseTypecast.new(least_task).as_json(self)
          assert_equal(expect, result)
        end
      end
    end
  end
end
