require 'open3'

module Neutrino
  module Client
    class ShellMetric < Metric
      property :command

      def self.execute(command)
        Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
          r = stdout.read.strip
        end
      end

      def value
        ShellMetric.execute(self.command)
      end
    end
  end
end