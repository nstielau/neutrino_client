require "lib/neutrino/client"
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
        FakeWeb.register_uri(:post, %r|neutrino2\.heroku\.com/|, :body => "{ok:1}")
      end

      def test_reporter_should_call_record_one_per_metric
        Reporter.expects(:record).times(Reporter.get_metrics.length)
        Reporter.report
      end

      def test_reporter_adds_munin_plugins
        dummy_metric = Metric.new(:name => "a", :hostname => 'asdf', :values => {:a => 1})
        Dir.expects(:glob).with("/somedir/*").returns(["/path1", "/path2"])
        MuninMetric.expects(:new).with(:munin_plugin_path => "/path1").returns(dummy_metric)
        MuninMetric.expects(:new).with(:munin_plugin_path => "/path2").returns(dummy_metric)
        Config.munin_plugin_globs "/somedir/*"
        Reporter.get_metrics
      end

      def test_report_call_get_metrics
        Reporter.expects(:get_metrics).returns([])
        Reporter.report
      end

      def test_can_add_custom_plugin_via_config
        cust_metric = ShellMetric.new({
          :name => "Custom Plugin",
          :commands => {:cust => "cust_command"},
          :group => "system",
          :type => "CPU",
          :display_options => {:min => 0, :max => 100}
        })
        Config.plugins << cust_metric
        ShellMetric.stubs(:execute).returns(100)
        metrics = Reporter.get_metrics
        assert metrics.include?(cust_metric)
      end
    end
  end
end