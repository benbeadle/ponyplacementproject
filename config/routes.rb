Ponyplacementproject::Application.routes.draw do
  

  match "/" => "pages#index"
  match "/evaluate" => "pages#evaluate"
  match "/how" => "pages#how"
  match "/code" => "pages#code"
  match "/about" => "pages#about"
  
  match "oauth/" => "pages#evaluate"
  match "oauth/begin" => "oauth#begin"
  
end
