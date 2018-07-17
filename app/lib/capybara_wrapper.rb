class CapybaraWrapper
  require 'capybara/poltergeist'

  MAX_PARSE_RETRY_COUNT = 3
  RETRY_WAIT_SEC = 3

  attr_reader :session

  # Initialize web scraping instance.
  def initialize
    # Set up Capybara.
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(
          app,
          {
              :js_errors => false,
              :timeout => 10000,
              :phantomjs_options => [
                  '--debug=no',
                  '--load-images=no',
                  '--ignore-ssl-errors=yes',
                  '--ssl-protocol=any',
              ],
              :debug => false,
          })
    end

    @session = Capybara::Session.new(:poltergeist)
    @session.driver.headers = {
      'User-Agent' => 'Linux Mozilla'
    }

  end

  # Request GET URL.
  #
  # @url String Get target URL.
  def get(url)
    @session.visit(url)
  end

  # Input text to text field of ID.
  #
  # @text String Input text.
  # @id String Element ID. (e.g. input#id, input.class.class)
  def input_to_id(text, id)
    input = @session.find(id)
    input.native.send_key(text)
  end

  # Click on field of ID.
  #
  # @id String Element ID. (e.g. input#id, input.class.class)
  def click_on_id(id)
    button = @session.find(id)
    button.trigger('click')
  end

  # Get text in element nest.
  #
  # @elements [String, Integer][] Nest of elements id/class and order.
  #           order is optional, if passed nil, it means 0.
  #           (e.g. [['sectio#id', 0], ['div.class', 1], ...])
  # @return String Content text in element nest.
  def get_text(elements)
    doc = Nokogiri::HTML.parse(@session.html)

    cur_elm = doc
    elements.each { |element, order|
      order = 0 if order.nil?
      cur_elm = cur_elm.css(element)[order]
    }

    return cur_elm.text
  end

  # Wait for proc done.
  # If the proc raise exception, automatically retry it.
  # After retried as max time, return false.
  #
  # @block Waiting proc may raise exception on failed.
  def wait_for
    raise "No block given." if !block_given?

    count = 0
    is_success = false
    while count < MAX_PARSE_RETRY_COUNT
      # Wait for AJAX.
      sleep RETRY_WAIT_SEC

      begin
        yield
      rescue => e
        puts "## Retry. Element is not found." if e.is_a?(Capybara::ElementNotFound)
        puts "## Retry. Element is nil." if e.is_a?(NoMethodError)
        puts e
        count += 1
        next # Failed.
      end # begin

      is_success = true
      break # Succeeded.

    end # while

    return is_success
  end

  private

  # private

end

