require "neutrino/client"
require "test/unit"
require 'mocha'

module Neutrino
  module Client
    class TestReporter < Test::Unit::TestCase
      def setup
        Config.defaults!
        Reporter.stubs(:get_value).returns("3.14159")
      end

      def test_reporter_records_metrics
        metrics = Reporter.get_metrics
        Reporter.expects(:record).times(metrics.length)
        Reporter.report
      end
    end
  end
end