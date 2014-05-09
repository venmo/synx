require File.join(File.dirname(__FILE__), '..', 'spec_helper')

require 'pathname'

describe Synxronize::Project do

  let(:dummy_synx_pathname) { Pathname(File.join(File.dirname(__FILE__), '..', 'dummy')) }
  let(:dummy_synx_project_path) { dummy_synx_pathname + 'dummy.xcodeproj' }

  let(:dummy_synx_project) do
    Synxronize::Project.open(dummy_synx_project_path)
  end

  def pathname_should_have_x_entries(pathname, num)
    # Every entries.count expectation is inflated by 2, because of '.' and '..'
    expect(pathname.entries.count).to eq(num + 2)
  end

  def pathname_should_have_files(*files)
    existing_files = pathname.entries.map(&:to_s)
    files.each |file| do
      expect(existing_files.include?(file)).to be(true)
  end5
  describe "#sync" do

    before(:all) { Synxronize::Project.open(dummy_synx_project_path).sync }

    let(:expected_structure) do
      [
        {
        "dummy" => 
          [
          ]
        },
        {
        "dummyTests" =>
          [
          ]
        },
        "dummy.xcodeproj",
        {
        "Products" =>
          []
        }
      ]
    end

    it "should have the correct physical file structure" do
      pathname_should_have_x_entries(dummy_synx_pathname, 3)
      dummy_dummy = dummy_synx_pathname + 'dummy'
      pathname_should_have_x_entries(dummy_dummy, 5)
      

      dummy_dummyTests = dummy_synx_pathname + 'dummyTests'

      dummy_Products = dummy_synx_pathname + 'Products'
      pathname_should_have_x_entries(dummy_Products, 0)

    end

    it "should not have modified the Xcode group structure" do
    end

    it "should have updated the pch and info.plist build setting paths" do
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

  describe "#pathname_to_work_pathname" do

    it "should return the path in work_root_pathname that is relatively equivalent to root_pathname" do
      pathname = dummy_synx_project.send(:root_pathname) + "some" + "path" + "to" + "thing"

      value = dummy_synx_project.send(:pathname_to_work_pathname, pathname)
      expected = dummy_synx_project.send(:work_root_pathname) + "some" + "path" + "to" + "thing"

      expect(value).to eq(expected)
    end
  end
end