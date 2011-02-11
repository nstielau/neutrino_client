require "neutrino/client"
require "test/unit"
require 'mocha'

module Neutrino
  module Client
    class TestReporter < Test::Unit::TestCase
      def setup
        Config.defaults!
        Config[:metadata] = {:datacenter => "EC2"}
      end

      def test_reporter_should_call_record_one_per_metric
        metrics = Reporter.get_metrics
        Reporter.expects(:record).times(metrics.length)
        Reporter.report
      end
    end
  end
end