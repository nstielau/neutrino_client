require 'open3'

module Neutrino
  module Client
    class MuninMetric < Metric
      property :munin_plugin_path

      def initialize(opts={})
        super(opts)
        configure
        # query
      end

      def self.execute_and_parse(command)
        output = Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
          stdout.read.strip
        end
        result = {}
        output.split("\n").each do |line|
          whole_line, key, value = line.match(/(\S*) (.*)/).to_a
          key_parts = key.split(/\.|_/)
          if key_parts.length == 2
            result[key_parts.first] ||= {}
            result[key_parts.first][key_parts.last] = value
          else
            result[key_parts.first] = value
          end
        end
        result
      end

      def self.configure_plugin(path)
        self.execute_and_parse("#{path} config")
      end

      def self.query_plugin(path)
        self.execute_and_parse(path)
      end

      def configure
        plugin_configuration = MuninMetric.configure_plugin(self.munin_plugin_path)
        self.base_metadata ||= {}
        if plugin_configuration["graph"]
          self.base_metadata["group"] = plugin_configuration["graph"]["category"]
          self.base_metadata["type"] = plugin_configuration["graph"]["vlabel"]
          self.base_metadata["name"] = plugin_configuration["graph"]["title"]
        end
      end

      def query
        plugin_query = MuninMetric.query_plugin(self.munin_plugin_path)
        begin
        self.value = plugin_query.to_a.first[1]["value"]
        rescue
        end
      end

    end
  end
end