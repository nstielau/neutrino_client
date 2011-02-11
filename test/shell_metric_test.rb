require "neutrino/client"
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
        m = ShellMetric.new(:command => cmd)
        ShellMetric.expects(:execute).with(cmd)
        m.execute
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