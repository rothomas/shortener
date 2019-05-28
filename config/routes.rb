Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/short_link', controller: :short_link, action: :shorten
  get '/:short_code', controller: :short_link, action: :follow
end
