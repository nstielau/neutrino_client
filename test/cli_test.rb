require "neutrino/client"
require "test/unit"

module Neutrino
  module Client
    class TestCLI < Test::Unit::TestCase
      def setup
        Config.defaults!
        @cli = Neutrino::Client::CLI.new
      end

      def test_cli_will_set_log_level
        @cli.run(['-l', 'some_log_level'])
        assert_equal(:some_log_level, Config.log_level)
      end
    end
  end
end