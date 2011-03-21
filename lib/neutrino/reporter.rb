require 'httparty'

module Neutrino
  module Client
    class Reporter

      def self.record(metric)
        Log.info("Recording: #{metric.inspect}")
        Log.debug("Recording JSON: #{metric.to_json}")
        begin
          response = HTTParty.post("http://neutrino2.heroku.com/metrics/#{metric.metric_id}/record", :body => metric.to_h)
          Log.debug "Response: body=#{response.body} code=#{response.code} message=#{response.message} headers=#{response.headers.inspect}"
        rescue => e
          Log.error("Error sending #{metric.inspect}: #{e.inspect}")
        end
      end

      def self.get_metrics
        metrics = [
          ShellMetric.new({
            :name => "User CPU",
            :commands => {:user => "iostat | grep -A1 avg-cpu | tail -1 | awk '{print $1}'"},
            :group => "system",
            :type => "CPU",
            :display_options => {:min => 0, :max => 1}
          }),
          ShellMetric.new({
            :name => "Idle CPU",
            :commands => {:idle => "iostat | grep -A1 avg-cpu | tail -1 | awk '{print $6}'"},
            :group => "system",
            :type => "CPU",
            :display_options => {:min => 0, :max => 100}
          }),
          ShellMetric.new({
            :name => "Free Memory",
            :commands => {:free => "cat /proc/meminfo  | grep 'MemFree' | awk '{print $2}'"},
            :group => "system",
            :type => 'memory'
            # :display_options => {:min => 0, :max => ShellMetric.execute("cat /proc/meminfo  | grep 'MemTotal' | awk '{print $2}'")}
          }),
          ShellMetric.new({
            :name => "Load Avg",
            :commands => {
              "1_min" => "cat /proc/loadavg | awk '{print $1}'",
              "5_min" => "cat /proc/loadavg | awk '{print $2}'",
              "15_min" => "cat /proc/loadavg | awk '{print $3}'",
            },
            :group => "system",
            :type => 'load'
          }),
          ShellMetric.new({
            :name => "Process Count",
            :commands => {:processes => "ps aux | wc -l"},
            :group => "system",
            :type => 'process'
          })
        ]
        Config.plugins.each{|plugin| metrics << plugin}
        Dir.glob(Config.munin_plugin_globs).each{|plugin_path| metrics << MuninMetric.new(:munin_plugin_path => plugin_path)}
        metrics
      end

      def self.report
        get_metrics.each do |m|
          m.hostname = `hostname`.strip
          m.base_metadata = Config.metadata
          Reporter.record(m)
        end
      end
    end
  end
end
