require "neutrino/client"
require "test/unit"
require 'mocha'

module Neutrino
  module Client
    class TestReporter < Test::Unit::TestCase
      def setup
        Config.defaults!
        Config[:metadata] = {:datacenter => "EC2"}
        Reporter.stubs(:get_value).returns("3.14159")
      end

      def test_reporter_records_metrics
        metrics = Reporter.get_metrics
        metrics.each do |m|
          Reporter.expects(:record).with() do |param|
            !param.hostname.nil? &&
            param.type = m.type &&
            param.group == m.group &&
            param.base_metadata == Config.metadata
          end
        end
        Reporter.report
      end
    end
  end
end