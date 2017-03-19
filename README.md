# Google Spreadsheets input plugin for Embulk

Embulk input plugin to load records from Google Spreadsheets.

## Overview

* **Plugin type**: input

## Configuration

| name                | type        | requirement | default         | description            |
|:--------------------|:------------|:------------|:----------------|:-----------------------|
| auth_method        | string      | optional    | `authorized_user`      | `service_account`, `authorized_user`, `compute_engine`, or `application_default` |
| json_keyfile       | string      | optional    |                 | keyfile path or `content` |
| spreadsheets_url    | string      | required    |                 |  |
| worksheet_title    | string      | required    |                 | worksheet title |
| start_column       | integer     | optional    | `1`             |  |
| start_row          | integer     | optional    | `1`             |  |
| end_row            | integer     | optional    | `-1`            | `-1` means loading records until an empty record appears. |
| max_fetch_rows     | integer     | optional    | `100000`        |  Load data from a worksheet for each numerical value specified by this option. |
| null_string        | string      | optional    | `''`            |  Replace this value to `NULL` |
| stop_on_invalid_record | boolean | optional    | `true`          |  |
| default_timestamp_format | string | optional | `'%Y-%m-%d %H:%M:%S.%N %z'` | |
| default_timezone | string | optional | `'UTC'` | |
| default_typecast | string | optional | `'strict'` | |
|  columns            | array       | required    |                 |  |

##### about keyfile
* if `auth_method` is `compute_engine` or `application_default`, this option is not required.
* if `auth_method` is `authorized_user`, this plugin supposes the format is the below.
  
  ```json
  {
    "client_id":"xxxxxxxxxxx.apps.googleusercontent.com",
    "client_secret":"xxxxxxxxxxx",
    "refresh_token":"xxxxxxxxxxx"
  }
  ```
* if `auth_method` is `service_account`, set the service account credential json file path.

##### about columns
* name: column name
* type: boolean, long, double, string, timestamp, json
* format: timestamp format like `'%Y-%m-%d %H:%M:%S.%N %z'`
* timezone: timezone
* typecast: you can choose `strict`, `loose`, `minimal` (default: `strict`)
  * `strict`: raise TypecastError if typecasting is failed.
  * `loose` : set `NULL` value if typecasting is failed.
  * `minimal`  : typecast minimally.


## Development

### Run example:

1. Execute `example/setup_authorized_user_credentials.rb` if you don't have credentials, then
2. 

```
$ embulk bundle install --path vendor/bundle
$ embulk run -b . -l trace example/config_authorized_user.yml
```

### Run test:

```
$ bundle exec rake test
```

To run tests which actually connects to Google Spreadsheets such as `test/test_google_spreadsheets_client.rb`,
prepare a json\_keyfile at `example/service_account_credentials.json`, then

```
$ bundle exec ruby test/test_google_spreadsheets_client.rb
$ bundle exec ruby test/test_example.rb
```

### Release gem:

Fix gemspec, then

```
$ bundle exec rake release
```

## ChangeLog

[CHANGELOG.md](CHANGELOG.md)