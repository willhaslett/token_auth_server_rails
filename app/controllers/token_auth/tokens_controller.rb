# frozen_string_literal: true

module TokenAuth
  # Manage configuration and authentication tokens.
  class TokensController < ::TokenAuth::BaseController
    def index
      @entity_id = params[:entity_id]
      @authentication_token = AuthenticationToken
                              .find_by(entity_id: @entity_id)
      @configuration_token = ConfigurationToken
                             .find_by(entity_id: @entity_id)
    end
  end
end
