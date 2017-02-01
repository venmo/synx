require 'spec_helper'
require 'fileutils'
require 'pathname'

describe Synx::FileManager do

  let (:file_manager) do
    Synx::FileManager.new
  end

  describe "rm_rf" do
    before(:each) { FileUtils.stub(:rm_rf) }

    it "should delete file at given path" do
      file_manager.rm_rf('/the_path')

      expect(FileUtils).to have_received(:rm_rf).with('/the_path')
    end

    it "should not delete file if warn flag is set" do
      file_manager.options[:warn] = 'warning'
      file_manager.rm_rf('/the_path')

      expect(FileUtils).to_not have_received(:rm_rf)
    end
  end

  describe "mv" do
    before(:each) { FileUtils.stub('mv') }

    it "should move file from source to destination" do
      file_manager.mv('/src', '/dest')

      expect(FileUtils).to have_received(:mv).with('/src', '/dest')
    end

    it "should not move files if warn flag is set" do
      file_manager.options[:warn] = 'error'
      file_manager.mv('/src', '/dest')

      expect(FileUtils).to_not have_received(:mv)
    end
  end

end
