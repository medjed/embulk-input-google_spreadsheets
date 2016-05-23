# Googlespreadsheet input plugin for Embulk

Embulk input plugin to fetch data from Google Spreadsheet.

## Overview

* **Plugin type**: input

## Configuration

| name                | type        | requirement | default         | description            |
|:--------------------|:------------|:------------|:----------------|:-----------------------|
|  auth_method        | string      | optional    | "json_key"      | `json_key` or `refresh_token` |
|  account            | string      | required    |                 | service_account or normal google account |
|  json_keyfile       | string      | required    |                 | path to the keyfile |
|  spreadsheet_key    | string      | required    |                 | https://docs.google.com/spreadsheets/d/`spreadsheet_key`/edit#gid=... |
|  worksheet_title    | string      | required    |                 | worksheet title |
|  start_column       | integer     | optional    | 1               |  |
|  start_row          | integer     | optional    | 1               |  |
|  end_row            | integer     | optional    | -1              |  |
|  columns            | array       | required    |                 |  |

##### about keyfile
* private json key
 * auth_method: `json_key`
 * account: service account
* refresh token
 * auth_method: `refresh_token`
 * account: normal google account

##### about columns
* name: column name
* type: boolean, long, double, string, timestamp, json


