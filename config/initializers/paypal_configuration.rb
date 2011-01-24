PAYPAL_CONFIG = YAML::load(File.open("#{RAILS_ROOT}/config/paypal.yml"))
PAYPAL_CONFIG.symbolize_keys!