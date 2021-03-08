# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get '/lock_out' => 'lock_out#index'
post '/lock_out/lock/:year/:month' => 'lock_out#lock', :as => :lock_date
post '/lock_out/unlock/:year/:month' => 'lock_out#unlock', :as => :unlock_date