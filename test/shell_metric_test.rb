require "lib/neutrino/client"
require "test/unit"
require 'mocha'

module Neutrino
  module Client
    class TestShellMetric < Test::Unit::TestCase
      def setup
        Config.defaults!
      end

      def test_execute_calculates_value
        cmd = "ps aux | wc -l"
        m = ShellMetric.new(:commands => {:myval => cmd})
        ShellMetric.expects(:execute).with(cmd)
        m.values
      end

      def test_creates_values_hash
        m = ShellMetric.new(:commands => {:myval => "somecmd", :bval => "othercmd"})
        ShellMetric.stubs(:execute).with("somecmd").returns(100)
        ShellMetric.stubs(:execute).with("othercmd").returns(150)
        values_hash = m.values
        assert_equal values_hash[:myval], 100
        assert_equal values_hash[:bval], 150
      end

      def test_executes_command
        cmd = "ps aux | wc -l"
        Open3.expects(:popen3).with(cmd).returns(100)
        ShellMetric.execute(cmd)
      end

      def test_execute_raises_error_without_value
        Open3.stubs(:popen3).returns('')
        assert_raises(StandardError){ShellMetric.execute("some bogus command")}
      end
    end
  end
end