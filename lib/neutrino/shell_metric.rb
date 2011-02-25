require 'open3'

module Neutrino
  module Client
    class ShellMetric < Metric
      property :commands

      def initialize(opts={})
        super(opts)
        query
      end

      def self.execute(command)
        parsed_value = Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
          stdout.read.strip
        end
        Log.debug("'#{command}' outputs '#{parsed_value}'")
        Log.warn("'#{command}' outputs '#{parsed_value}'") if parsed_value.nil? || parsed_value.empty?
        return parsed_value
      end

      def query
        values_hash = {}
        self.commands.each_pair do |name, cmd|
          values_hash[name] = ShellMetric.execute(cmd)
        end
        self.values = values_hash
      end
    end
  end
end