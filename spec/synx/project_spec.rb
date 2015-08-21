require 'spec_helper'
require 'fileutils'
require 'pathname'
require 'yaml'

class Hash
  # Return a hash that includes everything but the given keys. This is useful for
  # limiting a set of parameters to everything but a few known toggles:
  #
  #   @person.update_attributes(params[:person].except(:admin))
  #
  # If the receiver responds to +convert_key+, the method is called on each of the
  # arguments. This allows +except+ to play nice with hashes with indifferent access
  # for instance:
  #
  #   {:a => 1}.with_indifferent_access.except(:a)  # => {}
  #   {:a => 1}.with_indifferent_access.except("a") # => {}
  #
  def except(*keys)
    dup.except!(*keys)
  end

  # Replaces the hash without the given keys.
  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end
end

describe Synx::Project do

  describe "#sync" do

    def verify_group_structure(group, expected_structure)
      expected_structure.each_with_index do |(object_name, object_children), index|
        failure_message = "expected group `#{group.basename}` to have child `#{object_name}`"
        object = group.children[index]
        expect(object.basename).to eq(object_name)
        expect(group).to_not be_nil, failure_message
        next if ["Products", "Frameworks"].include?(object.display_name)

        if object.instance_of?(Xcodeproj::Project::Object::PBXGroup)
          object_children ||= {}
          found_children = object.children.map(&:basename)
          missing_children_in_group = object_children.keys - found_children
          extra_children_in_group = found_children - object_children.keys
          failure_message = "In group #{object.hierarchy_path}:"

          unless missing_children_in_group.empty?
            failure_message += "\n  Expected to find children: #{missing_children_in_group.join(", ")}"
          end

          unless extra_children_in_group.empty?
            failure_message += "\n  Did not expect to find children: #{extra_children_in_group.join(", ")}"
          end
          failure_message = "Expected #{object_name} to have #{object_children.count} children, found #{object.children.count}"
          expect(object_children.count).to eq(object.children.count), failure_message
          verify_group_structure(object, object_children) if object_children.count > 0
        end
      end
    end

    def verify_file_structure(dir_pathname, expected_structure)
      expected_structure.each do |entry_name, entry_entries|
        entry_pathname = dir_pathname + entry_name
        expect(File.exist?(entry_pathname) || Dir.exists?(entry_pathname)).to be(true), "Expected #{entry_pathname} to exist"

        if File.directory?(entry_pathname)
          entry_entries ||= {}
          found_entries = entry_pathname.entries.reject { |e| [".", ".."].include?(e.to_s) }.map(&:to_s)
          missing_entries_on_file_system = entry_entries.keys - found_entries
          extra_entries_on_file_system = found_entries - entry_entries.keys
          failure_message = "In #{entry_pathname}:"

          unless missing_entries_on_file_system.empty?
            failure_message += "\n  Expected to find entries: #{missing_entries_on_file_system.join(", ")}"
          end

          unless extra_entries_on_file_system.empty?
            failure_message += "\n  Did not expect to find entries: #{extra_entries_on_file_system.join(", ")}"
          end

          expect(missing_entries_on_file_system.count + extra_entries_on_file_system.count).to be(0), failure_message
          verify_file_structure(entry_pathname, entry_entries) if entry_entries.count > 0
        end
      end
    end

    def expected_file_structure
      YAML::load_file(File.expand_path("../expected_file_structure.yml", __FILE__))
    end

    def expected_group_structure
      YAML::load_file(File.expand_path("../expected_group_structure.yml", __FILE__))
    end

    describe "with no additional options" do

      before(:all) do
        DUMMY_SYNX_TEST_PROJECT.sync(:output => StringIO.new)
      end

      it "should have the correct physical file structure" do
        verify_file_structure(Pathname(DUMMY_SYNX_TEST_PROJECT_PATH).parent, expected_file_structure)
      end

      it "should not have modified the Xcode group structure, except for fixing double file references" do
        verify_group_structure(DUMMY_SYNX_TEST_PROJECT.main_group, expected_group_structure)
      end

      it "should have updated the pch and info.plist build setting paths" do
        # dummy target
        DUMMY_SYNX_TEST_PROJECT.targets.first.each_build_settings do |bs|
          expect(bs["GCC_PREFIX_HEADER"]).to eq("dummy/Supporting Files/dummy-Prefix.pch")
          expect(bs["INFOPLIST_FILE"]).to be_nil
        end

        # dummyTests target
        DUMMY_SYNX_TEST_PROJECT.targets[1].each_build_settings do |bs|
          expect(bs["GCC_PREFIX_HEADER"]).to eq("dummyTests/Supporting Files/dummyTests-Prefix.pch")
          expect(bs["INFOPLIST_FILE"]).to eq("dummyTests/Supporting Files/dummyTests-Info.plist")
        end
      end
    end

    describe "with the prune option toggled" do

      before(:all) do
        DUMMY_SYNX_TEST_PROJECT.sync(:prune => true, :output => StringIO.new)
      end

      it "should remove unreferenced images and source files if the prune option is toggled" do
        expected_file_structure_with_removals = expected_file_structure
        expected_file_structure_with_removals["dummy"].except!("image-not-in-xcodeproj.png")
        expected_file_structure_with_removals["dummy"].except!("FileNotInXcodeProj.h")
        expected_file_structure_with_removals["dummy"]["AlreadySynced"].except!("FolderNotInXcodeProj")
        verify_file_structure(Pathname(DUMMY_SYNX_TEST_PROJECT_PATH).parent, expected_file_structure_with_removals)
      end

      it "should not have modified the Xcode group structure, except for fixing double file references" do
        verify_group_structure(DUMMY_SYNX_TEST_PROJECT.main_group, expected_group_structure)
      end
    end

    describe "with the no_default_exclusions option toggled" do

      before(:all) do
        DUMMY_SYNX_TEST_PROJECT.sync(:no_default_exclusions => true, :output => StringIO.new)
      end

      it "should have an empty array for default exclusions" do
        expect(DUMMY_SYNX_TEST_PROJECT.group_exclusions.count).to eq(0)
      end
    end

    describe "with group_exclusions provided as options" do

      before(:all) do
        DUMMY_SYNX_TEST_PROJECT.sync(:group_exclusions => %W(/dummy /dummy/SuchGroup/VeryChildGroup), :output => StringIO.new)
      end

      it "should add the group exclusions to the array" do
        expect(DUMMY_SYNX_TEST_PROJECT.group_exclusions.sort).to eq(%W(/Libraries /Products /Frameworks /Pods /dummy /dummy/SuchGroup/VeryChildGroup).sort)
      end
    end

  end

  describe "group_exclusions=" do

    it "should raise an IndexError if any of the groups do not exist" do
      expect { DUMMY_SYNX_TEST_PROJECT.group_exclusions = %W(/dummy /dummy/DoesntExist) }.to raise_error(IndexError)
    end

    it "should be fine if the groups all exist" do
      group_exclusions = %W(/dummy /dummy/GroupThatDoubleReferencesFile /dummy/SuchGroup/VeryChildGroup)
      DUMMY_SYNX_TEST_PROJECT.group_exclusions = group_exclusions

      expect(DUMMY_SYNX_TEST_PROJECT.group_exclusions).to eq(group_exclusions)
    end

    it "should be forgiving about missing '/' at beginning of group paths" do
      group_exclusions = %W(dummy dummy/GroupThatDoubleReferencesFile dummy/SuchGroup/VeryChildGroup)
      DUMMY_SYNX_TEST_PROJECT.group_exclusions = group_exclusions

      expected = %W(/dummy /dummy/GroupThatDoubleReferencesFile /dummy/SuchGroup/VeryChildGroup)
      expect(DUMMY_SYNX_TEST_PROJECT.group_exclusions).to eq(expected)
    end
  end

  describe "#root_pathname" do

    it "should return the pathname to the directory that the .pbxproj file is inside" do
      expected = Pathname(File.join(File.dirname(__FILE__), '..', 'test_dummy'))
      DUMMY_SYNX_TEST_PROJECT.send(:root_pathname).realpath.should eq(expected.realpath)
    end
  end

  describe "#work_root_pathname" do

    before(:each) { DUMMY_SYNX_TEST_PROJECT.instance_variable_set("@work_root_pathname", nil) }

    it "should return the pathname to the directory synxchronize will do its work in" do
      expected = Pathname(Synx::Project.const_get(:SYNXRONIZE_DIR)) + "test_dummy"
      DUMMY_SYNX_TEST_PROJECT.send(:work_root_pathname).realpath.should eq(expected.realpath)
    end

    it "should start fresh by removing any existing directory at work_root_pathname" do
      Pathname.any_instance.stub(:exist?).and_return(true)
      expect(FileUtils).to receive(:rm_rf)

      DUMMY_SYNX_TEST_PROJECT.send(:work_root_pathname)
    end

    it "should create a directory at work_root_pathname" do
      expect_any_instance_of(Pathname).to receive(:mkpath)
      DUMMY_SYNX_TEST_PROJECT.send(:work_root_pathname)
    end

    it "should be an idempotent operation but return the same value through memoization" do
      pathname = DUMMY_SYNX_TEST_PROJECT.send(:work_root_pathname)
      expect(FileUtils).to_not receive(:rm_rf)
      expect_any_instance_of(Pathname).to_not receive(:exist?)
      expect_any_instance_of(Pathname).to_not receive(:mkpath)
      expect(DUMMY_SYNX_TEST_PROJECT.send(:work_root_pathname)).to be(pathname)
    end
  end

  describe "#pathname_to_work_pathname" do

    it "should return the path in work_root_pathname that is relatively equivalent to root_pathname" do
      pathname = DUMMY_SYNX_TEST_PROJECT.send(:root_pathname) + "some" + "path" + "to" + "thing"

      value = DUMMY_SYNX_TEST_PROJECT.send(:pathname_to_work_pathname, pathname)
      expected = DUMMY_SYNX_TEST_PROJECT.send(:work_root_pathname) + "some" + "path" + "to" + "thing"

      expect(value).to eq(expected)
    end
  end
end
