require 'yaml'

class Something
  def initialize()
    @disp = "I am a duck"
  end
  
  def doit()
    print @disp
  end
end

s = YAML.load_file("config.cfg")
s.doit