require_relative 'web_parser_base.rb'

class DcmWebParser < WebParserBase
  DCM_TOP_URL = 'https://www.nttdocomo.co.jp/mydocomo/data'

  IS_DEBUG = false

  # CONSTRUCTOR.
  #
  def initialize(
      in_dcm_network_indicator,
      dcm_network_pin,
      dcm_id,
      dcm_pass)
    @in_dcm_network_indicator = in_dcm_network_indicator
    @dcm_network_pin = dcm_network_pin
    @dcm_id = dcm_id
    @dcm_pass = dcm_pass
  end

  # Access to web page and get data.
  #
  # @return is_success, month_used_mb, yesterday_used_mb
  def get_data_from_web
    # Access to DCM server.
    is_success, month_used_mb, yesterday_used_mb = get_dcm_sim_stats

    if IS_DEBUG
      puts "## is_success = #{is_success}"
      puts "## month_used_mb = #{month_used_mb}"
      puts "## yesterday_used_mb = #{yesterday_used_mb}"
    end

    return is_success, month_used_mb, yesterday_used_mb
  end

  private

    # Get DCM SIM Stats.
    #
    # @return is_success, month_used_mb, yesterday_used_mb,
    def get_dcm_sim_stats

      is_success = false

      # Set up Capybara.
      session = setup_capybara

      # Get top page.
      session.visit(DCM_TOP_URL)

      login_url = nil
      is_success = do_with_retry {
        login_url = get_login_url_from_top_page(session)
        puts "## Login URL = #{login_url}" if IS_DEBUG
        !login_url.nil? # OK/NG of block.
      } # get_with_retry

      return false, INVALID_VALUE, INVALID_VALUE if !is_success

      # Get login page.
      session.visit(login_url)

      is_success = do_with_retry {
        input_id(session)
      }

      return false, INVALID_VALUE, INVALID_VALUE if !is_success

      is_success = do_with_retry {
        click_next_button(session)
      }

      return false, INVALID_VALUE, INVALID_VALUE if !is_success

      is_success = do_with_retry {
        input_pass(session)
      }

      return false, INVALID_VALUE, INVALID_VALUE if !is_success

      is_success = do_with_retry {
        click_login_button(session)
      }

      return false, INVALID_VALUE, INVALID_VALUE if !is_success

      month_used = nil
      yesterday_used = nil
      is_success = do_with_retry {
        month_used, yesterday_used = get_data(session)
        !month_used.nil? && !yesterday_used.nil?
      }

      return false, INVALID_VALUE, INVALID_VALUE if !is_success

      puts "## Month Used = #{month_used} GB"
      puts "## Yesterday Used = #{yesterday_used} GB"

      # Convert from GB to MB.
      month_used_mb = ((month_used.to_f) * 1000).to_i
      yesterday_used_mb = ((yesterday_used.to_f) * 1000).to_i

      return true, month_used_mb, yesterday_used_mb
    end

    # Do after go to top page.
    # @return String Login URL or nil.
    def get_login_url_from_top_page(session)
      doc = Nokogiri::HTML.parse(session.html)
      puts "## dcm top doc\n#{doc}" if IS_DEBUG

      login_url = nil

      links = doc.css('a')
      links.each { |link|
        href = link.attributes['href'].value
        url = URI.unescape(href)
        puts "## available url = #{url}" if IS_DEBUG

        login_url = url if url.include?(DCM_TOP_URL)
      }

      return login_url
    end

    # Do after go to login page.
    # @return Boolean Success or not.
    def input_id(session)
      begin
        if session.has_text?(@in_dcm_network_indicator)
          # In DCM network.

          # TODO:

          pass_input = session.find('input#Di_Pass')
          pass_input.native.send_key(@dcm_network_pin)
        else
          # In public network.
          id_input = session.find('input#Di_Uid')
          id_input.native.send_key(@dcm_id)
        end
      rescue Capybara::ElementNotFound => _
        puts "## login page (id) element not found, retry."
        return false
      end # begin

      return true
    end

    # Do after go to login page.
    # @return Boolean Success or not.
    def click_next_button(session)
      begin
        next_button = session.find('input.button_submit.nextaction')
      rescue Capybara::ElementNotFound => _
        puts "## login page (next button) element not found, retry."
        return false
      end

      # Go to next page.
      next_button.trigger('click')

      return true
    end

    # Do after ID input done.
    # @return Boolean Success or not.
    def input_pass(session)
      begin
        if session.has_text?(@in_dcm_network_indicator)
          # In DCM network.

          # TODO:

          pass_input = session.find('input#Di_Pass')
          pass_input.native.send_key(@dcm_network_pin)
        else
          # In public network.
          pass_input = session.find('input#Di_Pass')
          pass_input.native.send_key(@dcm_pass)
        end
      rescue Capybara::ElementNotFound => _
        puts "## login page (pass) element not found, retry."
        return false
      end # begin

      return true
    end

    # Do after go to login page.
    # @return Boolean Success or not.
    def click_login_button(session)
      begin
        login_button = session.find('input.button_submit.nextaction')
      rescue Capybara::ElementNotFound => _
        puts "## login page (login button) element not found, retry."
        return false
      end

      # Go to data page.
      login_button.trigger('click')

      return true
    end

    # Do after go to data page.
    # @return Int month_used, Int yesterday_used If failed, nil return.
    def get_data(session)
      month_used = nil
      yesterday_used = nil

      doc = Nokogiri::HTML.parse(session.html)

      if IS_DEBUG
        puts "#### data page"
        puts doc
      end

      month_used = doc.
          css('section#mydcm_data_data').
          css('div.in-data-use').
          css('span.card-t-number').
          text
      month_used = nil if month_used.empty?

      yesterday_used = doc.
          css('section#mydcm_data_3day').
          css('div#mydcm_data_3day-03').
          css('dl.mydcm_data_3day-03-02').
          css('span.card-t-ssnumber').
          text
      yesterday_used = nil if yesterday_used.empty?

      return month_used, yesterday_used
    end

  # private

end

