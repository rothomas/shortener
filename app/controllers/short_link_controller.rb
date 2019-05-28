class ShortLinkController < ApplicationController

  def shorten
    params.require([:long_url, :user_id])

    link = ShortLink.find_or_create_by!(params.permit(:long_url, :user_id)) do |link|
      link.short_code = ShortCode.generate
    end

    render json: { long_url: link.long_url, short_link: url_for(action: 'follow', short_code: link.short_code) }
  end

  def follow
    short_code = params.require(:short_code)
    is_analytics = short_code.end_with? '+'
    short_code = short_code[0...-1] if is_analytics
    link = ShortLink.find_for_request(short_code, request, is_analytics)

    if link.nil?
      render status: 404, body: '404 Not Found'
    elsif is_analytics
      render json: link.to_analytics
    else
      redirect_to link.long_url
    end

  end

end