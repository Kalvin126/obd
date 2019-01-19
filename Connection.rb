require 'rubyserial'

require_relative "Command"

module OBD

  class Connection

    def initialize(port, baud=115200)
      @port = port
      @baud = baud
    end 

    def connect
      puts "Connecting to #{@port} @ #{@baud}"

      @serial = Serial.new @port, @baud

      setup_config
    end

    def close
      @serial.close
    end

    def send(data)
      write data

      read
    end

    def [] command
      response = send command.command

      return Response.new command, response
    end
    
    private

    def setup_config
      write 'AT D'
      read
      write 'ATZ'   # Reset
      read "\r\r\r" # ATZ
      read          # ELM327 v1.3a

      write 'AT E0' # turn echo off
      read "\r"     # AT E0
      read          # OK

      send 'AT L0'    # turn linefeeds off
      send 'AT S0'    # turn spaces off
      send 'AT AT2'   # respond to commands faster
      send 'AT SP 00' # automatically select protocol
    end

    def read(seperator="\r\r>")
      resp = @serial.gets(seperator).chomp(seperator)

      puts "Received #{resp.dump}"

      return resp.gsub("SEARCHING...\r", "")
    end

    def write data
      hex_data = data.to_s + "\r"

      puts "Writing #{hex_data.dump}" 

      @serial.write hex_data
    end

  end

end
