class EvaluateController < ApplicationController
  
  MAX_WORDS = 33000 #Since some ponies talk more, let's limit the amount of words. The least pony said 33025 words
  TWEET_MIN_LENGTH = 75
  KNN = 3
  
  before_filter :client_auth, :only => [:do]
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
  
  def client_auth
    @client = TwitterOAuth::Client.new(
    :consumer_key => 'd7yzB6cpQaFYEIUz7VkVcQ',
    :consumer_secret => 'xXmpeUdcnyv1W4hBnOGBC2CF61srZSCAfxoK3CrJ0n8'
    )
    
    begin
      @client.authorize(
        session[:oauth_token],
        session[:secret],
        :oauth_verifier => session[:oauth_verifier]
      )
    rescue Exception => e
      redirect_to "/evaluate/error"
    end
  end
  
  def tokenize(text)
    tokens = text.downcase.scan(/[\w']+/)
    
    returns = []
    
    for token in tokens do
      returns.push(token.stem)
    end
    
  end
  
  def remove_stop_words(input)
    stop_words = ["a", "able", " about", "above", "abst", "accordance", "according", "accordingly", "across", "act", "actually", "added", "adj", "affected", "affecting", "affects", "after", "afterwards", "again", "against", "ah", "all", "almost", "alone", "along", "already", "also", "although", "always", "am", "among", "amongst", "an", "and", "announce", "another", "any", "anybody", "anyhow", "anymore", "anyone", "anything", "anyway", "anyways", "anywhere", "apparently", "approximately", "are", "aren", "arent", "arise", "around", "as", "aside", "ask", "asking", "at", "auth", "available", "away", "awfully", "b", "back", "be", "became", "because", "become", "becomes", "becoming", "been", "before", "beforehand", "begin", "beginning", "beginnings", "begins", "behind", "being", "believe", "below", "beside", "besides", "between", "beyond", "biol", "both", "brief", "briefly", "but", "by", "c", "ca", "came", "can", "cannot", "can't", "cause", "causes", "certain", "certainly", "co", "com", "come", "comes", "contain", "containing", "contains", "could", "couldnt", "d", "date", "did", "didn't", "different", "do", "does", "doesn't", "doing", "done", "don't", "down", "downwards", "due", "during", "e", "each", "ed", "edu", "effect", "eg", "eight", "eighty", "either", "else", "elsewhere", "end", "ending", "enough", "especially", "et", "et-al", "etc", "even", "ever", "every", "everybody", "everyone", "everything", "everywhere", "ex", "except", "f", "far", "few", "ff", "fifth", "first", "five", "fix", "followed", "following", "follows", "for", "former", "formerly", "forth", "found", "four", "from", "further", "furthermore", "g", "gave", "get", "gets", "getting", "give", "given", "gives", "giving", "go", "goes", "gone", "got", "gotten", "h", "had", "happens", "hardly", "has", "hasn't", "have", "haven't", "having", "he", "hed", "hence", "her", "here", "hereafter", "hereby", "herein", "heres", "hereupon", "hers", "herself", "hes", "hi", "hid", "him", "himself", "his", "hither", "home", "how", "howbeit", "however", "hundred", "i", "id", "ie", "if", "i'll", "im", "immediate", "immediately", "importance", "important", "in", "inc", "indeed", "index", "information", "instead", "into", "invention", "inward", "is", "isn't", "it", "itd", "it'll", "its", "itself", "i've", "j", "just", "k", "keep", "keeps", "kept", "kg", "km", "know", "known", "knows", "l", "largely", "last", "lately", "later", "latter", "latterly", "least", "less", "lest", "let", "lets", "like", "liked", "likely", "line", "little", "'ll", "look", "looking", "looks", "ltd", "m", "made", "mainly", "make", "makes", "many", "may", "maybe", "me", "mean", "means", "meantime", "meanwhile", "merely", "mg", "might", "million", "miss", "ml", "more", "moreover", "most", "mostly", "mr", "mrs", "much", "mug", "must", "my", "myself", "n", "na", "name", "namely", "nay", "nd", "near", "nearly", "necessarily", "necessary", "need", "needs", "neither", "never", "nevertheless", "new", "next", "nine", "ninety", "no", "nobody", "non", "none", "nonetheless", "noone", "nor", "normally", "nos", "not", "noted", "nothing", "now", "nowhere", "o", "obtain", "obtained", "obviously", "of", "off", "often", "oh", "ok", "okay", "old", "omitted", "on", "once", "one", "ones", "only", "onto", "or", "ord", "other", "others", "otherwise", "ought", "our", "ours", "ourselves", "out", "outside", "over", "overall", "owing", "own", "p", "page", "pages", "part", " particular", "particularly", "past", "per", "perhaps", "placed", "please", "plus", "poorly", "possible", "possibly", "potentially", "pp", "predominantly", "present", "previously", "primarily", "probably", "promptly", "proud", "provides", "put", "q", "que", "quickly", "quite", "qv", "r", "ran", "rather", "rd", "re", "readily", "really", "recent", "recently", "ref", "refs", "regarding", "regardless", "regards", "related", "relatively", "research", "respectively", "resulted", "resulting", "results", "right", "run", "s", "said", "same", "saw", "say", "saying", "says", "sec", "section", "see", "seeing", "seem", "seemed", "seeming", "seems", "seen", "self", "selves", "sent", "seven", "several", "shall", "she", "shed", "she'll", "shes", "should", "shouldn't", "show", "showed", "shown", "showns", "shows", "significant", "significantly", "similar", "similarly", "since", "six", "slightly", "so", "some", "somebody", "somehow", "someone", "somethan", "something", "sometime", "sometimes", "somewhat", "somewhere", "soon", "sorry", "specifically", "specified", "specify", "specifying", "still", "stop", "strongly", "sub", "substantially", "successfully", "such", "sufficiently", "suggest", "sup", "sure", "t", "take", "taken", "taking", "tell", "tends", "th", "than", "thank", "thanks", "thanx", "that", "that'll", "thats", "that've", "the", "their", "theirs", "them", "themselves", "then", "thence", "there", "thereafter", "thereby", "thered", "therefore", "therein", "there'll", "thereof", "therere", "theres", "thereto", "thereupon", "there've", "these", "they", "theyd", "they'll", "theyre", "they've", "think", "this", "those", "thou", "though", "thoughh", " thousand", " throug", "through", "throughout", "thru", "thus", "til", "tip", " to", "together", "too", "took", "toward", "towards ", "tried", "tries", "truly", "try", "trying", "ts", "twice", "two", "u", "un", "under", "unfortunately", "unless", "unlike", "unlikely", "until", "unto", "up", "upon", "ups", "us", "use", "used", "useful", "usefully", "usefulness", "uses", "using", "usually", "v", "value", "various", "'ve", "very", "via", "viz", "vol", "vols", "vs", "w", "want", "wants", "was", "wasn't", "way", "we", "wed", "welcome", "we'll", "went", "were", "weren't", "we've", "what", "whatever", "what'll", "whats", "when", "whence", "whenever", "where", "whereafter", "whereas", "whereby", "wherein", "wheres", "whereupon", "wherever", "whether", "which", "while", "whim", "whither", "who", "whod", "whoever", "whole", "who'll", "whom ", "whomever", "whos", "whose", "why", "widely", "willing", "wish", "with", "within", "without", "won't", "words", "world", "would", "wouldn't", "www", "x", "y", "yes", "yet", "you", "youd", "you'll", "your", "youre", "yours", "yourself", "yourselves", "you've", "z", "zero", "Twilight", "Twilight Sparkle", " Sparkle", "Rainbow Dash", "Rainbow", "Dash", "Fluttershy", "Rarity", "Applejack", "Spike", "to", "i'm", "apple", "well"]
    return_array = input - stop_words
    #return_string = text.gsub(stop_words, " ")
  end
  
  def tweet_parse(text)
    text = text.gsub /(^|\s)(@|#)(\w+)/, ""
    text = text.gsub /https?:\/\/[\S]+/, ""
    tweet = self.remove_stop_words(self.tokenize(text))
    tweet
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
    tweet_winner = ""
    tweet_val = 0
    stats = Hash.new(-1)
    total = 0.0
    
    tweets.each do |tweet|
      ponies = self.find_pony(tweet["tokens"])
      
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
  
  def tweets
    
    timeline = @client.user_timeline({:count => 100})
    tweets = []
    
    timeline.each do |tweet|
      text = self.tweet_parse(tweet["text"])
      
      push = Hash.new(0)
      puts text.size
      #if text.strip != ""
      push["tokens"] = text
      push["tweet"] = tweet["text"]
      #end
      tweets.push(push)
    end
    
    tweets
  end
end
