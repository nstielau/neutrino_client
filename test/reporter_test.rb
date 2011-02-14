require "neutrino/client"
require "test/unit"
require 'mocha'
require 'fakeweb'

module Neutrino
  module Client
    class TestReporter < Test::Unit::TestCase
      def setup
        Config.defaults!
        Config[:metadata] = {:datacenter => "EC2"}
        ShellMetric.stubs(:execute).returns(3.14159)

        FakeWeb.allow_net_connect = false
      end

      def test_reporter_should_call_record_one_per_metric
        metrics = Reporter.get_metrics
        Reporter.expects(:record).times(metrics.length)
        Reporter.report
      end

      def test_reporter_swallows_errors_and_logs_warnings
        Open3.stubs(:popen3).returns('')
        metrics = Reporter.get_metrics
        Log.expects(:warn).times(metrics.length)
        Reporter.report
      end

      def test_reporter_adds_munin_plugins
        Dir.expects(:glob).with("/somedir/*").returns(["/path1", "/path2"])
        MuninMetric.expects(:new).with(:munin_plugin_path => "/path1").returns(Metric.new)
        MuninMetric.expects(:new).with(:munin_plugin_path => "/path2").returns(Metric.new)
        Config.munin_plugin_globs "/somedir/*"
        Reporter.report
      end
    end
  end
end