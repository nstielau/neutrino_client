require 'open3'

module Neutrino
  module Client
    class MuninMetric < Metric
      property :munin_plugin_path

      def initialize(opts={})
        super(opts)
        configure
        query
      end

      def self.execute_and_parse(command)
        output = Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
          stdout.read.strip
        end
        result = {}
        Log.debug("#{command} outputs #{output}")
        output.to_s.split("\n").each do |line|
          whole_line, key, value = line.match(/(\S*) (.*)/).to_a
          key = line.strip if key.nil? # Can be nil if no value is specified
          key_parts = nil
          if key.match("graph_")
            key_parts = key.split(/_/)
          else
            key_parts = key.split(/\./)
          end
          if key_parts.length == 2
            result[key_parts.first] ||= {}
            result[key_parts.first][key_parts.last] = value
          else
            result[key_parts.first] = value
          end
        end
        Log.debug("#{command} output is parsed as #{result.inspect}")
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
          self.name = plugin_configuration["graph"]["title"]
        end
      end

      def query
        plugin_query = MuninMetric.query_plugin(self.munin_plugin_path)
        begin
          values_hash = {}
          plugin_query.to_a.each do |metric|
            name = metric[0]
            val = metric[1]["value"]
            values_hash[name] = val.nil? ? nil : val.to_f
          end
          self.values = values_hash
        rescue => e
          Log.debug("Error querying munin: #{e}")
        end
      end

    end
  end
end