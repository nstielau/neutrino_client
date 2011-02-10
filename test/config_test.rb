require "neutrino/client"
require "test/unit"

module Neutrino
  module Client
    class TestConfig < Test::Unit::TestCase
      def setup
        Config.defaults!
      end

      def test_log_level_defaults_to_info
        assert_equal(:info, Config.log_level)
      end

      def test_metadata_defaults_to_empty_hash
        assert_equal({}, Config.metadata)
      end

      def test_default_config_file
        assert_equal("/etc/neutrino.rb", Config.config_file)
      end
    end
  end
end