Rails.application.routes.draw do
  resources :parkingspots

  get 'spots/api_nr' => 'parkingspots#api1'
  get 'spots/api_r' => 'parkingspots#api2'
end
