require           'minitest/autorun'
require_relative  'test_helper.rb'

describe Platformer::Room do
  it 'is created from json data' do
    json_data = $gtk.parse_json_file filename
    r         = Platformer::Room.new json_data['levels'].first
  end

  #it 'will create its exit collision rectangles' do
  #end
end
