#!/usr/bin/env ruby

require 'test/unit'
require 'test/unit/rr'

ENV['TZ'] = 'JST-9'

require 'embulk'
Embulk.setup
Embulk.logger = Embulk::Logger.new('/dev/null')

APP_ROOT = File.expand_path('../', __dir__)
EXAMPLE_ROOT = File.join(APP_ROOT, 'example')
TEST_ROOT = File.join(APP_ROOT, 'test')
JSON_KEYFILE_SERVICE_ACCOUNT = File.join(EXAMPLE_ROOT, 'service_account_credentials.json')
JSON_KEYFILE_AUTHORIZED_USER = File.join(EXAMPLE_ROOT, 'authorized_user_credentials.json')
TEST_SPREADSHEETS_URL = 'https://docs.google.com/spreadsheets/d/1Cxz-LudQuhRAGZL8mBoHs6mRnpjODpyF4Rwc5UYoV1E/edit#gid=0'
TEST_SPREADSHEETS_ID = '1Cxz-LudQuhRAGZL8mBoHs6mRnpjODpyF4Rwc5UYoV1E'
TEST_WORKSHEET_TITLE = 'sheet1'
TEST_WORKSHEET_TITLE_MULTI_BYTE = '日本語（japanese）'
DUMMY_RSA_KEY = File.expand_path('dummy.key', __dir__) # openssl genrsa 2048 > dummy.key
