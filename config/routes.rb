Rails.application.routes.draw do
  post '/callback' => 'nogibot#callback'
end
