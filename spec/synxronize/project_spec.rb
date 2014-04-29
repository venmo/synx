require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Synxronize::Project do

  let(:dummy_synx_project) do
    path = File.join(File.dirname(__FILE__), '..', 'dummy', 'dummy.xcodeproj')
    Synxronize::Project.open(path)
  end

  describe "#sync" do
  end

  describe "#sync_group" do
  end

  describe "#sync_file" do
    it "" do
      dummy_synx_project.sync
    end
  end

  describe "#root_pathname" do

    it "should return the pathname to the directory that the .pbxproj file is inside" do
      expected = Pathname(File.join(File.dirname(__FILE__), '..', 'dummy'))
      dummy_synx_project.send(:root_pathname).realpath.should eq(expected.realpath)
    end
  end

  describe "#work_root_pathname" do

    it "should return the pathname to the directory synxchronize will do its work in" do
      expected = Pathname(Synxronize::Project.const_get(:SYNXRONIZE_DIR)) + "dummy"
      dummy_synx_project.send(:work_root_pathname).realpath.should eq(expected.realpath)
    end

    it "should start fresh by removing any existing directory at work_root_pathname" do
      Pathname.any_instance.stub(:exist?).and_return(true)
      expect(FileUtils).to receive(:rm_rf)

      dummy_synx_project.send(:work_root_pathname)
    end

    it "should create a directory at work_root_pathname" do
      expect_any_instance_of(Pathname).to receive(:mkpath)
      dummy_synx_project.send(:work_root_pathname)
    end

    it "should be an idempotent operation but return the same value through memoization" do
      pathname = dummy_synx_project.send(:work_root_pathname)
      expect(FileUtils).to_not receive(:rm_rf)
      expect_any_instance_of(Pathname).to_not receive(:exist?)
      expect_any_instance_of(Pathname).to_not receive(:mkpath)
      expect(dummy_synx_project.send(:work_root_pathname)).to be(pathname)
    end
  end

  describe "#dir_name_for_group" do

    let(:group_mock) { double(Xcodeproj::Project::Object::PBXGroup) }
    it "should return the name if there is one" do
        name_mock = double(String)
        group_mock.stub(:name).and_return(name_mock)

        expect(dummy_synx_project.send(:dir_name_for_group, group_mock)).to be(name_mock)
    end

    it "should return the path if there is no name" do
        path_mock = double(String)
        group_mock.stub(:name).and_return(nil)
        group_mock.stub(:path).and_return(path_mock)

        expect(dummy_synx_project.send(:dir_name_for_group, group_mock)).to be(path_mock)
    end
  end

  describe "#pathname_to_work_pathname" do

    it "should return the path in work_root_pathname that is relatively equivalent to root_pathname" do
      pathname = dummy_synx_project.send(:root_pathname) + "some" + "path" + "to" + "thing"

      value = dummy_synx_project.send(:pathname_to_work_pathname, pathname)
      expected = dummy_synx_project.send(:work_root_pathname) + "some" + "path" + "to" + "thing"

      expect(value).to eq(expected)
    end
  end
end