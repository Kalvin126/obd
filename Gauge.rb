require_relative 'Command'

class Gauge
    
  def initialize(name, commands_syms, result_formatter)
    if name.nil?
      @name = OBD.method(commands_syms[0]).call.name
    else
      @name = name
    end
    @commands_syms = commands_syms

    # result_formatter (Hash<Command, Response>) -> String
    if result_formatter.nil?
      @result_formatter = lambda { |command_results| 
        result = command_results[@commands_syms[0]].display_value
        return result
      } 
    else
      @result_formatter = result_formatter
    end
  end

  def get_name
    @name
  end

  def get_commands
    @commands_syms
  end

  def display_value(command_results) # Hash<Command, Response>
    if @commands_syms.count == 0
      return 'no commands_syms'
    else
      return @result_formatter[command_results]
    end
  end

  # Gauges

  def self.gauge_for_command(command_sym)
    Gauge.new(nil, commands_syms = [command_sym], nil)
  end

  def self.mpg
    Gauge.new("MPG",
      [:fuel_system_status, :intake_manifold_absolute_pressure, :vehicle_speed, :fuel_air_commanded_equivalence_ratio],
      lambda { |command_results|
        fuel_system_status = command_results[:fuel_system_status]
        return "9999" if fuel_system_status.value == :open_loop_load_decel
        map = command_results[:intake_manifold_absolute_pressure].value
        speed = command_results[:vehicle_speed].value
        actualAF = command_results[:fuel_air_commanded_equivalence_ratio].value

        instant_mpg = 0.483492*(actualAF * speed / map)

        return "0.0" if instant_mpg.nan?
        return instant_mpg
      }
    )
  end

  def self.turbo_boost
    Gauge.new("Turbo Boost",
      [:intake_manifold_absolute_pressure, :absolute_barometric_pressure],
      lambda { |command_results|
        map = command_results[:intake_manifold_absolute_pressure]
        barometric_pressure =  command_results[:absolute_barometric_pressure]
        result = map.value - barometric_pressure.value
        return result.truncate(2).to_s + ' psi'
      }
    )
  end

  def self.fuel_air_ratio
    Gauge.new("Fuel Air Ratio",
      [:fuel_air_commanded_equivalence_ratio],
      lambda { |command_results|
        command_afr = command_results[:fuel_air_commanded_equivalence_ratio]
        result = 14.64 * command_afr.value

        return result.truncate(3).to_s
      }
    )
  end

end
