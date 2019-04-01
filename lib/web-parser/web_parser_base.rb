class WebParserBase
  require 'capybara/poltergeist'
  require 'uri'

  MAX_PARSE_RETRY_COUNT = 10
  RETRY_WAIT_SEC = 1

  INVALID_VALUE = -1

  # Set up capybara instance.
  #
  # @return Object Capybara session instance.
  def setup_capybara
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, { :js_errors => false, :timeout => 10000 })
    end

    session = Capybara::Session.new(:poltergeist)

    session.driver.headers = {
      'User-Agent' => 'Linux Mozilla'
    }

    return session
  end

  # Retry block proc with interval.
  #
  # @return Boolean Success or not.
  def do_with_retry
    raise "No block given." if !block_given?

    count = 0
    is_ok = false
    while count < MAX_PARSE_RETRY_COUNT
      # Wait for AJAX.
      sleep RETRY_WAIT_SEC

      is_ok = yield

      break if is_ok

      count += 1
    end # while

    return is_ok
  end

end

