Ponyplacementproject::Application.routes.draw do

  match "/" => "pages#index"
  match "/evaluate" => "pages#evaluate"
  match "/how" => "pages#how"
  match "/code" => "pages#code"
  match "/about" => "pages#about"
  match "/feedback" => "pages#feedback"
  
  match "evaluate/do" => "evaluate#do"
  
  match "oauth/" => "pages#evaluate"
  match "oauth/begin" => "oauth#begin_oauth"
  match "oauth/authorize" => "oauth#authorize"
  
end
