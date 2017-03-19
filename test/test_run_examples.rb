require_relative 'helper'

module Embulk
  class Input::GoogleSpreadsheets < InputPlugin
    class TestRunExample < Test::Unit::TestCase
      def embulk_path
        if File.exist?("#{ENV['PATH']}/.embulk/bin/embulk")
          "#{ENV['PATH']}/.embulk/bin/embulk"
        elsif File.exist?('/usr/local/bin/embulk')
          '/usr/local/bin/embulk'
        else
          'embulk'
        end
      end

      def embulk_run(config_path)
        Bundler.with_clean_env do
          cmd = "#{embulk_path} run -X page_size=1 -b . -l trace #{config_path}"
          puts '=' * 64
          puts cmd
          system(cmd)
        end
      end

      sub_test_case 'run' do
        unless File.exist?(JSON_KEYFILE_AUTHORIZED_USER)
          puts "'#{JSON_KEYFILE_AUTHORIZED_USER}' is not found. Skip case authorized_user"
        else
          test 'authorized_user' do
            assert_true embulk_run(File.join(EXAMPLE_ROOT, 'config_authorized_user.yml'))
          end
        end

        unless File.exist?(JSON_KEYFILE_SERVICE_ACCOUNT)
          puts "'#{JSON_KEYFILE_SERVICE_ACCOUNT}' is not found. Skip case service_account"
        else
          test 'service_account' do
            assert_true embulk_run(File.join(EXAMPLE_ROOT, 'config_service_account.yml'))
          end
        end
      end
    end
  end
end
