require 'digest/md5'

module Neutrino
  module Client
    class Reporter
      def self.get_value(cmd)
        `#{cmd}`.strip
      end

      def self.record(result)
        Log.debug(result.to_json)
        #`curl --silent -X POST -H 'Content-Type: application/json' -d '#{result.to_json}' http://neutrino2.heroku.com/record`
      end

      def self.get_metrics
        [
          {
            :name => "CPU Steal",
            :value => Reporter.get_value("iostat | grep -A1 avg-cpu | tail -1 | awk '{print $5}'"),
            :group => "system",
            :type => "CPU"
          },
          {
            :name => "User CPU",
            :value => Reporter.get_value("iostat | grep -A1 avg-cpu | tail -1 | awk '{print $1}'"),
            :group => "system",
            :type => "CPU",
            :display_options => {:min => 0, :max => 1}
          },
          {
            :name => "Idle CPU",
            :value => Reporter.get_value("iostat | grep -A1 avg-cpu | tail -1 | awk '{print $6}'"),
            :group => "system",
            :type => "CPU",
            :display_options => {:min => 0, :max => 100}
          },
          {
            :name => "Free Memory",
            :value => Reporter.get_value("cat /proc/meminfo  | grep 'MemFree' | awk '{print $2}'"),
            :group => "system",
            :type => 'memory',
            :display_options => {:min => 0, :max => Reporter.get_value("cat /proc/meminfo  | grep 'MemTotal' | awk '{print $2}'")}
          },
          {
            :name => "Load Avg (1m)",
            :value => Reporter.get_value("cat /proc/loadavg | awk '{print $1}'"),
            :group => "system",
            :type => 'load'
          },
          {
            :name => "Load Avg (5m)",
            :value => Reporter.get_value("cat /proc/loadavg | awk '{print $2}'"),
            :group => "system",
            :type => 'load'
          },
          {
            :name => "Load Avg (15m)",
            :value => Reporter.get_value("cat /proc/loadavg | awk '{print $3}'"),
            :group => "system",
            :type => 'load'
          }
        ]
      end

      def self.report
        metrics = get_metrics
        hostname = `hostname`
        host_id = Digest::MD5.hexdigest(hostname).to_i(16);

        metrics.each do |m|
          modifier = 1-((rand * 100).to_i%25.0)/100
          result = {:metadata => Config.metadata}
          result[:metadata][:metric_group] = m[:group]
          result[:metadata][:name] = m[:name]
          result[:metadata][:type] = m[:type]
          result[:value] = m[:value]
          result[:metadata][:hostname] = hostname
          result[:display_options] = m[:display_options] unless m[:display_options].nil?
          metric_id = Digest::MD5.hexdigest("#{m[:name]}#{hostname}")
          result[:name] = metric_id
          Reporter.record(result)
        end
      end
    end
  end
end
