require 'bundler/setup'
Bundler.setup

require 'synx'
require 'pry'

DUMMY_SYNX_PATH = File.join(File.dirname(__FILE__), 'dummy')
DUMMY_SYNX_TEST_PATH = File.join(File.dirname(__FILE__), 'test_dummy')
DUMMY_SYNX_TEST_PROJECT_PATH = File.join(DUMMY_SYNX_TEST_PATH, 'dummy.xcodeproj')
FileUtils.rm_rf(DUMMY_SYNX_TEST_PATH)
FileUtils.cp_r(DUMMY_SYNX_PATH, DUMMY_SYNX_TEST_PATH)
DUMMY_SYNX_TEST_PROJECT = Synx::Project.open(DUMMY_SYNX_TEST_PROJECT_PATH)

RSpec.configure do |config|
end
