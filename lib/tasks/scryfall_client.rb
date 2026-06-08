# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'
require 'fileutils'

# Shared HTTP client for Scryfall.
#
# Centralizes the things Scryfall requires/recommends and that the old code
# was missing:
#   - explicit User-Agent + Accept headers (Scryfall returns 403 without them)
#   - open/read timeouts + bounded retry with backoff
#   - polite rate limiting (>= 50-100ms between requests)
#   - streaming download to disk (never holds the ~2GB bulk file in memory)
#   - streaming iteration over the bulk JSON array (one card at a time)
module ScryfallClient
  USER_AGENT = 'CardMonkey/1.0 (+https://cardmonkey.app; contact@cardmonkey.app)'
  HEADERS = { 'User-Agent' => USER_AGENT, 'Accept' => 'application/json;q=0.9,*/*;q=0.8' }.freeze
  OPEN_TIMEOUT = 15
  READ_TIMEOUT = 180
  RATE_LIMIT_DELAY = 0.1

  module_function

  def get(uri)
    uri = URI(uri.to_s)
    with_retry do
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.open_timeout = OPEN_TIMEOUT
      http.read_timeout = READ_TIMEOUT
      response = http.request(Net::HTTP::Get.new(uri, HEADERS))
      raise "Scryfall HTTP #{response.code} for #{uri}" unless response.is_a?(Net::HTTPSuccess)

      sleep RATE_LIMIT_DELAY # be polite with the Scryfall rate limit
      response.body
    end
  end

  def get_json(uri)
    JSON.parse(get(uri))
  end

  # Stream a (potentially multi-GB) download straight to disk.
  # Uses the `down` gem (already in the Gemfile) so the payload never lives
  # entirely in Ruby memory.
  def download_to(uri, destination)
    require 'down'
    tempfile = Down.download(
      uri.to_s,
      headers: HEADERS,
      open_timeout: OPEN_TIMEOUT,
      read_timeout: READ_TIMEOUT
    )
    FileUtils.mkdir_p(File.dirname(destination))
    FileUtils.mv(tempfile.path, destination)
    destination
  ensure
    tempfile&.close unless tempfile&.closed?
  end

  # Iterate a top-level JSON array of objects, yielding one Hash at a time.
  #
  # When the `oj` gem is available it uses a streaming SAJ parser (constant
  # memory). Otherwise it falls back to a full JSON.parse — correct, but loads
  # the whole file into memory (kept only as a safety net; install `oj`).
  def each_object(path, &block)
    if defined?(Oj)
      File.open(path, 'r') { |io| Oj.saj_parse(ArrayElementHandler.new(&block), io) }
    else
      warn('[ScryfallClient] `oj` gem not loaded: falling back to in-memory JSON.parse (high memory).')
      JSON.parse(File.read(path)).each(&block)
    end
  end

  def with_retry(attempts: 3)
    last_error = nil
    attempts.times do |i|
      return yield
    rescue StandardError => e
      last_error = e
      sleep(2**i) # exponential backoff: 1s, 2s, 4s
    end
    raise last_error
  end

  # SAJ handler that rebuilds each top-level array element into a Ruby Hash,
  # yields it, then drops it. Memory stays proportional to a single card, not
  # the whole file. Does not need to inherit Oj::Saj — Oj.saj_parse only
  # requires an object responding to the callback methods.
  class ArrayElementHandler
    def initialize(&block)
      @block = block
      @stack = [] # open containers; @stack.first is the root array (never retained)
    end

    def hash_start(key)
      open_container({}, key)
    end

    def array_start(key)
      open_container([], key)
    end

    def hash_end(_key)
      close_container
    end

    def array_end(_key)
      close_container
    end

    def add_value(value, key)
      store(value, key)
    end

    def error(message, line, column)
      raise "Scryfall JSON parse error at #{line}:#{column}: #{message}"
    end

    private

    def open_container(container, key)
      store(container, key) unless @stack.empty? # root array is not stored anywhere
      @stack.push(container)
    end

    def close_container
      finished = @stack.pop
      # Only the root array remains -> `finished` was a top-level element.
      @block.call(finished) if @stack.size == 1 && @stack.first.is_a?(Array)
    end

    def store(value, key)
      parent = @stack.last
      return if parent.nil?

      if parent.is_a?(Array)
        parent << value unless @stack.size == 1 # never accumulate into the root array
      else
        parent[key] = value
      end
    end
  end
end
