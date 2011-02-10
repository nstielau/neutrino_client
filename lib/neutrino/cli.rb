module Neutrino
  module Client
    class CLI
      def run(argv=ARGV)
        parse_options(argv)
        MyConfig.merge!(config)
      end
    end
  end
end