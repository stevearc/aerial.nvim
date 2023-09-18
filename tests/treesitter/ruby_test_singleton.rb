class Klassy
  class << self
    def ==(other); end
    def regular; end
    def endless = nil
  end

  def self.<=>(other); end
  def self.regularish; end
  def self.endlessish = nil
end

def Explody.>(other); end
def Explody.regularnot; end
def Explody.endlessness = nil

def instance.==(other); end
def instance.regular; end
def instance.endless = nil

def youcandothistoo::==(other); end
def youcandothistoo::regular; end
def youcandothistoo::endless = nil

# This will actually explode in Ruby, but only because integers are special
class << 42
  def ==(other); end
  def regular; end
  def endless = nil
end

class << "42"
  def ==(other); end
  def regular; end
  def endless = nil
end

class << variable
  def ==(other); end
  def regular; end
  def endless = nil
end

class << Constant
  def ==(other); end
  def regular; end
  def endless = nil
end
