require 'mixlib/cli'

module Neutrino
  module Client
    class CLI
      include Mixlib::CLI

      option :log_level,
        :short => "-l LEVEL",
        :long  => "--log_level LEVEL",
        :description => "Set the log level (debug, info, warn, error, fatal)",
        :proc => Proc.new { |l| l.to_sym }

      option :help,
        :short => "-h",
        :long => "--help",
        :description => "Show this message",
        :on => :tail,
        :boolean => true,
        :show_options => true,
        :exit => 0

      def run(argv=ARGV)
        parse_options(argv)
        # Load config from file
        Config.from_file(Config.config_file) if File.exist?(Config.config_file)
        # Overrides from command-line
        Config.merge!(config)
      end
    end
  end
end