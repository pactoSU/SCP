require 'yaml'

class Something
  def initialize()
    @disp = "I am a duck"
  end
  
  def doit()
    print @disp
  end
end

s = Something.new

File.open("config.cfg", "w") {|f| f.write(s.to_yaml)}