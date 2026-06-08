# Error monitoring. Inert unless SENTRY_DSN is set, so dev/test/CI are unaffected.
if ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.environment = Rails.env
    # Sample a fraction of requests for performance monitoring.
    config.traces_sample_rate = ENV.fetch("SENTRY_TRACES_SAMPLE_RATE", "0.1").to_f
    # Don't send PII by default.
    config.send_default_pii = false
  end
end
