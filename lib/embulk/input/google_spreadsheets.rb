require_relative 'google_spreadsheets/error'
require_relative 'google_spreadsheets/record_typecaster'
require_relative 'google_spreadsheets/auth'
require_relative 'google_spreadsheets/spreadsheets_client'
require_relative 'google_spreadsheets/pager'

module Embulk
  module Input

    class GoogleSpreadsheets < InputPlugin
      Plugin.register_input('google_spreadsheets', self)

      # support config by file path or content which supported by org.embulk.spi.unit.LocalFile
      # json_keyfile:
      #   content: |
      class LocalFile
        # return JSON string
        def self.load(v)
          if v.is_a?(String)
            File.read(v)
          elsif v.is_a?(Hash)
            v['content']
          end
        end
      end

      class CustomColumns
        # NOTE: if raised, rescue and re-raise as Embulk::ConfigError
        def self.load(v)
          raise "`embulk-input-google_spreadsheets`: Invalid value '#{v}' for :array_of_hash" unless v.is_a?(Array)
          v.each do |c|
            raise "`embulk-input-google_spreadsheets`: Invalid value '#{v}' for :array_of_hash" unless c.is_a?(Hash)
          end

          complete_default(v.dup)
        end

        def self.complete_default(columns)
          columns.map do |c|
            c = c.dup
            if c['type'] == 'timestamp'
              c['format'] = c['format'] || default_format
              c['timezone'] = c['timezone'] || default_timezone
            end
            c['typecast']  = c['typecast'] || default_typecast
            c
          end
        end

        def self.default_format
          # ref. https://github.com/embulk/embulk/blob/936c5d5a20af3086f7d1e5779a89035105bb975b/embulk-core/src/main/java/org/embulk/spi/type/TimestampType.java#L10
          # `Time.strptime` does not support `%6N`, so use `%N` instead.
          @default_format ||= '%Y-%m-%d %H:%M:%S.%N %z'
        end

        def self.default_format=(format)
          @default_format = format
        end

        def self.default_timezone
          @default_timezone ||= 'UTC'
        end

        def self.default_timezone=(timezone)
          @default_timezone = timezone
        end

        def self.default_typecast
          @default_typecast ||= 'strict'
        end

        def self.default_typecast=(typecast)
          @default_typecast = typecast
        end
      end

      def self.logger
        ::Embulk.logger
      end

      def logger
        self.class.logger
      end

      def self.configure(config)
        task = {}
        # auth_method:
        #   - service_account
        #   - authorized_user
        #   - compute_engine
        #   - application_default
        task['auth_method'] = config.param('auth_method', :string, default: 'authorized_user')
        # json_keyfile: Fullpath of json key
        #   if `auth_method` is `authorized_user`, this plugin supposes the format
        #   is the below.
        #   {
        #     "client_id":"xxxxxxxxxxx.apps.googleusercontent.com",
        #     "client_secret":"xxxxxxxxxxx",
        #     "refresh_token":"xxxxxxxxxxx"
        #   }
        #
        #   if `auth_method` is `compute_engine` or `application_default`, this
        #   option is not required.
        task['json_keyfile']           = config.param('json_keyfile',          LocalFile, default: nil)
        task['spreadsheets_url']       = config.param('spreadsheets_url',       :string)
        task['worksheet_title']        = config.param('worksheet_title',        :string)
        task['start_column']           = config.param('start_column',           :integer, default: 1)
        task['start_row']              = config.param('start_row',              :integer, default: 1)
        task['end_row']                = config.param('end_row',                :integer, default: -1)
        task['max_fetch_rows']         = config.param('max_fetch_rows',         :integer, default: 10000)
        # FORMATTED_VALUE, UNFORMATTED_VALUE, FORMULA are available.
        # ref. https://developers.google.com/sheets/api/reference/rest/v4/ValueRenderOption
        task['value_render_option']    = config.param('value_render_option',    :string,  default: 'FORMATTED_VALUE')
        task['null_string']            = config.param('null_string',            :string,  default: '')
        task['stop_on_invalid_record'] = config.param('stop_on_invalid_record', :bool,    default: true)
        # columns: this option supposes an array of hash has the below structure.
        #   - name
        #   - type
        #   - format
        #   - timezone
        #   - typecast: default: strict
        CustomColumns.default_format   = task['default_timestamp_format'] = config.param('default_timestamp_format', :string, default: CustomColumns.default_format)
        CustomColumns.default_timezone = task['default_timezone']         = config.param('default_timezone',         :string, default: CustomColumns.default_timezone)
        CustomColumns.default_typecast = task['default_typecast']         = config.param('default_typecast',         :string, default: CustomColumns.default_typecast)
        task['columns'] = config.param('columns', CustomColumns)

        task['end_column'] = task['start_column'] + task['columns'].length - 1

        logger.debug { "`embulk-input-google_spreadsheets`: configured task '#{task.reject{|k, v| k == 'json_keyfile'}.to_json}'"}
        task
      end

      def self.configure_columns(task)
        task['columns'].map.with_index do |c, i|
          Column.new(i, c['name'], c['type'].to_sym, c['format'])
        end
      end

      def self.transaction(config, &control)
        task = configure(config)
        columns = configure_columns(task)
        resume(task, columns, 1, &control)
      end

      def self.resume(task, columns, count, &control)
        task_reports = yield(task, columns, count)

        next_config_diff = {}
        return next_config_diff
      end

      attr_reader :typecaster, :client

      def init
        @typecaster = RecordTypecaster.new(task)
        @client = SpreadsheetsClient.new(task, auth: Auth.new(task), pager: Pager.new(task))
      end

      def stop_on_invalid_record?
        task['stop_on_invalid_record']
      end

      def run
        client.worksheet_each_record do |record|
          begin
            record = typecaster.transform_by_columns(record)
            page_builder.add(record)
          rescue => e
            if stop_on_invalid_record?
              raise e if e.is_a?(ConfigError) or e.is_a?(DataError)
              raise DataError.new(e)
            end
            logger.warn{ "`embulk-input-google_spreadsheets`: Error '#{e}' occurred. Skip '#{record}'" }
          end
        end

        page_builder.finish

        task_report = {}
        return task_report
      end
    end
  end
end

