class EvaluateController < ApplicationController
  
  #applejack, fluttershy, pinkie, rarity, rainbow, twilight
  #TRANS_LOC = "#{Rails.root}/app/assets/transcripts/compilation_twilight.txt"
  TRANS_LOC = "#{Rails.root}/app/assets/transcripts/pony_compilation.txt"
  KNN = 50 #How many similar lines to take into account
  
  #Used to output term frequencies for testing
  DOC_OUT = "#{Rails.root}/app/assets/tf/ponies_no_stop_no_stem.txt"
  DOC_OUT_BOOL = false
  
  before_filter :calculate_doc_vectors, :only => [:analyze, :find_accuracy]
  
  #The final landing page after Twitter authorization
  def do
  
  end
  
  #This tests the algorithm on the transcripts to find the accuracy
  def find_accuracy
    
    #lines_input = File.read(TRANS_LOC).unpack('C*').pack('U*').downcase.split("\n")
    lines_input = File.read("#{Rails.root}/app/assets/transcripts/compilation_fluttershy.txt").unpack('C*').pack('U*').downcase.split("\n")
    
    total_lines = 0
    total_right = 0
    total_wrong = 0
    total_invalid = 0
    pony_total = Hash.new(0)
    pony_hash = Hash.new{|h, k| h[k] = Hash.new(0)}
    
    lines_input.each do |line|
      puts "line"
      line_split = line.split(" ", 2)
      real_pony = line_split[0]
      line_pony = Hash.new(0)
      tokens = self.tokenize(line_split[1])
      sim_lines = []
      
      #Get all lines which have the tokens this tweet has
      line_ids = []
      tokens.each { |tok| if @index[tok].length > 0 then line_ids.push(@index[tok]) end }
      puts "ids"
      #There was no match for this tweet
      if line_ids.length == 0
        total_invalid += 1
        next
      end
      
      line_ids = line_ids.join(" ").split(" ").uniq
      line_ids.each do |id|
        sim_lines.push(@lines[id.to_i])
        sim_lines.last["sim"] = self.cos_sim(self.normed_vect(tokens), sim_lines.last["vect"])
      end
      #puts "sim"
      #Get the KNN closest ponies
      sim_lines = sim_lines.sort_by{|term, sim| sim}.reverse
      sim_lines_knn = sim_lines.first(KNN)
      #sim_lines_knn = sim_lines
      #puts "knn"
      #puts sim_lines_knn.last["sim"]
      i = 1
      while sim_lines.length > (KNN+i) && sim_lines_knn.last["sim"] == sim_lines.first(KNN+i).last["sim"]
        #puts sim_lines.length.to_s + " " + i.to_s + " " + sim_lines.length.to_s + " " + sim_lines_knn.last["sim"].to_s + " " + sim_lines.first(KNN+i).last["sim"].to_s
        sim_lines_knn.push(sim_lines.first(KNN+i).last)
        i += 1
      end
      #puts sim_lines.first(KNN+i+1).last["sim"].to_s
      #puts ""
      #puts "Added " + i.to_s + " more lines."
      puts "fix"
      sim_lines_knn.each do |line|
        line_pony[line["pony"]] += line["sim"]
        pony_total[line["pony"]] += line["sim"]
      end
      puts "add"
      line_pony = line_pony.sort_by{|term, sim| sim}.reverse
      sum = 0
      line_pony.each {|pony, sim| sum=sum+sim }
      puts "sum"
      percent = ((line_pony.first[1] / sum)*10000).round.to_f/100
      
      pony_hash[real_pony][line_pony.first[0]] += 1
      
      if real_pony == line_pony.first[0]
        total_right += 1
      else
        total_wrong += 1
      end
      total_lines += 1
      
      #puts real_pony + " -> " + line_pony.first[0] + ": " + percent.to_s
      
    end
    
    pony_total = pony_total.sort_by{|term, sim| sim}.reverse
    sum = 0
    pony_total.each {|pony, sim| sum=sum+sim }
      
    percent = ((pony_total.first[1] / sum)*10000).round.to_f/100
    
    puts "Right: " + total_right.to_s + "/" + total_lines.to_s + ": " + (((total_right.to_f / total_lines.to_f)*10000).round.to_f/100).to_s + "%"
    puts "Wrong: " + total_wrong.to_s + "/" + total_lines.to_s + ": " + (((total_wrong.to_f / total_lines.to_f)*10000).round.to_f/100).to_s + "%"
    puts "Invalid: " + total_invalid.to_s + "/" + total_lines.to_s + ": " + (((total_invalid.to_f / total_lines.to_f)*10000).round.to_f/100).to_s + "%"
    puts "Pony: " + pony_total.first[0] + ": " + percent.to_s
    pony_hash.each do |pony, hash|
      hash.each do |pony_2, val|
        puts pony + " " + pony_2 + " " + val.to_s
      end
    end
    puts pony_total
    exit
  end
  
  #Calculate the tf_idf of a term
  def _term_tf_idf(term, count)
      
      return_val = 0
      #Default value of @term_idf is -1
      if count != 0 && @term_idf[term] != -1
        return_val = (1+Math.log(count,2))*@term_idf[term]
      end
      
      return_val
  end
  
  #Convert tokens to a normalized tf-idf vector
  def normed_vect(tokens)
    
    counts = Hash.new(0)
    tokens.each do |tok|
      counts[tok] += 1
    end
    vect = Hash.new(0)
    counts.each do |term, count|
      vect[term] = self._term_tf_idf(term, count)
    end
    
    mag = Math.sqrt(vect.map{|term, count| count*count}.reduce(:+))
    
    vect.each {|t, c| vect[t] = c/mag}
  end
  
  #Find the tf-idf vectors for the terms in the transcripts
  def calculate_doc_vectors
    self.processing_not_used
    #TRANS_LOC.gsub("pony", params[:pony])
    lines_input = File.read(TRANS_LOC).unpack('C*').pack('U*').downcase.split("\n")
    
    @doc_freq = Hash.new(0) #The number of docs each term is in
    @lines = Hash.new #Keep track of all the lines
    @index = Hash.new{|h, k| h[k] = []} #Keeps track of what lines have what tokens
    @term_idf = Hash.new(-1)
    
    line_id = 1 #Make an id for each line
    
    lines_input.each do |line_string|
      #Not sure why this might be blank, but just putting
      #a bandaid on it for now and just skipping the line
      if line_string == ""
        puts "Skip line for being empty which is weird."
        next
      end
      line_arr = line_string.split(" ", 2)
      line = Hash.new
      text = line_arr[1]
      
      line["id"] = line_id
      line["pony"] = line_arr[0]
      line["text"] = text
      line["tokens"] = self.tokenize(text)
      
      #Tokenizing might remove all of the words
      if line["tokens"].length == 0
        next
      end
      
      line["tokens"].each do |tok|
        @doc_freq[tok] += 1
        @index[tok].push(line_id)
      end
      
      @lines[line_id] = line
      line_id += 1
    end
    
    #Used to output term frequencies
    if DOC_OUT_BOOL
      str = ""
      
      rev = @doc_freq.sort_by{|term, sim| sim}.reverse
      rev.each do |arr|
        if str != ""
          str += "\n"
        end
        str += arr[0] + "\t" + arr[1].to_s
      end
      
      File.open(DOC_OUT, 'w') {|f| f.write(str) }
    end
    
    @doc_freq.each do |term, count|
      @term_idf[term] = Math.log(@lines.length / count, 2)
    end
    @lines.each do |id, line|
      line["vect"] = self.normed_vect(line["tokens"])
    end
    
    #File.open("#{Rails.root}/app/assets/idf_2.json", 'w') {|f| f.write(@term_idf.sort_by{|term, sim| term}.reverse.to_json) }
  end
  
  #Calculate the cosine simularity from the normalized vectors
  def cos_sim(tweet_vec, line_vec)
    total = 0.0
    
    tweet_vec.each do |term, count|
      total += count*line_vec[term]
    end
    
    total
  end
  
  #The ajax call to analyze the tweets
  def analyze
    
    #render json: JSON.parse(File.read("#{Rails.root}/app/assets/dev_result_output.json"))
    #return
    
    #Make sure their session is currently authorized
    if @client == nil
      render json: {:error => true}
      return
    end
    
    tweets = self.tweets
    ponies_total = Hash.new(0)
    tweets_output = []
    
    tweets.each do |tweet|
      
      tweet_pony = Hash.new(0)
      tweet_out = Hash.new
      tweet_out["text"] = tweet["text"]
      sim_lines = []
      
      #Get all lines which have the tokens this tweet has
      line_ids = []
      tweet["tokens"].each { |tok| if @index[tok].length > 0 then line_ids.push(@index[tok]) end }
      
      #There was no match for this tweet
      if line_ids.length == 0
        tweet_out["pony"] = "--"
        tweet_out["percent"] = 0
        tweets_output.push(tweet_out)
        next
      end
      
      line_ids = line_ids.join(" ").split(" ").uniq
      line_ids.each do |id|
        sim_lines.push(@lines[id.to_i])
        sim_lines.last["sim"] = self.cos_sim(tweet["vect"], sim_lines.last["vect"])
      end
      
      #Get the KNN closest ponies
      sim_lines = sim_lines.sort_by{|term, sim| sim}.reverse.first(KNN)
      sim_lines.each do |line|
        tweet_pony[line["pony"]] += line["sim"]
        ponies_total[line["pony"]] += line["sim"]
      end
      
      tweet_pony = tweet_pony.sort_by{|term, sim| sim}.reverse
      sum = 0
      tweet_pony.each {|pony, sim| sum=sum+sim }
      
      tweet_out["pony"] = tweet_pony.first[0]
      tweet_out["percent"] = ((tweet_pony.first[1] / sum)*10000).round.to_f/100
      
      tweets_output.push(tweet_out)
    end
    ponies_total = ponies_total.sort_by{|term, sim| sim}.reverse
    
    name = ponies_total.first[0]
    result = Hash.new
    result["winner"] = {
      :short_name => name,
      :name => self.pony_full_name(name),
      :description => self.pony_description(name),
      :percent => (ponies_total.first[1] / ponies_total.inject(0) { |sum, tuple| sum += tuple[1] })*100#,
      #:order => @ponies.join(" ")
    }
    result["stats"] = self.pony_scores_to_name(ponies_total)
    result["tweet_count"] = tweets.length
    result["tweets"] = tweets_output
    #File.open("#{Rails.root}/app/assets/dev_result_output.json", 'w') {|f| f.write(result.to_json) }
    render json: result
    
  end
  
  #Grab all the tweets from the authorized user
  #Should only be called from analyze since before_filter
  #creates the authenticated client
  #Also tokenizes and calculates the vectors
  protected
  def tweets
    timeline = @client.user_timeline({:count => 200})
    
    #File.open("#{Rails.root}/app/assets/tweets/_tweets.json", 'w') {|f| f.write(timeline.to_json) }
    #timeline = JSON.parse(File.read("#{Rails.root}/app/assets/tweets/ben_tweets.json"))
    #timeline = JSON.parse(File.read("#{Rails.root}/app/assets/tweets/lindsey_tweets.json"))
    #timeline = JSON.parse(File.read("#{Rails.root}/app/assets/tweets/rachel_tweets.json"))
    
    #This allows removing items. Remove tweets that don't have tokens"
    timeline.delete_if do |tweet|
      tweet["tokens"] = self.tweet_tokenize(tweet["text"])
      
      if tweet["tokens"].length == 0
        true
      else
        tweet["vect"] = self.normed_vect(tweet["tokens"])
        false
      end
    end
    
    timeline
  end
  
  #This function was used to convert the pony files to UTF-8 and remove empty lines
  def processing_not_used
    #return
    #Must add ".unpack('C*').pack('U*')" since apparently there's some non UTF-8 text in the transcripts
    @ponies = ["fluttershy", "pinkie", "rarity", "applejack", "rainbow", "twilight"].shuffle
    puts @ponies.join(" ")
    out = ""
    @ponies.each do |pony|
      loc = "#{Rails.root}/app/assets/transcripts/compilation_" + pony + ".txt"
      lines = File.read(loc).unpack('C*').pack('U*').downcase.split("\n")
      
      new_lines = ""
      
      lines.each do |line|
        spl = line.split(" ", 2)
        if spl[1] != ""
          if new_lines != ""
            new_lines += "\n"
          end
          new_lines += spl.join(" ")
        end
      end
      
      out += new_lines
      
    end
    File.open("#{Rails.root}/app/assets/transcripts/pony_compilation.txt", 'w') {|f| f.write(out) }
  end
end
