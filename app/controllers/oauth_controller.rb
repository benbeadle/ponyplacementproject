
class OauthController < ApplicationController
  
  before_filter :client, :only => [:begin_oauth, :authorize]
  
  
  def client
    @client = TwitterOAuth::Client.new(
    :consumer_key => 'd7yzB6cpQaFYEIUz7VkVcQ',
    :consumer_secret => 'xXmpeUdcnyv1W4hBnOGBC2CF61srZSCAfxoK3CrJ0n8'
    )
  end
  
  def begin_oauth
    
    request_token = @client.authentication_request_token(:oauth_callback => 'http://3g44.localtunnel.com/oauth/authorize')
    
    session[:secret] = request_token.secret

    redirect_to request_token.authorize_url
    
      
  end
  
  def authorize
    session[:oauth_token] = params[:oauth_token]
    session[:oauth_verifier] = params[:oauth_verifier]
    redirect_to :controller => 'evaluate', :action => 'do'
    
    #timeline = @client.user_timeline({:count => 50})
    
    #@tweets = []
    
    #timeline.each do |tweet|
    #  text = tweet["text"]
    #  text = text.gsub /(^|\s)(@|#)(\w+)/, ""
    #  text = text.gsub /https?:\/\/[\S]+/, ""
      
    #  if text.strip != ""
    #    @tweets.push(text)
    #  end
    #end
    
    
  end
  
end
