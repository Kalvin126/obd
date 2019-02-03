module OBD
  class Response
    
    def initialize command, response
      @command = command
      @response = response
    end

    def command
      @command
    end

    def raw_response
      @response
    end

    def raw_values
      return nil if @response == 'NO DATA'

      @response
        .split("\r")
        .map { |x| x[4..-1].to_i(16) }
    end

    def value
      return nil if @response == 'NO DATA'

      data = @response[4..-1]
      result_formatter = @command.result_formatter

      if result_formatter.arity > 1
        groups = data.chars
          .each_slice(2)
          .to_a
          .map(&:join)
          .map do |data|
            data.to_i(16)
        end
        arguments = [data, groups.first(result_formatter.arity - 1)]
        arguments = arguments.flatten

        result_formatter.call *arguments
      else
        result_formatter.call data
      end
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
        return_value = current_value.truncate(2).to_s

        if not @command.unit.nil?
          return_value = return_value + @command.unit
        end

        return return_value
      else 
        return current_value.to_s
      end
    end

  end
end
