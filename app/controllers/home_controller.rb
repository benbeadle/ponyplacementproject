class HomeController < ApplicationController
  def index
    @ponies = ["apple bloom", "applejack", "fluttershy", "pinkie pie", "rainbow dash", "rarity", "spike", "twilight sparkle"]
    
    
    
    @data = File.read("transcripts/Applejack.txt").split("\n");
  end
end
