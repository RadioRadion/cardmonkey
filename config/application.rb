require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cardmonkey
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Register proper MIME types for JavaScript modules
    config.before_configuration do
      Mime::Type.register "text/javascript", :js
      Mime::Type.register "application/javascript", :mjs
      Mime::Type.register_alias "application/javascript", :module
    end

    # Configure importmap paths
    config.importmap.paths << Rails.root.join("config/importmap.rb")
    config.importmap.cache_sweepers << Rails.root.join("app/javascript")

    # Configure Action Cable
    config.action_cable.mount_path = '/cable'
  end
end
