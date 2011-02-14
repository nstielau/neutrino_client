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
      property :value
      property :display_options

      def metric_id
        raise StandardError.new("Requires name and hostname") unless name && hostname
        Digest::MD5.hexdigest("#{name}#{hostname}")
      end

      def to_json
        to_h.to_json
      end

      def to_h
        {
          :metadata => (base_metadata || {}).merge({
            :name => self.name,
            :group => self.group,
            :type => self.type
          }),
          :display_options => self.display_options,
          :name => self.metric_id,
          :value => self.value
        }
      end
    end
  end
end
