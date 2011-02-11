require 'digest/md5'
require 'open3'

module Neutrino
  module Client
    class Reporter
      def self.get_value(cmd)
        Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
          stdout.read.strip
        end
      end

      def self.record(metric)
        Log.debug("Recording: metric.to_json")
        `curl --silent -X POST -H 'Content-Type: application/json' -d '#{metric.to_json}' http://neutrino2.heroku.com/record`
      end

      def self.get_metrics
        [
          Metric.new({
            :name => "CPU Steal",
            :value => Reporter.get_value("iostat | grep -A1 avg-cpu | tail -1 | awk '{print $5}'"),
            :group => "system",
            :type => "CPU"
          }),
          Metric.new({
            :name => "User CPU",
            :value => Reporter.get_value("iostat | grep -A1 avg-cpu | tail -1 | awk '{print $1}'"),
            :group => "system",
            :type => "CPU",
            :display_options => {:min => 0, :max => 1}
          }),
          Metric.new({
            :name => "Idle CPU",
            :value => Reporter.get_value("iostat | grep -A1 avg-cpu | tail -1 | awk '{print $6}'"),
            :group => "system",
            :type => "CPU",
            :display_options => {:min => 0, :max => 100}
          }),
          Metric.new({
            :name => "Free Memory",
            :value => Reporter.get_value("cat /proc/meminfo  | grep 'MemFree' | awk '{print $2}'"),
            :group => "system",
            :type => 'memory',
            :display_options => {:min => 0, :max => Reporter.get_value("cat /proc/meminfo  | grep 'MemTotal' | awk '{print $2}'")}
          }),
          Metric.new({
            :name => "Load Avg (1m)",
            :value => Reporter.get_value("cat /proc/loadavg | awk '{print $1}'"),
            :group => "system",
            :type => 'load'
          }),
          Metric.new({
            :name => "Load Avg (5m)",
            :value => Reporter.get_value("cat /proc/loadavg | awk '{print $2}'"),
            :group => "system",
            :type => 'load'
          }),
          Metric.new({
            :name => "Load Avg (15m)",
            :value => Reporter.get_value("cat /proc/loadavg | awk '{print $3}'"),
            :group => "system",
            :type => 'load'
          }),
        ]
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
