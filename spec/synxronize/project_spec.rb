require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Synxronize::Project do

  describe "#initialize" do
    it "should set @xcodeproj as a Xcodeproj::Project for the path" do
      mockPath = double(String)
      mockProj = double(Xcodeproj::Project)

      expect(Xcodeproj::Project).to receive(:open).with(mockPath).and_return(mockProj)

      project = Synxronize::Project.new(mockPath)
      project.instance_variable_get("@xcodeproj").should be(mockProj)
    end
  end

  describe "::open" do
    it "should initialize and return a new Synxronize::Project with the given path" do
      mockPath = double(String)
      mockProject = double(Synxronize::Project)

      expect(Synxronize::Project).to receive(:new).with(mockPath).and_return(mockProject)

      Synxronize::Project.open(mockPath).should be(mockProject)

    end
  end

  describe "#sync" do
  end

  describe "#sync_group" do
  end

  describe "#sync_file" do
  end

  describe "#temp_root_path" do
  end

  describe "#root_path" do
  end
end