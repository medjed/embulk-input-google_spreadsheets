require 'googleauth'
require 'google/apis/sheets_v4'
require 'highline/import'
require 'json'

puts 'Before setup, open this page https://developers.google.com/identity/protocols/OAuth2'
puts 'then get OAuth 2.0 credentials such as a client ID and client secret according to the above page.'
puts

credentials = Google::Auth::UserRefreshCredentials.new(
  client_id: ask('Enter client_id: '),
  client_secret: ask('Enter client_secret: '),
  scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY,
  redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
)

credentials.code = ask(
  "1. Open this page '#{credentials.authorization_uri.to_s}'.\n" \
  '2. Enter the authorization code shown in the page: '
) {|q| q.echo = false}

credentials.fetch_access_token!

data = {
  client_id: credentials.client_id,
  client_secret: credentials.client_secret,
  refresh_token: credentials.refresh_token,
}.to_json
file = File.expand_path('authorized_user_credentials.json', __dir__)
File.open(file, 'w') do |f|
  f.write(data)
end

puts "Success. See '#{file}'."