1.1.1 (2019-10-17)
==================
- Maintenance: Lock signet and google-api-client version (thanks to @hiroyuki-sato)
  - https://github.com/medjed/embulk-input-google_spreadsheets/pull/14

1.1.0 (2017-04-18)
==================
- New Feature: Support `value_render_option` option.
  - https://github.com/medjed/embulk-input-google_spreadsheets/pull/9

1.0.0 (2017-03-27)
==================

### Now, embulk-input-googlespreadsheet is recreated as embulk-input-google_spreadsheets, so this release has **lots of breaking changes**.

#### About Configuration
- Remove `account` option because this parameter can be set by `json_keyfile` or internal processing.
- Change acceptable values of `auth_method` option to `service_account`, `authorized_user`, `compute_engine`, and `application_default`.
  - `json_key` is renamed to `service_account`.
  - `refresh_token` is renamed to `authorized_user`.
- Remove `spreadsheet_key` option because it is ambiguous what to specify for this option.
- Create `spreadsheets_url` option instead of `spreadsheet_key` option.
- Create `max_fetch_rows` option for loading a worksheet which have lots of cells.
  - Load data from a worksheet for each numerical value specified by this option.
- Create `null_string` option to define `NULL` value.
- Create `stop_on_invalid_record` option.
  - Stop loading data if this option is true.
- Create `default_timestamp_format` option.
- Create `default_timezone` option.
- Create `typecast` option for `columns` configurations.
  - You can choose `strict`, `loose`, `minimal`.
  - You can set default by `default_typecast` option.

#### About Behaviours
- Improve memory usage
  - The previous implementation loads all data (includes other worksheets) from the spreadsheets at once by each task, so embulk uses lots of memory.
  - This version loads data from the specified worksheet for each numerical value specified by `max_fetch_rows` option.
- Change default timestamp format `%Y-%m-%d %H:%M:%S` to `%Y-%m-%d %H:%M:%S.%N %z`.
  - This new default format follows embulk-core implementation.
    - Ref. https://github.com/embulk/embulk/blob/936c5d5a20af3086f7d1e5779a89035105bb975b/embulk-core/src/main/java/org/embulk/spi/type/TimestampType.java#L10
    - But, `Time.strptime` does not support `%6N`, so this plugin use `%N` instead.
  - Enable to define default timestamp format by using `default_timestamp_format` option.
- Change default timezone from `Asia/Tokyo` to `UTC`.
  - This follows world standard.
  - Enable to define default timezone by using `default_timezone` option.
- Remove mysterious replace of string.
  - The previous version replace `\t` and `\n` to ` `, but the implementation is so mysterious for users.
  - This version does not do any mysterious replaces.
- Change errors more traceable.
  - All errors are wrapped by `Embulk::Input::GoogleSpreadsheets::ConfigError` or `Embulk::Input::GoogleSpreadsheets::DataError`, so you can see JRuby stacktrace when some error occurs.
- Improve processing invalid records.
  - Enable to skip by set `stop_on_invalid_record` option false.
- Improve Typecasting.
  - Enable to define `NULL` value by using `null_string` option.
  - Enable to use `yes` or `no` as boolean type.
  - Disable to round values.
    - The previous version typecast empty string to `0` if the type is `long`.
    - The previous version typecast empty string to `0.0` if the type is `double`.
  - Support loose typecasting.
  - Support minimal typecasting.
  
#### Others
- Add tests
- Rename this plugin's name to `embulk-input-google_spreadsheets`
- Start CI
  - https://travis-ci.org/medjed/embulk-input-google_spreadsheets
  
#### Known Issues
- [Some multi-byte strings cannot be used as a worksheet title.](https://github.com/medjed/embulk-input-google_spreadsheets/issues/6)
- [Emoji cannot be used as a worksheet title.](https://github.com/medjed/embulk-input-google_spreadsheets/issues/7)

0.3.0 (2017-03-08)
==================

- change: transfer `apollocarlos/embulk-input-googlespreadsheet` to `medjed/embulk-input-googlespreadsheet`
- incompatible change: raise `ConfigError` if worksheet cannot be found.
- incompatible change: change `CompatibilityError` to `UnmatchedNumberOfColumnsError` .
