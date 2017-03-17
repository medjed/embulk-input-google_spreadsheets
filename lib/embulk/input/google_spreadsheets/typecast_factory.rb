module Embulk
  module Input
    class GoogleSpreadsheets < InputPlugin
      module TypecastFactory
        def self.create(type, task)
          raise ConfigError.new("`embulk-input-google_spreadsheets`: unknown typecast '#{type}'") if type.nil? or !type.is_a?(String)

          type = type.downcase
          path = build_typecast_class_path(type)
          raise ConfigError.new("`embulk-input-google_spreadsheets`: Typecast class path does not exist '#{path}'") unless File.exist?(path)

          require path
          typecast_class(type).new(task)
        end

        private

        def self.typecast_class(type)
          Object.const_get("Embulk::Input::GoogleSpreadsheets::Typecast::#{camelize(type)}Typecast")
        end

        def self.build_typecast_class_path(type)
          File.expand_path("typecast/#{type}_typecast.rb", __dir__)
        end

        def self.camelize(snake)
          snake.split('_').map{|w| w[0] = w[0].upcase; w}.join
        end
      end
    end
  end
end
