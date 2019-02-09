require 'json'
require 'pry'

require_relative '../Response'

class MockConnection

=begin
@data
[[command: Response]]

=end

  def initialize
    @frame = 0
    @data = []
  end

  def connect
    load_data
  end

  def [] command
    return OBD::Response.new command, @data[@frame][command.command]
  end

  def increment_frame_data
    @frame += 1

    @frame = 0 if @data.count < @frame + 1
  end

  # Loading Data

  private

  def load_data
    mock_data_path = './obd/Mock/Data'
    files = Dir.entries(mock_data_path)
      .sort

    files.each { |file_name|
      if file_name.include? 'frame_'
        data = File.read mock_data_path + '/'+ file_name

        @data.push JSON.parse(data)
      end
    }
  end

end
