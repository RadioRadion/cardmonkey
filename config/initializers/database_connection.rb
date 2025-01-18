# Handle connection pool for Puma workers
if defined?(Puma)
  Puma.cli_config.options.fetch(:max_threads, 5).times do
    ActiveRecord::Base.connection_pool.checkout
  end
end
