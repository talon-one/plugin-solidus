require 'spree_core'

module TalonOneSpree
  class Engine < Rails::Engine
    require "solidus_core"

    isolate_namespace Spree
    engine_name "solidus_talon_one"

    def self.activate
      dir = File.dirname(__FILE__)
      Dir.glob(File.join(dir, "**/*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
      Dir.glob(File.join(dir, "../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      # puts "DECORATORS LOADED ============================================================"
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
