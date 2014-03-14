class DetectLocaleController < ActionController::Base
  layout false
  include LocalesHelper
  include CurrentUserHelper

  before_filter :cors_preflight_check,           only: :video
  after_filter :cors_set_access_control_headers, only: :video

  def show
    d = best_locale(detected_locale(Translation.frontpage_locales))
    if current_locale != d
      I18n.locale = d
      Measurement.increment('detect_locale.foreign')
    else
      Measurement.increment('detect_locale.default')
      head :ok
    end
  end

  def video
    @locale = best_locale(detected_locale(Translation.video_locales))

    if @locale == default_locale
      Measurement.increment('detect_video_locale.default')
    else
      Measurement.increment('detect_video_locale.foreign')
    end

    render text: @locale
  end

  private

  def current_locale
    (Translation.locales & [params[:current_locale]]).first || default_locale
  end

  # return the CORS access control headers.
  def cors_set_access_control_headers
    # headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Origin'] = 'https://love.loomio.org'
    headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  # If this is a preflight OPTIONS request, then short-circuit the
  # request, return only the necessary headers and return an empty
  # text/plain.
  def cors_preflight_check
    if request.method == :options
      # headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Origin'] = 'https://love.loomio.org'
      headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
      headers['Access-Control-Max-Age'] = '1728000'
      render :text => '', :content_type => 'text/plain'
    end
  end
end
