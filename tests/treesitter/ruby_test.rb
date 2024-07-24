module Mod
  class Cl_1
    def meth_1() end
  end

  call_some_function

  def self.meth_2
  end

  def meth_3
  end

  def name=(value) end

  def ==(other) end

  def oneline = "woo"
end

describe 'UnitTest' do
  before :all do
  end
  after do
  end
  it 'should describe the test' do
  end
end

namespace "rake_namespace" do
  task :simple_task do || end
  task 'inline_task' => %w[prereq1 prereq2]
  task rake_task: [:prereq] do || end
  multitask parallel_prereqs: %w[task1 task2 task3] do end
  file "create_file" do || end
end


module Long::Mod::Name
  class Long::Class::Name
  end
end

context "Shoulda Context" do
  setup do
  end
  teardown do
  end
  should "test something" do
  end
  should_eventually "actually work" do
  end
  should_not validate_presence_of(:title)
end

class Privateers
  private def inline_private
  end

  def public_1
  end

  private
  def private_1
  end

  acts_as_state_machine

  protected
  def protected_1
  end

  attr_reader :test

  class DoNotBreakScope
  end

  # Some comment
  def protected_2
  end

  public def inline_public
  end

  def protected_3
  end

  public
  def public_2
  end

  def public_setter=(val)
  end

  private
  def private_setter=(val)
  end
end
