require 'ini_file'
require 'googleauth'
require 'google/apis/sheets_v4'

module Embulk
  module Input
    class GoogleSpreadsheets < InputPlugin
      class Auth

        attr_reader :auth_method

        def initialize(task)
          @auth_method = task['auth_method']
          @json_key = task['json_keyfile']
        end

        def authenticate
          case auth_method
          when 'authorized_user'
            key = StringIO.new(credentials.to_json)
            return Google::Auth::UserRefreshCredentials.make_creds(json_key_io: key, scope: scope)
          when 'compute_engine'
            return Google::Auth::GCECredentials.new
          when 'service_account'
            key = StringIO.new(credentials.to_json)
            return Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: key, scope: scope)
          when 'application_default'
            return Google::Auth.get_application_default([scope])
          else
            raise ConfigError, "Unknown auth method: #{auth_method}"
          end
        end

        def scope
          Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY
        end

        private

        def credentials
          JSON.parse(@json_key || File.read(credentials_file))
        end

        def credentials_file
          @credentials_file ||= File.expand_path(
            # ref. https://developers.google.com/identity/protocols/application-default-credentials
            (File.exist?(global_application_default_credentials_file) ?
              global_application_default_credentials_file : application_default_credentials_file)
          )
        end

        def application_default_credentials_file
          @application_default_credentials_file ||=
            File.expand_path('~/.config/gcloud/application_default_credentials.json')
        end

        def global_application_default_credentials_file
          @global_application_default_credentials_file ||=
            '/etc/google/auth/application_default_credentials.json'
        end
      end
    end
  end
end
