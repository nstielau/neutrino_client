require 'hashie'
require 'digest/md5'

module Neutrino
  module Client
    class Metric < Hashie::Dash
      property :hostname
      property :base_metadata

      property :group
      property :type
      property :name
      property :values
      property :display_options

      def metric_id
        raise StandardError.new("Generating a metric_id requires a name and hostname") unless name && hostname
        Digest::MD5.hexdigest("#{name}#{hostname}")
      end

      def to_json
        to_h.to_json
      end

      def to_h
        raise StandardError.new("Requires values") unless values
        raise StandardError.new("Requires hostname") unless hostname
        {
          :metadata => (base_metadata || {}).merge({
            :name => self.name,
            :group => self.group,
            :type => self.type,
            :hostname => self.hostname
          }),
          :display_options => self.display_options,
          :values => self.values || {}
        }
      end
    end
  end
end
