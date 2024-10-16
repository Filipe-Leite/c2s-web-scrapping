Rails.application.routes.draw do
  post '/web_scraper', to: 'products#create'
  get '/products', to: 'products#index'
end