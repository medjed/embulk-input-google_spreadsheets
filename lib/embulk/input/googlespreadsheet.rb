require_relative 'googlespreadsheet/gss_session'
require_relative 'googlespreadsheet/type_converter'

module Embulk
  module Input

    class Googlespreadsheet < InputPlugin
      Plugin.register_input("googlespreadsheet", self)

      # support config by file path or content which supported by org.embulk.spi.unit.LocalFile
      # json_keyfile:
      #   content: |
      class LocalFile
        # return JSON string
        def self.load(v)
          if v.is_a?(String)
            File.read(v)
          elsif v.is_a?(Hash)
            v["content"]
          end
        end
      end

      def self.transaction(config, &control)
        task = {
          # auth_method:
          #   - json_key
          #   - refresh_token
          "auth_method"     => config.param("auth_method", :string, default:"json_key"),
          # account:
          #   - service account for json_key auth_method
          #   - normal google account for refresh_token auth_method
          "account"         => config.param("account", :string),
          # json_keyfile:
          #   - private_key file for json_key auth_method
          #   - refresh_token file for refresh_token auth_method
          "json_keyfile"         => config.param("json_keyfile", LocalFile),

          "spreadsheet_key" => config.param("spreadsheet_key", :string),
          "worksheet_title" => config.param("worksheet_title", :string),
          "start_column"    => config.param("start_column", :integer, default: 1),
          "start_row"       => config.param("start_row", :integer, default: 1),
          "end_row"         => config.param("end_row", :integer, default: -1),

          # columns:
          #   - {name:a, type:string}
          #   - {name:b, type:long}
          "columns"         => config.param("columns", :array)
        }

        columns = []
        index = -1
        columns.concat task["columns"].map{|c|
          index += 1
          Column.new(index, c["name"], c["type"].to_sym)
        }

        resume(task, columns, 1, &control)
      end

      def self.resume(task, columns, count, &control)
        task_reports = yield(task, columns, count)

        next_config_diff = {}
        return next_config_diff
      end

      def init
        @session = GssSession.new(@task)
        @converter = TypeConverter.new
      end

      def run
        end_column = @task["start_column"] + @task["columns"].length - 1
        result = @session.fetch(@task["start_row"], @task["start_column"], @task["end_row"], end_column)
        result.each do |line|
          page_builder.add(@converter.convert(@task["columns"], line))
        end
        page_builder.finish

        task_report = {}
        return task_report
      end
    end

  end
end
