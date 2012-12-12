class OauthController < ApplicationController
  
  def begin_oauth
    request_token = @client.authentication_request_token(:oauth_callback => 'http://ponyplacementproject.com/oauth/authorize')
    
    session[:secret] = request_token.secret

    redirect_to request_token.authorize_url
  end
  
  #TODO: Make sure user authorized
  def authorize
    session[:oauth_token] = params[:oauth_token]
    session[:oauth_verifier] = params[:oauth_verifier]
    redirect_to :controller => 'evaluate', :action => 'do'
  end
  
end
