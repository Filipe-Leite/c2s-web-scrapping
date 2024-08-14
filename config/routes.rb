Rails.application.routes.draw do
  post '/web_scraper', to: 'products#create'
end
