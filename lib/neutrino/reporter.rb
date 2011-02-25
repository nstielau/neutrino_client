require 'httparty'

module Neutrino
  module Client
    class Reporter

      def self.record(metric)
        Log.info("Recording: #{metric.to_json}")
        HTTParty.post('http://neutrino2.heroku.com/record', :body => metric.to_json)
        # `curl --silent -X POST -H 'Content-Type: application/json' -d '#{metric.to_json}' http://neutrino2.heroku.com/record`
      end

      def self.get_metrics
        ms = [
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
            :name => "Load Avg (15m)",
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
        Dir.glob(Config.munin_plugin_globs).each{|plugin_path| ms << MuninMetric.new(:munin_plugin_path => plugin_path)}
        ms
      end

      def self.report
        get_metrics.each do |m|
          m.hostname = `hostname`.strip
          m.base_metadata = Config.metadata
          begin
            Reporter.record(m)
          rescue StandardError => e
            Log.warn("Error running '#{m.name}': #{e}")
          end
        end
      end
    end
  end
end
