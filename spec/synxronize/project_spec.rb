require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Synxronize::Project do

  let(:dummySynxProject) do
    path = File.join(File.dirname(__FILE__), '..', 'dummy', 'dummy.xcodeproj')
    Synxronize::Project.open(path)
  end

  describe "#sync" do
  end

  describe "#sync_group" do
  end

  describe "#sync_file" do
  end

  describe "#root_pathname" do
    it "should return the pathname to the directory that the .pbxproj file is inside" do
      expected = Pathname(File.join(File.dirname(__FILE__), '..', 'dummy'))
      dummySynxProject.send(:root_pathname).realpath.should eq(expected.realpath)
    end
  end

  describe "#work_root_pathname" do

    it "should return the pathname to the directory synxchronize will do its work in" do
      expected = Pathname(Synxronize::Project.const_get(:SYNXRONIZE_DIR)) + "dummy"
      dummySynxProject.send(:work_root_pathname).realpath.should eq(expected.realpath)
    end

    it "should start fresh by removing any existing directory at work_root_pathname" do
      Pathname.any_instance.stub(:exist?).and_return(true)
      expect(FileUtils).to receive(:rm_rf)

      dummySynxProject.send(:work_root_pathname)
    end

    it "should create a directory at work_root_pathname" do
      expect_any_instance_of(Pathname).to receive(:mkpath)
      dummySynxProject.send(:work_root_pathname)
    end

    it "should be an idempotent operation but return the same value through memoization" do
      pathname = dummySynxProject.send(:work_root_pathname)
      expect(FileUtils).to_not receive(:rm_rf)
      expect_any_instance_of(Pathname).to_not receive(:exist?)
      expect_any_instance_of(Pathname).to_not receive(:mkpath)
      expect(dummySynxProject.send(:work_root_pathname)).to be(pathname)
    end

  end
end