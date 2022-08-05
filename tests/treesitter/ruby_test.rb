module Mod
  class Cl_1
    def meth_1() end
  end

  def meth_2() end
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
