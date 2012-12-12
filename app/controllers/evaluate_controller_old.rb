class EvaluateController < ApplicationController
  
  MAX_WORDS = 33000 #Since some ponies talk more, let's limit the amount of words. The least pony said 33025 words
  TWEET_MIN_LENGTH = 75
  KNN = 3
  
  before_filter :calculate_tf, :only => [:do]
  
  #TODO: Do more than just get the first MAX_WORDS
  def calculate_tf
    @ponies = ["applejack", "fluttershy", "pinkie pie", "rainbow dash",  "rarity", "twilight sparkle"]
    @ponies_tf = Hash.new(0)
    
    @ponies.each do |pony|
      data = File.read("transcripts/" + pony + ".txt").split("\n").join("\n").downcase
      data = data.gsub(/[0-9]{2} [0-9]{2} /, "") #Remove the season and episode numbers
      @ponies_tf[pony] = self.find_tf(self.remove_stop_words(self.tokenize(data)).first(MAX_WORDS)) #Tokenize
    end
    
  end
  
  
  def find_distance(pony, tweeter)
    distance = 0
    
    tweeter.each do |tkey, tvalue|
        if (pony[tkey] != -1)
            distance += (pony[tkey] - tvalue)**2
        end
    end
    
    distance = Math.sqrt(distance)
  end
  
  def find_pony(tweet_tokens)
    
    result = Hash.new(-1)
    
    @ponies_tf.each do |pkey, pvalue|
      distance = self.find_distance(pvalue, self.find_tf(tweet_tokens))
      result[pkey] = distance
    end
    result = result.sort_by{|key, value| value}.reverse.first(KNN)
  end
  
  #Get the term frequency all of the tokens
  def find_tf(pony_words) 
    tf = Hash.new(-1)
    
    pony_words.each do |word|
        if(tf[word] == -1)
            tf[word] = 1
        else 
            tf[word] = tf[word] + 1
        end
    end
    tf
  end
  
  def do
    tweets = self.tweets()
    
    @winner = ""
    @output = []
    tweet_val = 0
    stats = Hash.new(-1)
    total = 0.0
    
    tweets.each do |tweet|
      ponies = self.find_pony(tweet["tokens"])
      
      tweet_winner = ""
      ponies.each do |key, val|
        if tweet_winner == ""
          tweet_winner = key
        end
        
        if stats[key] == -1
          stats[key] = 0
        else
          stats[key] += val
          total += val
        end
        
        #if statistics[pony][key] == -1
        #  statistics[pony][key] = 1
        #else
        #  statistics[pony][key] += 1
        #end
        
        #if pony == key
        #  right += 1
        #else
        #  wrong += 1
        #end
      end
      
      @output.push(tweet_winner + " -> " + tweet["tweet"])
      @output.push ""
    end
    
    @output.push ""
    @output.push ""
    
    stats = stats.sort_by{|key, value| value}.reverse
    stats.each do |key, val|
      if @winner == ""
        @winner = key
      end
      @output.push key + " -> " + (val/total*100).to_s + "%"
    end
    puts @winner
  end
  
end
