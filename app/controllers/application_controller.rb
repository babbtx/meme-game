class ApplicationController < ActionController::API
  include JwtSecured
  include CurrentUser

  rescue_from Graphiti::Errors::InvalidRequest, with: :render_invalid_request

  protected

  def render_invalid_request(ex)
    logger.info "Invalid request: request=#{request.body} message=#{ex.message}"
    render_jsonapi_error(ex, status: 400)
  end

  def render_jsonapi_error(ex, status: 500)
    status = Symbol === status ? Rack::Utils::SYMBOL_TO_STATUS_CODE[status] : status
    code =  Rack::Utils::HTTP_STATUS_CODES[status]
    body = {errors: [{code: code, status: status.to_s}]}
    body[:errors][0][:detail] = ex.message unless Rails.env.production?
    render json: body, status: status
  end
end
