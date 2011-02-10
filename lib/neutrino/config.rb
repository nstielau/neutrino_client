module Neutrino
  module Client
    class Config
      extend(Mixlib::Config)

      log_level   :info
      config_file "/etc/neutrino.rb"
    end
  end
end