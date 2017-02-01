require 'spec_helper'
require 'fileutils'
require 'pathname'

describe Synx::IssueRegistry do

  let(:output) { StringIO.new }
  let(:registry) {
    registry = Synx::IssueRegistry.new
    registry.output = output
    registry
  }

  it "should return empty output if there are no issues" do
    registry.print(:warning)

    expect(output.string).to eq('')
  end

  it "should sort issues alphabetically" do
    registry.add_issue('The issue', Pathname('the_issue'))
    registry.add_issue('An issue', Pathname('an_issue'))

    expect(registry.issues.first).to eq('An issue')
    expect(registry.issues.last).to eq('The issue')
  end

  it "should be able to filter issues by basename" do
    registry.add_issue('Issue in the 1st directory', Pathname('the_directory_file.jpg'))
    registry.add_issue('Issue in the 2nd directory', Pathname('dir_file.txt'))
    registry.add_issue('Issue in the 3rd directory', Pathname('a_directory_file.png'))

    issues = registry.issues_for_basename Pathname('directory')

    expect(issues).to match_array(['Issue in the 1st directory', 'Issue in the 3rd directory'])
  end

  it "should print warnings correctly" do
    registry.add_issue('The issue', Pathname('first_path'))
    registry.add_issue('The other issue', Pathname('second_path'))
    registry.print(:warning)

    expect(output.string).to eq("warning: The issue\n" +
                                "warning: The other issue\n")
  end

  it "should print errors correctly" do
    registry.add_issue('Duplicate file', Pathname('duplicate_file'))
    registry.add_issue('Missing file', Pathname('missing_file'))
    registry.print(:error)

    expect(output.string).to eq("error: Duplicate file\n" +
                                "error: Missing file\n")
  end

  it "should override unused issue with not synchronized issue" do
    registry.add_issue('To be discarded', Pathname('file_basename.txt'), :unused)
    registry.add_issue('Overwriting issue', Pathname('file_basename.txt'), :not_synchronized)

    issues = registry.issues_for_basename Pathname('file_basename.txt')

    expect(issues).to match_array(['Overwriting issue'])
  end

  it "should not override not synchronized issue with unused issue" do
    registry.add_issue('Not synchronized', Pathname('file_basename.png'), :not_synchronized)
    registry.add_issue('Unused', Pathname('file_basename.png'), :unused)

    issues = registry.issues_for_basename Pathname('file_basename.png')

    expect(issues).to match_array(['Not synchronized'])
  end

  it "should return correct issue count" do
    registry.add_issue('First', Pathname('file_basename.m'), :not_synchronized)
    registry.add_issue('Second', Pathname('file_basename2.h'), :not_synchronized)
    registry.add_issue('Third', Pathname('file_basename3.swift'), :not_synchronized)

    expect(registry.issues_count).to eq(3)
  end

end
