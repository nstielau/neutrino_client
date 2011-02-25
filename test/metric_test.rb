require "lib/neutrino/client"
require "test/unit"
require 'mocha'

module Neutrino
  module Client
    class TestMetric < Test::Unit::TestCase
      def setup
        Config.defaults!
      end

      def test_metric_instatiation
        metric = Metric.new
        assert metric
      end

      def test_metric_attributes
        attrs = {
          :name => "Load Avg (15m)",
          :value => 747,
          :group => "system",
          :type => 'load',
          :display_options => {:width => 100}
        }
        metric = Metric.new(attrs)
        assert_equal metric.group, attrs[:group]
        assert_equal metric.type, attrs[:type]
        assert_equal metric.name, attrs[:name]
        assert_equal metric.value, attrs[:value]
        assert_equal metric.display_options, attrs[:display_options]
      end

      def test_can_set_hostname
        hostname = "some_hostname"
        metric = Metric.new
        metric.hostname = hostname
        assert_equal metric.hostname, hostname
      end

      def test_metric_class_base_metadata
        base_metadata = {"some_hostname" => "true"}
        metric = Metric.new
        metric.base_metadata = base_metadata
        assert_equal metric.base_metadata, base_metadata
      end

      def test_metric_id
        hostname = "panda.com"
        name = "a_metric"
        metric = Metric.new(:hostname => hostname, :name => name)
        assert_equal metric.metric_id, Digest::MD5.hexdigest("#{name}#{hostname}")
      end

      def test_metric_id_raises_without_hostname
        metric = Metric.new(:name => "a_metric")
        assert_raises(StandardError){ metric.metric_id }
      end

      def test_metric_id_raises_without_hostname
        metric = Metric.new(:hostname => "a_metric.com")
        assert_raises(StandardError){ metric.metric_id }
      end

      def test_to_json_calls_to_h
        metric = Metric.new(:hostname => "a_metric.com", :name => "asdf")
        metric.expects(:to_h)
        metric.to_json
      end

      def test_metric_to_h
        attrs = {
          :name => "Load Avg (15m)",
          :value => 0.11,
          :group => "system",
          :type => 'load',
          :display_options => {:width => 100}
        }
        metric = Metric.new(attrs)
        metric.hostname = "panda.com"
        metric.base_metadata = {:datacenter => "EC2"}
        result = metric.to_h
        assert_not_nil result[:metadata]
        assert_equal result[:metadata][:datacenter], "EC2"
        assert_equal result[:metadata][:name], attrs[:name]
        assert_equal result[:metadata][:group], attrs[:group]
        assert_equal result[:metadata][:type], attrs[:type]
        assert_equal result[:display_options], attrs[:display_options]
        assert_equal result[:value], attrs[:value]
        assert_equal result[:name], metric.metric_id
      end
    end
  end
end