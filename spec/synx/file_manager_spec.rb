require 'spec_helper'
require 'fileutils'
require 'pathname'

describe Synx::FileManager do

  before(:each) do
    Synx::FileManager.reset
  end

  describe "::rm_rf" do
    before(:each) { FileUtils.stub(:rm_rf) }

    it "should delete file at given path" do
      Synx::FileManager.rm_rf('/the_path')

      expect(FileUtils).to have_received(:rm_rf).with('/the_path')
    end

    it "should not delete file if warn flag is set" do
      Synx::FileManager.options[:warn] = 'warning'
      Synx::FileManager.rm_rf('/the_path')

      expect(FileUtils).to_not have_received(:rm_rf)
    end
  end

  describe "::mv" do
    before(:each) { FileUtils.stub('mv') }

    it "should move file from source to destination" do
      Synx::FileManager.mv('/src', '/dest')

      expect(FileUtils).to have_received(:mv).with('/src', '/dest')
    end

    it "should not move files if warn flag is set" do
      Synx::FileManager.options[:warn] = 'error'
      Synx::FileManager.mv('/src', '/dest')

      expect(FileUtils).to_not have_received(:mv)
    end
  end

end
