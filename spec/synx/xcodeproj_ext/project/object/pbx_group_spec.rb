require 'spec_helper'

describe Xcodeproj::Project::Object::PBXGroup do

  describe "groups_containing_forward_slash" do

    before(:all) do
      DUMMY_SYNX_TEST_PROJECT.send(:set_options, {})
    end

    after(:all) do
      DUMMY_SYNX_TEST_PROJECT["top group"].remove_from_project
    end

    it "should return all child and grandchild groups containing forward slash" do

      top_group = DUMMY_SYNX_TEST_PROJECT.main_group.new_group("top group")

      child_1 = top_group.new_group("have / slash")
      child_1_1 = child_1.new_group("1 no slash")
      child_1_2 = child_1.new_group("1 / slash")

      child_2 = top_group.new_group("no slash")
      child_2_1 = child_2.new_group("2 no slash")
      child_2_2 = child_2.new_group("2 / slash")

      expect(top_group.groups_containing_forward_slash).to eq([child_1, child_1_2, child_2_2])
    end
  end

  describe "pretty_hierarchy_path" do
    it "should return / in case hierarchy path is empty (top level)" do
      main_group = DUMMY_SYNX_TEST_PROJECT.main_group

      expect(main_group.pretty_hierarchy_path).to eq('/')
    end

    it "should return hierarchy path if it is not empty" do
      dummy_group = DUMMY_SYNX_TEST_PROJECT.main_group.children.select { |g| g.basename == 'dummy' }.first

      expect(dummy_group.pretty_hierarchy_path).to eq('/dummy')
    end
  end
end
