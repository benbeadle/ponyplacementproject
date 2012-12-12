class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :twitter_client, :only => [:begin_oauth]
  #before_filter :twitter_client_auth, :only => [:do]
  before_filter :twitter_client_auth_ajax, :only => [:analyze]
  
  
  #Authorize the user using the session variables
  #Called when analyzing
  protected
  def twitter_client_auth_ajax
    
    #@client = []
    #return
    
    self.twitter_client
    begin
      @client.authorize(
        session[:oauth_token],
        ENV["twitter_secret"],
        :oauth_verifier => session[:oauth_verifier]
      )
    rescue Exception => e
      puts e.message
      @client = nil
    end
  end
  
  #Authorize the user using the session variables
  #Called when navigating to do
  #TODO: Route to real error page?
  protected
  def twitter_client_auth
    self.twitter_client
    begin
      @client.authorize(
        session[:oauth_token],
        ENV["twitter_secret"],
        :oauth_verifier => session[:oauth_verifier]
      )
    rescue Exception => e
      session[:error] = e.message
      redirect_to "/evaluate/"
    end
  end
  
  #Simply create the client global variable
  protected
  def twitter_client
    @client = TwitterOAuth::Client.new(
    :consumer_key => ENV["twitter_key"],
    :consumer_secret => ENV["twitter_secret"]
    )
  end
  
  
  #Remove links, and usernames, and hashtags
  def tweet_tokenize(text)
    text = text.gsub /(^|\s)(@|#)(\w+)/, ""
    text = text.gsub /https?:\/\/[\S]+/, ""
    tweet = self.tokenize(text)
    tweet
  end
  
  
  #Returns the full name of the pony
  def pony_full_name(abbrev)
    
    name = ""
    if abbrev == "rainbow"
      name = "Rainbow Dash"
    elsif abbrev == "fluttershy"
      name = "Fluttershy"
    elsif abbrev == "twilight"
      name = "Twilight Sparkle"
    elsif abbrev == "rarity"
      name = "Rarity"
    elsif abbrev == "pinkie"
      name = "Pinkie Pie"
    elsif abbrev == "applejack"
      name = "Applejack"
    end
    
    name
  end
  
  #The ponies_total hash has the short names of the ponies
  #This will convert to show the full name for the graph
  def pony_scores_to_name(ponies_total)
    return_total = Hash.new(0)
    ponies_total.each do |pony, score|
      return_total[self.pony_full_name(pony)] = score
    end
    return_total = return_total.sort_by{|term, sim| sim}.reverse
  end
  
  def pony_description(abbrev)
    desc = ""
    if abbrev == "rainbow"
      desc = "This Pegasus pony is the epitome of loyalty. While this pony can be a bit too confident sometimes and can never turn down a good nap, she is extremely athletic and competitive. While she can be a bit blunt with her friends, she can also show a fair amount of patience and compassion for them. She also has a mischievous side and is known as a trickster."
    elsif abbrev == "fluttershy"
      desc = "This Pegasus pony is the kindest pony you will ever meet. She can be incredibly shy and timid and is faithful and considerate when handling all types of animals. She is compassionate to all even when they do not show her the same in return, and she truly believes \"we all just need to be shown a little kindness\". While not the best flyer, she is very skilled in caretaking, music, and sewing. She has a gentle, serene personality and can be sweet, soft-spoken, graceful and sometimes fearful."
    elsif abbrev == "twilight"
      desc = "This unicorn pony is quite skilled in magic. She has a tendency to rely on logic instead of instinct and is very studious. She often confuses her friends with the use of advanced and technical terms. She is often anxious when faced with tests and can overreact. She often shows empathy and patience when sharing her knowledge with her friends and is skeptical of superstition and all things she cannot find in her books."
    elsif abbrev == "rarity"
      desc = "This unicorn pony is a fashionista. She loves all things beauty and the spotlight. She is very poised and has a very formal vocabulary. She can get carried away with details. She can also be quite tough and resourceful when needed and takes control of situations well. She represents the spirit of generosity. She would help any friend or animal in need."
    elsif abbrev == "pinkie"
      desc = "This earth pony is extremely exuberant, enthusiastic, happy, silly, talkative, jolly, and giggly. As she is always giggling and smiling, she represents laughter. She is the happiest pony around. She loves party planning, bursting into random songs and dances, and baking. She marches to the beat of her own drum and definitely a free spirit."
    end
    desc
  end
  
  #Tokenize and remove all stop words
  #I put this here so it doesn't take up room in the eval controller
  def tokenize(input)
    
    tokens = input.downcase.scan(/[\w']+/)
    
    returns = []
    
    for token in tokens do
      #returns.push(token.stem)
      returns.push(token)
    end
    
    stop_words = ["a", "able", "about", "above", "abst", "accordance", "according", "accordingly", "across", "act", "actually", "added", "adj", "affected", "affecting", "affects", "after", "afterwards", "again", "against", "ah", "all", "almost", "alone", "along", "already", "also", "although", "always", "am", "among", "amongst", "an", "and", "announce", "another", "any", "anybody", "anyhow", "anymore", "anyone", "anything", "anyway", "anyways", "anywhere", "apparently", "approximately", "are", "aren", "arent", "arise", "around", "as", "aside", "ask", "asking", "at", "auth", "available", "away", "awfully", "b", "back", "be", "became", "because", "become", "becomes", "becoming", "been", "before", "beforehand", "begin", "beginning", "beginnings", "begins", "behind", "being", "believe", "below", "beside", "besides", "between", "beyond", "biol", "both", "brief", "briefly", "but", "by", "c", "ca", "came", "can", "cannot", "can't", "cause", "causes", "certain", "certainly", "co", "com", "come", "comes", "contain", "containing", "contains", "could", "couldnt", "d", "date", "did", "didn't", "different", "do", "does", "doesn't", "doing", "done", "don't", "down", "downwards", "due", "during", "e", "each", "ed", "edu", "effect", "eg", "eight", "eighty", "either", "else", "elsewhere", "end", "ending", "enough", "especially", "et", "et-al", "etc", "even", "ever", "every", "everybody", "everyone", "everything", "everywhere", "ex", "except", "f", "far", "few", "ff", "fifth", "first", "five", "fix", "followed", "following", "follows", "for", "former", "formerly", "forth", "found", "four", "from", "further", "furthermore", "g", "gave", "get", "gets", "getting", "give", "given", "gives", "giving", "go", "goes", "gone", "got", "gotten", "h", "had", "happens", "hardly", "has", "hasn't", "have", "haven't", "having", "he", "hed", "hence", "her", "here", "hereafter", "hereby", "herein", "heres", "hereupon", "hers", "herself", "hes", "hi", "hid", "him", "himself", "his", "hither", "home", "how", "howbeit", "however", "hundred", "i", "id", "ie", "if", "i'll", "im", "immediate", "immediately", "importance", "important", "in", "inc", "indeed", "index", "information", "instead", "into", "invention", "inward", "is", "isn't", "it", "itd", "it'll", "its", "itself", "i've", "j", "just", "k", "keep", "keeps", "kept", "kg", "km", "know", "known", "knows", "l", "largely", "last", "lately", "later", "latter", "latterly", "least", "less", "lest", "let", "lets", "like", "liked", "likely", "line", "little", "'ll", "look", "looking", "looks", "ltd", "m", "made", "mainly", "make", "makes", "many", "may", "maybe", "me", "mean", "means", "meantime", "meanwhile", "merely", "mg", "might", "million", "miss", "ml", "more", "moreover", "most", "mostly", "mr", "mrs", "much", "mug", "must", "my", "myself", "n", "na", "name", "namely", "nay", "nd", "near", "nearly", "necessarily", "necessary", "need", "needs", "neither", "never", "nevertheless", "new", "next", "nine", "ninety", "no", "nobody", "non", "none", "nonetheless", "noone", "nor", "normally", "nos", "not", "noted", "nothing", "now", "nowhere", "o", "obtain", "obtained", "obviously", "of", "off", "often", "oh", "ok", "okay", "old", "omitted", "on", "once", "one", "ones", "only", "onto", "or", "ord", "other", "others", "otherwise", "ought", "our", "ours", "ourselves", "out", "outside", "over", "overall", "owing", "own", "p", "page", "pages", "part", " particular", "particularly", "past", "per", "perhaps", "placed", "please", "plus", "poorly", "possible", "possibly", "potentially", "pp", "predominantly", "present", "previously", "primarily", "probably", "promptly", "proud", "provides", "put", "q", "que", "quickly", "quite", "qv", "r", "ran", "rather", "rd", "re", "readily", "really", "recent", "recently", "ref", "refs", "regarding", "regardless", "regards", "related", "relatively", "research", "respectively", "resulted", "resulting", "results", "right", "run", "s", "said", "same", "saw", "say", "saying", "says", "sec", "section", "see", "seeing", "seem", "seemed", "seeming", "seems", "seen", "self", "selves", "sent", "seven", "several", "shall", "she", "shed", "she'll", "shes", "should", "shouldn't", "show", "showed", "shown", "showns", "shows", "significant", "significantly", "similar", "similarly", "since", "six", "slightly", "so", "some", "somebody", "somehow", "someone", "somethan", "something", "sometime", "sometimes", "somewhat", "somewhere", "soon", "sorry", "specifically", "specified", "specify", "specifying", "still", "stop", "strongly", "sub", "substantially", "successfully", "such", "sufficiently", "suggest", "sup", "sure", "t", "take", "taken", "taking", "tell", "tends", "th", "than", "thank", "thanks", "thanx", "that", "that'll", "thats", "that've", "the", "their", "theirs", "them", "themselves", "then", "thence", "there", "thereafter", "thereby", "thered", "therefore", "therein", "there'll", "thereof", "therere", "theres", "thereto", "thereupon", "there've", "these", "they", "theyd", "they'll", "theyre", "they've", "think", "this", "those", "thou", "though", "thoughh", " thousand", " throug", "through", "throughout", "thru", "thus", "til", "tip", " to", "together", "too", "took", "toward", "towards ", "tried", "tries", "truly", "try", "trying", "ts", "twice", "two", "u", "un", "under", "unfortunately", "unless", "unlike", "unlikely", "until", "unto", "up", "upon", "ups", "us", "use", "used", "useful", "usefully", "usefulness", "uses", "using", "usually", "v", "value", "various", "'ve", "very", "via", "viz", "vol", "vols", "vs", "w", "want", "wants", "was", "wasn't", "way", "we", "wed", "welcome", "we'll", "went", "were", "weren't", "we've", "what", "whatever", "what'll", "whats", "when", "whence", "whenever", "where", "whereafter", "whereas", "whereby", "wherein", "wheres", "whereupon", "wherever", "whether", "which", "while", "whim", "whither", "who", "whod", "whoever", "whole", "who'll", "whom ", "whomever", "whos", "whose", "why", "widely", "willing", "wish", "with", "within", "without", "won't", "words", "world", "would", "wouldn't", "www", "x", "y", "yes", "yet", "you", "youd", "you'll", "your", "youre", "yours", "yourself", "yourselves", "you've", "z", "zero", "twilight", "swilight sparkle", " sparkle", "rainbow dash", "rainbow", "dash", "fluttershy", "rarity", "applejack", "spike", "to", "i'm", "apple", "well", "it's", "you're", "that's", "pinkie", "will", "they're"]
    #stop_words = ["you", "i", "to", "the", "a", "and", "that", "of", "is", "it", "what", "this", "we", "my", "in", "just", "but", "be", "all", "have", "me", "oh", "dono", "don't", "not", "are", "i'm", "for", "so", "it's", "was", "with", "now", "get"]

    #uniq removes duplicates!
    return_array = []
    #if params[:stop] == "true"
    #  return_array = returns.uniq - stop_words
    #else
    #  return_array = returns.uniq
    #end
    return_array = returns.uniq - stop_words
    #return_array = returns.uniq
  end
end
