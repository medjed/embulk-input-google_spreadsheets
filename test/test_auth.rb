require_relative 'helper'
require 'embulk/input/google_spreadsheets'
require_relative 'assert_embulk_raise'
require_relative 'assert_embulk_nothing_raised'

module Embulk
  class Input::GoogleSpreadsheets < InputPlugin

    class TestAuth < Test::Unit::TestCase

      include AssertEmbulkRaise
      include AssertEmbulkNothingRaised

      sub_test_case 'authorized_user' do
        unless File.exist?(JSON_KEYFILE_AUTHORIZED_USER)
          puts "#{JSON_KEYFILE_AUTHORIZED_USER} is not found. Skip correct cases authorized_user"
        else
          test 'correct json_keyfile' do
            task = {
              'auth_method'  => 'authorized_user',
              'json_keyfile' => File.read(JSON_KEYFILE_AUTHORIZED_USER)
            }
            assert_embulk_nothing_raised do
              Auth.new(task).authenticate.fetch_access_token!
            end
          end
        end

        test 'incorrect json_keyfile' do
          task = {
            'auth_method'  => 'authorized_user',
            'json_keyfile' => '{"client_id":"hoge", "client_secret":"fuga","refresh_token":"hogo"}'
          }
          assert_embulk_raise Signet::AuthorizationError do
            Auth.new(task).authenticate.fetch_access_token!
          end
        end
      end

      sub_test_case 'service_account' do
        unless File.exist?(JSON_KEYFILE_SERVICE_ACCOUNT)
          puts "#{JSON_KEYFILE_SERVICE_ACCOUNT} is not found. Skip correct cases service_account"
        else
          test 'correct json_keyfile' do
            task = {
              'auth_method'  => 'service_account',
              'json_keyfile' => File.read(JSON_KEYFILE_SERVICE_ACCOUNT)
            }
            assert_embulk_nothing_raised do
              Auth.new(task).authenticate.fetch_access_token!
            end
          end
        end

        test 'incorrect json_keyfile' do
          dummy_rsa_key = File.read(DUMMY_RSA_KEY).gsub("\n", '\n')
          task = {
            'auth_method'  => 'service_account',
            'json_keyfile' => '{"client_id":"hoge", "client_secret":"fuga","client_email":"hogo","private_key":"' + dummy_rsa_key + '"}'
          }
          assert_embulk_raise Signet::AuthorizationError do
            Auth.new(task).authenticate.fetch_access_token!
          end
        end
      end

      # TODO: compute_engine cases
      # TODO: application_default cases

      sub_test_case 'ConfigError' do
        test 'invalid auth_method' do
          task = {
            'auth_methqd' => 'hoge'
          }
          assert_embulk_raise ConfigError do
            Auth.new(task).authenticate
          end
        end
      end
    end
  end
end
