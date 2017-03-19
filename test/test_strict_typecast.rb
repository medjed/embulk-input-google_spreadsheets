require_relative 'helper'
require 'embulk/input/google_spreadsheets'
require 'embulk/input/google_spreadsheets/typecast/strict_typecast'
require_relative 'assert_embulk_raise'

module Embulk
  class Input::GoogleSpreadsheets < InputPlugin
    class TestStrictTypecast < Test::Unit::TestCase

      include AssertEmbulkRaise

      def least_task
        {
          'null_string' => ''
        }
      end
      
      sub_test_case 'as_string' do
        sub_test_case 'return String' do
          test 'value is String' do
            expect = 'hoge'
            result = Typecast::StrictTypecast.new(least_task).as_string('hoge')
            assert_equal(expect, result)
          end

          test 'value is true' do
            expect = 'true'
            result = Typecast::StrictTypecast.new(least_task).as_string(true)
            assert_equal(expect, result)
          end

          test 'value is false' do
            expect = 'false'
            result = Typecast::StrictTypecast.new(least_task).as_string(false)
            assert_equal(expect, result)
          end

          test 'value is Fixnum' do
            expect = '10'
            result = Typecast::StrictTypecast.new(least_task).as_string(10)
            assert_equal(expect, result)
          end

          test 'value is Bignum' do
            expect = '10000000000000000000'
            result = Typecast::StrictTypecast.new(least_task).as_string(10000000000000000000)
            assert_equal(expect, result)
          end

          test 'value is Float' do
            expect = '5.5'
            result = Typecast::StrictTypecast.new(least_task).as_string(5.5)
            assert_equal(expect, result)
          end

          test 'value is Hash' do
            expect = "{\"test\":1}"
            result = Typecast::StrictTypecast.new(least_task).as_string({'test' => 1})
            assert_equal(expect, result)
          end

          test 'value is Array' do
            expect = '[1,2,3]'
            result = Typecast::StrictTypecast.new(least_task).as_string([1, 2, 3])
            assert_equal(expect, result)
          end
        end

        sub_test_case 'return nil' do
          test 'value is nil' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task).as_string(nil)
            assert_equal(expect, result)
          end

          test 'value is empty String' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task).as_string('')
            assert_equal(expect, result)
          end

          test 'value and null_string is `\N`' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task.tap{|t|t['null_string'] = '\N'}).as_string('\N')
            assert_equal(expect, result)
          end
        end

        sub_test_case 'call TypecastError' do
          test 'value is unknown class' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_string(self)
            end
          end
        end
      end

      sub_test_case 'as_long' do
        sub_test_case 'return Fixnum or Bignum' do
          test 'value is Fixnum' do
            expect = 7
            result = Typecast::StrictTypecast.new(least_task).as_long(7)
            assert_equal(expect, result)
          end

          test 'value is Bignum' do
            expect = 10000000000000000000
            result = Typecast::StrictTypecast.new(least_task).as_long(10000000000000000000)
            assert_equal(expect, result)
          end

          test 'value is String' do
            expect = 7
            result = Typecast::StrictTypecast.new(least_task).as_long('7')
            assert_equal(expect, result)
          end
        end

        sub_test_case 'return nil' do
          test 'value is nil' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task).as_long(nil)
            assert_equal(expect, result)
          end

          test 'value is empty String' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task).as_string('')
            assert_equal(expect, result)
          end

          test 'value and null_string is `\N`' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task.tap{|t|t['null_string'] = '\N'}).as_string('\N')
            assert_equal(expect, result)
          end
        end

        sub_test_case 'call TypecastError' do
          test 'value is TrueClass' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_long(true)
            end
          end

          test 'value is FalseClass' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_long(false)
            end
          end

          test 'value is Float: the first decimal place < 5' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_long(1.1)
            end
          end

          test 'value is Float: the first decimal place >= 5' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_long(1.9)
            end
          end

          test 'value is String unable to typecast' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_long('111:222:333')
            end
          end

          test 'value is Hash' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_long({'test' => 1})
            end
          end

          test 'value is Array' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_long([1, 2, 3])
            end
          end
        end
      end

      sub_test_case 'as_double' do
        sub_test_case 'return Float' do
          test 'value is Float' do
            expect = 7.7
            result = Typecast::StrictTypecast.new(least_task).as_double(7.7)
            assert_equal(expect, result)
          end

          test 'value is String' do
            expect = 7.7
            result = Typecast::StrictTypecast.new(least_task).as_double('7.7')
            assert_equal(expect, result)
          end

          test 'value is Fixnum' do
            expect = 7.0
            result = Typecast::StrictTypecast.new(least_task).as_double(7)
            assert_equal(expect, result)
          end

          test 'value is Bignum' do
            expect = 10000000000000000000.0
            result = Typecast::StrictTypecast.new(least_task).as_double(10000000000000000000)
            assert_equal(expect, result)
          end
        end

        sub_test_case 'return nil' do
          test 'value is nil' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task).as_double(nil)
            assert_equal(expect, result)
          end

          test 'value is empty String' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task).as_string('')
            assert_equal(expect, result)
          end

          test 'value and null_string is `\N`' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task.tap{|t|t['null_string'] = '\N'}).as_string('\N')
            assert_equal(expect, result)
          end
        end

        sub_test_case 'call TypecastError' do
          test 'value is TrueClass' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_double(true)
            end
          end

          test 'value is FalseClass' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_double(false)
            end
          end

          test 'value is String unable to typecast' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_double('44:55:3.6')
            end
          end

          test 'value is Hash' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_double({'test' => 1})
            end
          end

          test 'value is Array' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_double([1, 2, 3])
            end
          end
        end
      end

      sub_test_case 'as_boolean' do
        sub_test_case 'return false' do
          test 'value is FalseClass' do
            expect = false
            result = Typecast::StrictTypecast.new(least_task).as_boolean(false)
            assert_equal(expect, result)
          end

          test "value is String 'false'" do
            expect = false
            result = Typecast::StrictTypecast.new(least_task).as_boolean('false')
            assert_equal(expect, result)
          end

          test "value is String 'f'" do
            expect = false
            result = Typecast::StrictTypecast.new(least_task).as_boolean('f')
            assert_equal(expect, result)
          end

          test "value is String 'no'" do
            expect = false
            result = Typecast::StrictTypecast.new(least_task).as_boolean('no')
            assert_equal(expect, result)
          end

          test "value is String 'n'" do
            expect = false
            result = Typecast::StrictTypecast.new(least_task).as_boolean('n')
            assert_equal(expect, result)
          end

          test "value is String 'FALSE'" do
            expect = false
            result = Typecast::StrictTypecast.new(least_task).as_boolean('FALSE')
            assert_equal(expect, result)
          end

          test "value is String 'F'" do
            expect = false
            result = Typecast::StrictTypecast.new(least_task).as_boolean('F')
            assert_equal(expect, result)
          end

          test "value is String 'NO'" do
            expect = false
            result = Typecast::StrictTypecast.new(least_task).as_boolean('NO')
            assert_equal(expect, result)
          end

          test "value is String 'N'" do
            expect = false
            result = Typecast::StrictTypecast.new(least_task).as_boolean('N')
            assert_equal(expect, result)
          end

          test "value is String 'FaLsE'" do
            expect = false
            result = Typecast::StrictTypecast.new(least_task).as_boolean('FaLsE')
            assert_equal(expect, result)
          end

          test "value is String '0'" do
            expect = false
            result = Typecast::StrictTypecast.new(least_task).as_boolean('0')
            assert_equal(expect, result)
          end

          test 'value is 0' do
            expect = false
            result = Typecast::StrictTypecast.new(least_task).as_boolean(0)
            assert_equal(expect, result)
          end
        end

        sub_test_case 'return true' do
          test 'value is TrueClass' do
            expect = true
            result = Typecast::StrictTypecast.new(least_task).as_boolean(true)
            assert_equal(expect, result)
          end

          test "value is String 'true'" do
            expect = true
            result = Typecast::StrictTypecast.new(least_task).as_boolean('true')
            assert_equal(expect, result)
          end

          test "value is String 't'" do
            expect = true
            result = Typecast::StrictTypecast.new(least_task).as_boolean('t')
            assert_equal(expect, result)
          end

          test "value is String 'yes'" do
            expect = true
            result = Typecast::StrictTypecast.new(least_task).as_boolean('yes')
            assert_equal(expect, result)
          end

          test "value is String 'y'" do
            expect = true
            result = Typecast::StrictTypecast.new(least_task).as_boolean('y')
            assert_equal(expect, result)
          end

          test "value is String 'TRUE'" do
            expect = true
            result = Typecast::StrictTypecast.new(least_task).as_boolean('TRUE')
            assert_equal(expect, result)
          end

          test "value is String 'T'" do
            expect = true
            result = Typecast::StrictTypecast.new(least_task).as_boolean('T')
            assert_equal(expect, result)
          end

          test "value is String 'YES'" do
            expect = true
            result = Typecast::StrictTypecast.new(least_task).as_boolean('YES')
            assert_equal(expect, result)
          end

          test "value is String 'Y'" do
            expect = true
            result = Typecast::StrictTypecast.new(least_task).as_boolean('Y')
            assert_equal(expect, result)
          end

          test "value is String 'tRuE'" do
            expect = true
            result = Typecast::StrictTypecast.new(least_task).as_boolean('tRuE')
            assert_equal(expect, result)
          end

          test "value is String '1'" do
            expect = true
            result = Typecast::StrictTypecast.new(least_task).as_boolean('1')
            assert_equal(expect, result)
          end

          test 'value is 1' do
            expect = true
            result = Typecast::StrictTypecast.new(least_task).as_boolean(1)
            assert_equal(expect, result)
          end
        end

        sub_test_case 'return nil' do
          test 'value is nil' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task).as_boolean(nil)
            assert_equal(expect, result)
          end

          test 'value is empty String' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task).as_string('')
            assert_equal(expect, result)
          end

          test 'value and null_string is `\N`' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task.tap{|t|t['null_string'] = '\N'}).as_string('\N')
            assert_equal(expect, result)
          end
        end

        sub_test_case 'call TypecastError' do
          test 'value is String unable to typecast' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_boolean('test')
            end
          end

          test 'value is Hash' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_boolean({'test' => 1})
            end
          end

          test 'value is Array' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_boolean([1, 2, 3])
            end
          end
        end
      end

      sub_test_case 'as_timestamp' do
        sub_test_case 'return Time' do
          sub_test_case 'no timestamp_format, no timezone' do
            test 'value is String with timezone' do
              expect = Time.parse('2015-12-15 09:31:09 UTC')
              result = Typecast::StrictTypecast.new(least_task).as_timestamp('2015-12-15 09:31:09 UTC')
              assert_equal(expect, result)
            end

            test 'value is String without timezone' do
              expect = Time.parse('2015-12-15 09:31:09 JST')
              result = Typecast::StrictTypecast.new(least_task).as_timestamp('2015-12-15 09:31:09')
              assert_equal(expect, result)
            end
          end

          sub_test_case 'has timestamp_format, no timezone' do
            test 'value is JST' do
              expect = Time.parse('2001-02-03 06:05:04 +0900')
              result = Typecast::StrictTypecast.new(least_task).as_timestamp('2001-02-03T04:05:06+09:00', '%Y-%m-%dT%S:%M:%H%z')
              assert_equal(expect, result)
            end

            test 'value is UTC' do
              expect = Time.parse('2001-02-03 06:05:04 UTC')
              result = Typecast::StrictTypecast.new(least_task).as_timestamp('2001-02-03T04:05:06UTC', '%Y-%m-%dT%S:%M:%H%Z')
              assert_equal(expect, result)
            end
          end

          sub_test_case 'no timestamp_format, has timezone' do
            test 'value is String without timezone' do
              expect = Time.parse('2015-12-15 09:31:09 JST')
              result = Typecast::StrictTypecast.new(least_task).as_timestamp('2015-12-15 09:31:09', nil, 'Asia/Tokyo')
              assert_equal(expect, result)
            end

            test 'value is String with timezone' do
              expect = Time.parse('2015-12-15 09:31:09 JST')
              result = Typecast::StrictTypecast.new(least_task).as_timestamp('2015-12-15 09:31:09 UTC', nil, 'Asia/Tokyo')
              assert_equal(expect, result)
            end
          end

          sub_test_case 'has timestamp_format, has timezone' do
            test 'value is without timezone' do
              expect = Time.parse('2001-02-03 06:05:04 JST')
              result = Typecast::StrictTypecast.new(least_task).as_timestamp('2001-02-03T04:05:06', '%Y-%m-%dT%S:%M:%H', 'Asia/Tokyo')
              assert_equal(expect, result)
            end

            test 'value is with timezone' do
              expect = Time.parse('2001-02-03 06:05:04 UTC')
              result = Typecast::StrictTypecast.new(least_task).as_timestamp('2001/02/03T06:05:04+00:00', '%Y/%m/%dT%H:%M:%S%z', 'Asia/Tokyo')
              assert_equal(expect, result)
            end
          end
        end

        sub_test_case 'return nil' do
          test 'value is nil' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task).as_timestamp(nil)
            assert_equal(expect, result)
          end

          test 'value is empty String' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task).as_string('')
            assert_equal(expect, result)
          end

          test 'value and null_string is `\N`' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task.tap{|t|t['null_string'] = '\N'}).as_string('\N')
            assert_equal(expect, result)
          end
        end

        sub_test_case 'call ConfigError' do
          test 'invalid timezone format' do
            assert_embulk_raise ConfigError do
              Typecast::StrictTypecast.new(least_task).as_timestamp('2015-12-15 09:31:09 UTC', nil, 'JST')
            end
          end
        end

        sub_test_case 'call TypecastError' do
          test 'value is TrueClass' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_timestamp(true)
            end
          end

          test 'value is FalseClass' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_timestamp(false)
            end
          end

          test 'value is String unable to typecast' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_timestamp('test')
            end
          end

          test 'value is Hash' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_timestamp({'test' => 1})
            end
          end

          test 'value is Array' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_timestamp([1, 2, 3])
            end
          end
        end
      end

      sub_test_case 'as_json' do
        sub_test_case 'return String' do
          test 'value is String' do
            expect = {'hoge' => 'fuga'}
            result = Typecast::StrictTypecast.new(least_task).as_json('{"hoge":"fuga"}')
            assert_equal(expect, result)
          end

          test 'value is Hash' do
            expect = {'test' => 1}
            result = Typecast::StrictTypecast.new(least_task).as_json({'test' => 1})
            assert_equal(expect, result)
          end

          test 'value is Array' do
            expect = [1,2,3]
            result = Typecast::StrictTypecast.new(least_task).as_json([1, 2, 3])
            assert_equal(expect, result)
          end
        end

        sub_test_case 'return nil' do
          test 'value is nil' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task).as_json(nil)
            assert_equal(expect, result)
          end

          test 'value is empty String' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task).as_string('')
            assert_equal(expect, result)
          end

          test 'value and null_string is `\N`' do
            expect = nil
            result = Typecast::StrictTypecast.new(least_task.tap{|t|t['null_string'] = '\N'}).as_string('\N')
            assert_equal(expect, result)
          end
        end

        sub_test_case 'call TypecastError' do
          test 'value is not JSON String' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_json('hoge')
            end
          end

          test 'value is true' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_json(true)
            end
          end

          test 'value is false' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_json(false)
            end
          end

          test 'value is Fixnum' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_json(10)
            end
          end

          test 'value is Bignum' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_json(10000000000000000000)
            end
          end

          test 'value is Float' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_json(5.5)
            end
          end

          test 'value is Time class' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_json(Time.at(1475572099))
            end
          end

          test 'value is unknown class' do
            assert_embulk_raise TypecastError do
              Typecast::StrictTypecast.new(least_task).as_json(self)
            end
          end
        end
      end
      
    end
  end
end