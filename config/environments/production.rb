Rails.application.configure do
  config.action_mailer.default_url_options = { host: "https://godeck.fr" }
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  config.require_master_key = true

  # Enable serving static files from the `/public` folder for Render
  config.public_file_server.enabled = true

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass # Commented out to avoid conflicts with Tailwind

  # Enable runtime asset compilation in production for Tailwind CSS
  config.assets.compile = true
  config.assets.css_compressor = nil

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on Cloudinary (see config/storage.yml for options).
  config.active_storage.service = :cloudinary
  
  # Configure Active Storage to use direct uploads and resolve redirects
  config.active_storage.resolve_model_to_route = :rails_storage_redirect
  config.active_storage.replace_on_assign_to_many = false
  config.active_storage.track_variants = true

  # Mount Action Cable outside main process or domain.
  config.action_cable.mount_path = nil
  config.action_cable.url = 'wss://godeck.fr/cable'
  config.action_cable.allowed_request_origins = [ 'https://godeck.fr', /https:\/\/godeck.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Set log level to info in production for better performance
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use memory store for caching in production
  config.cache_store = :memory_store, { size: 64.megabytes }

  # Use async adapter for Active Job
  config.active_job.queue_adapter = :async
  config.active_job.queue_name_prefix = "cardmonkey_production"

  config.action_mailer.perform_caching = false

  # Configure mailer for production
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV['SMTP_ADDRESS'],
    port: ENV['SMTP_PORT'],
    domain: 'godeck.fr',
    user_name: ENV['SMTP_USERNAME'],
    password: ENV['SMTP_PASSWORD'],
    authentication: 'plain',
    enable_starttls_auto: true
  }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
