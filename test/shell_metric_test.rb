require "neutrino/client"
require "test/unit"
require 'mocha'

module Neutrino
  module Client
    class TestShellMetric < Test::Unit::TestCase
      def setup
        Config.defaults!
      end

      def test_calculates_value
        cmd = "ps aux | wc -l"
        m = ShellMetric.new(:command => cmd)
        ShellMetric.expects(:execute).with(cmd)
        m.value
      end

      def test_executes_command
        cmd = "ps aux | wc -l"
        Open3.expects(:popen3).with(cmd)
        ShellMetric.execute(cmd)
      end
    end
  end
end