class SiteInformation
  attr_accessor :title, :description, :greetings

  def initialize
    @title = "My Site"
    @description = "This is a sample site description."
    @greetings = ["Hello", "Welcome", "Greetings", "こんにちは"]
  end
end
