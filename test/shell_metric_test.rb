require "lib/neutrino/client"
require "test/unit"
require 'mocha'

module Neutrino
  module Client
    class TestShellMetric < Test::Unit::TestCase
      def setup
        Config.defaults!
      end

      def test_initialization_calls_query
        ShellMetric.expects(:execute).with("somecmd").returns(100)
        m = ShellMetric.new(:commands => {:myval => "somecmd"})
      end

      def test_execute_calculates_value
        cmd = "ps aux | wc -l"
        ShellMetric.expects(:execute).with(cmd)
        m = ShellMetric.new(:commands => {:myval => cmd})
      end

      def test_creates_values_hash
        ShellMetric.stubs(:execute).with("somecmd").returns(100)
        ShellMetric.stubs(:execute).with("othercmd").returns(150)
        m = ShellMetric.new(:commands => {:myval => "somecmd", :bval => "othercmd"})
        assert_equal m.values[:myval], 100
        assert_equal m.values[:bval], 150
      end

      def test_reporter_logs_warnings_for_empty_output
        cmd = "ps aux | wc -l"
        Open3.stubs(:popen3).with(cmd).returns("")
        Log.expects(:warn)
        ShellMetric.execute(cmd)
      end

      def test_reporter_logs_debugs
        cmd = "ps aux | wc -l"
        Open3.stubs(:popen3).with(cmd).returns("100")
        Log.expects(:debug)
        ShellMetric.execute(cmd)
      end

      def test_executes_command
        cmd = "ps aux | wc -l"
        Open3.expects(:popen3).with(cmd).returns("100")
        ShellMetric.execute(cmd)
      end
    end
  end
end