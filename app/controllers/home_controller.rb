require 'rubygems'
require 'fast_stemmer'

class HomeController < ApplicationController
  
  def tokenize(text)
    tokens = text.downcase.scan(/[\w']+/)
    
    returns = []
    
    for token in tokens do
      returns.push(token.stem)
    end
  end
  
  def index
    @ponies = ["apple bloom", "applejack", "fluttershy", "pinkie pie", "rainbow dash", "rarity", "spike", "twilight sparkle"]
    
    @data = File.read("transcripts/Applejack.txt").split("\n")
    
    @tokens = self.tokenize("Howdy what's up?");
  end
end
