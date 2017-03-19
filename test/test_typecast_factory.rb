require_relative 'helper'
require 'embulk/input/google_spreadsheets/typecast_factory'
require 'embulk/input/google_spreadsheets/typecast/strict_typecast'
require 'embulk/input/google_spreadsheets/typecast/loose_typecast'
require 'embulk/input/google_spreadsheets/typecast/minimal_typecast'
require_relative 'assert_embulk_raise'

module Embulk
  class Input::GoogleSpreadsheets < InputPlugin
    class TestTypecastFactory < Test::Unit::TestCase

      include AssertEmbulkRaise

      sub_test_case 'TypecastFactory.create' do
        test 'correct' do
          assert_kind_of(Typecast::StrictTypecast, TypecastFactory.create('strict', {}))
          assert_kind_of(Typecast::LooseTypecast, TypecastFactory.create('loose', {}))
          assert_kind_of(Typecast::MinimalTypecast, TypecastFactory.create('minimal', {}))
        end

        test 'incorrect' do
          assert_embulk_raise ConfigError do
            TypecastFactory.create(nil, nil)
          end
          assert_embulk_raise ConfigError do
            TypecastFactory.create({}, {})
          end
          assert_embulk_raise ConfigError do
            TypecastFactory.create('hoge', nil)
          end
        end
      end

    end
  end
end
