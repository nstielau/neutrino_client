require 'open3'

module Neutrino
  module Client
    class ShellMetric < Metric
      property :commands

      def self.execute(command)
        parsed_value = Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
          stdout.read.strip
        end
        Log.debug("#{command} returns '#{parsed_value}'")
        raise StandardError.new("Could not parse a value from \"#{command}\". Got '#{parsed_value}'") if parsed_value.nil? || parsed_value == ""
        return parsed_value
      end

      def values
        values_hash = {}
        self.commands.each_pair do |name, cmd|
          values_hash[name] = ShellMetric.execute(cmd)
        end
        values_hash
      end
    end
  end
end