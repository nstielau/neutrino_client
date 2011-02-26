require 'mixlib/config'

module Neutrino
  module Client
    class Config
      extend(Mixlib::Config)

      metadata {}

      def self.defaults!
        self.configuration = {}
        configure do |c|
           c[:metadata] = {}
         end
         log_level :warn
         config_file "/etc/neutrino.rb"
         munin_plugin_globs "/etc/munin/plugins/**"
      end

      Config.defaults!
    end
  end
end