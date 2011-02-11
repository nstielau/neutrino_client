require 'open3'

module Neutrino
  module Client
    class ShellMetric < Metric
      property :command

      def self.execute(command)
        parsed_value = Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
          stdout.read.strip
        end
        raise StandardError.new("Could not parse a value from \"#{command}\". Got '#{parsed_value}'") if parsed_value.nil? || parsed_value == ""
        return parsed_value
      end

      def value
        v = ShellMetric.execute(self.command)
        Log.debug("#{self.command} returns '#{v}'")
        v
      end
    end
  end
end