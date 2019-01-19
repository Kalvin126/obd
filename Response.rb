module OBD
  class Response
    
    def initialize command, response
      @command = command
      @response = response
    end

    def raw_values
      return nil if @response == 'NO DATA'

      @response
        .split("\r")
        .map { |x| x[4..-1].to_i(16) }
    end

    def value
      return nil if @response == 'NO DATA'

      date = @response[4..-1]
      groups = date.chars.each_slice(2).to_a.map(&:join)
      A = groups[0]
      B = groups[1]
      C = groups[2]
      D = groups[3]

      @command.result_formatter
        .call @response, A, B, C, D
    end

    def display_value
      return @response if @response == 'NO DATA'

      current_value = value

      if @command.service == 1 and @command.pid == 3
        case current_value
        when :inactive
          return 'Inactive'
        when :open_loop_insufficient_engine_temp
          return 'Open, Not warm'
        when :closed_loop
          return 'Closed'
        when :open_loop_load_decel
          return 'Open, DFCO/Load'
        when :open_loop_failure
          return 'Open, Failure'
        when :closed_loop_fault
          return 'Closed, Failure'
          end
      end

      if current_value.is_a?(Float)
        puts @command.pid
        return current_value.truncate(2).to_s + @command.unit
      else 
        return current_value.to_s
      end
    end

  end
end
