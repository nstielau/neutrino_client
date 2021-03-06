require "lib/neutrino/client"
require "test/unit"
require 'mocha'

module Neutrino
  module Client
    class TestMuninMetric < Test::Unit::TestCase
      def setup
        Config.defaults!
      end

      def test_properties
        path = "/path/to/plugin"
        Open3.stubs(:popen3)
        m = MuninMetric.new(:munin_plugin_path => path)
        assert_equal m.munin_plugin_path, path
      end

      def test_configure_plugin
        path = "/some_plugin"
        Open3.expects(:popen3).with("#{path} config").returns("graph_title Load average\ngraph_args --base 1000 -l 0\ngraph_vlabel load\ngraph_scale no\ngraph_category system\nload.label load\nload.warning 10\nload.critical 120\ngraph_info The load average of the machine describes how many processes are in the run-queue (scheduled to run \"immediately\").\nload.info Average load for the five minutes.\n")
        m = MuninMetric.configure_plugin(path)
        assert_equal m.class, Hash
        assert_not_nil m["graph"]
        assert_equal m["graph"]["title"], "Load average"
        assert_equal m["graph"]["args"], "--base 1000 -l 0"
        assert_equal m["graph"]["vlabel"], "load"
        assert_equal m["graph"]["scale"], "no"
        assert_equal m["graph"]["category"], "system"
        assert_not_nil m["load"]
        assert_equal m["load"]["label"], "load"
        assert_equal m["load"]["warning"], "10"
        assert_equal m["load"]["critical"], "120"
        assert_equal m["load"]["info"], "Average load for the five minutes."
      end

      def test_query_plugin
        path = "/some_plugin"
        Open3.expects(:popen3).with(path).returns("load.value 0.17\n")
        m = MuninMetric.query_plugin(path)
        assert_equal m.class, Hash
        assert_not_nil m["load"]
        assert_equal m["load"]["value"], "0.17"
      end

      def test_configuring_sets_base_metadata
        path = "/some_plugin"
        Open3.stubs(:popen3).with("#{path}")
        Open3.expects(:popen3).with("#{path} config").returns("graph_title Load average\ngraph_args --base 1000 -l 0\ngraph_vlabel load\ngraph_scale no\ngraph_category system\nload.label load\nload.warning 10\nload.critical 120\ngraph_info The load average of the machine describes how many processes are in the run-queue (scheduled to run \"immediately\").\nload.info Average load for the five minutes.\n")
        m = MuninMetric.new(:munin_plugin_path => path)
        assert_equal m.base_metadata["group"], "system"
        assert_equal m.base_metadata["type"], "load"
        assert_equal m.base_metadata["name"], "Load average"
      end

      def test_can_handle_memory_output
        path = "/some_plugin"
        output = "swap_cache.value 0\nswap.value 0\n"
        Open3.stubs(:popen3).with("#{path} config").returns("")
        Open3.stubs(:popen3).with("#{path}").returns(output)
        m = MuninMetric.new(:munin_plugin_path => path)
      end

      def test_can_handle_multiple_values
        path = "/some_plugin"
        output = "swap_cache.value 33\nswap.value 44\n"
        Open3.stubs(:popen3).with("#{path} config").returns("")
        Open3.stubs(:popen3).with("#{path}").returns(output)
        m = MuninMetric.new(:munin_plugin_path => path)
        assert_equal m.values["swap_cache"], 33
        assert_equal m.values["swap"], 44
      end

      def test_can_handle_no_values
        path = "/some_plugin"
        output = "swap_cache.value\nswap.value 44\n"
        Open3.stubs(:popen3).with("#{path} config").returns("")
        Open3.stubs(:popen3).with("#{path}").returns(output)
        m = MuninMetric.new(:munin_plugin_path => path)
        assert_equal m.values["swap_cache"], nil
        assert m.values.keys.include? "swap_cache"
      end

      def test_instanciation_configures_and_queries
        path = "/some_plugin"
        Open3.stubs(:popen3).with("#{path}")
        Open3.expects(:popen3).with("#{path} config")
        MuninMetric.new(:munin_plugin_path => path)
      end

      def test_query
        path = "/some_plugin"
        Open3.expects(:popen3).with("#{path} config").returns("")
        Open3.expects(:popen3).with(path).returns("load.value 123\n")
        m = MuninMetric.new(:munin_plugin_path => path)
        assert m.values.keys.include? "load"
        assert_equal m.values["load"], 123
      end
    end
  end
end
