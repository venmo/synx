require 'bundler/setup'
require 'synx'
require 'pry'

DUMMY_SYNX_PATH = File.expand_path('../dummy', __FILE__)
DUMMY_SYNX_TEST_PATH = File.expand_path('../test_dummy', __FILE__)
DUMMY_SYNX_TEST_PROJECT_PATH = File.join(DUMMY_SYNX_TEST_PATH, 'dummy.xcodeproj')
FileUtils.rm_rf(DUMMY_SYNX_TEST_PATH)
FileUtils.cp_r(DUMMY_SYNX_PATH, DUMMY_SYNX_TEST_PATH)
DUMMY_SYNX_TEST_PROJECT = Synx::Project.open(DUMMY_SYNX_TEST_PROJECT_PATH)

RSpec.configure do |config|
end
