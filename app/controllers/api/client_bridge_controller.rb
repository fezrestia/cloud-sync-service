module Api
  class ClientBridgeController < ApplicationController

    skip_before_action :verify_authenticity_token

    def register_fcm
      puts "## ClientBridge.register_fcm : E"

      fcm_token = fcm_token_param

      client_info = ClientInfo.get_primary
      client_info.fcm_token = fcm_token
      client_info.save!

      result = {}
      result['status'] = 'no_error'

      render json: result
      puts "## ClientBridge.register_fcm : X"
    end

    private

      def fcm_token_param
        params.require(:fcm_token)
      end

    # private

  end
end

