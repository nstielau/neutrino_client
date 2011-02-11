module Neutrino
  module Client
    class Reporter

      def self.record(metric)
        Log.info("Recording: #{metric.to_json}")
        HTTParty.post('http://neutrino2.heroku.com/record', :body => metric.to_json)
        # `curl --silent -X POST -H 'Content-Type: application/json' -d '#{metric.to_json}' http://neutrino2.heroku.com/record`
      end

      def self.get_metrics
        [
          ShellMetric.new({
            :name => "CPU Steal",
            :command => "iostat | grep -A1 avg-cpu | tail -1 | awk '{print $5}'",
            :group => "system",
            :type => "CPU"
          }),
          ShellMetric.new({
            :name => "User CPU",
            :command => "iostat | grep -A1 avg-cpu | tail -1 | awk '{print $1}'",
            :group => "system",
            :type => "CPU",
            :display_options => {:min => 0, :max => 1}
          }),
          ShellMetric.new({
            :name => "Idle CPU",
            :command => "iostat | grep -A1 avg-cpu | tail -1 | awk '{print $6}'",
            :group => "system",
            :type => "CPU",
            :display_options => {:min => 0, :max => 100}
          }),
          ShellMetric.new({
            :name => "Free Memory",
            :command => "cat /proc/meminfo  | grep 'MemFree' | awk '{print $2}'",
            :group => "system",
            :type => 'memory',
            :display_options => {:min => 0, :max => ShellMetric.execute("cat /proc/meminfo  | grep 'MemTotal' | awk '{print $2}'")}
          }),
          ShellMetric.new({
            :name => "Load Avg (1m)",
            :command => "cat /proc/loadavg | awk '{print $1}'",
            :group => "system",
            :type => 'load'
          }),
          ShellMetric.new({
            :name => "Load Avg (5m)",
            :command => "cat /proc/loadavg | awk '{print $2}'",
            :group => "system",
            :type => 'load'
          }),
          ShellMetric.new({
            :name => "Load Avg (15m)",
            :command => "cat /proc/loadavg | awk '{print $3}'",
            :group => "system",
            :type => 'load'
          }),
          ShellMetric.new({
            :name => "Process Count",
            :command => "ps aux | wc -l",
            :group => "system",
            :type => 'process'
          })
        ]
      end

      def self.report
        get_metrics.each do |m|
          m.hostname = `hostname`.strip
          m.base_metadata = Config.metadata
          begin
            Log.warn("Executing")
            m.execute
            Log.warn("Executed, recording...")
            Reporter.record(m)
          rescue StandardError => e
            Log.warn("Error running #{m.name}: #{e}")
          end
        end
      end
    end
  end
end
