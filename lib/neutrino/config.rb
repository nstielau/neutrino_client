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
         log_level :info
         config_file "/etc/neutrino.rb"
      end

      Config.defaults!
    end
  end
end