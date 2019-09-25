Rails.application.routes.draw do
  post '/callback' => 'rain#callback'
end
