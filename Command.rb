require 'pry'

module OBD

  Command = Struct.new(:name, :service, :pid, :unit, :result_formatter) do
    
    def command
      ("%02X" % service) + ("%02X" % pid)
    end

  end

  ### Command Factory

  def self.pids_supported_1
    Command.new("01 - 20 PIDs supported", 1, 0, nil,
      lambda { |x, a|
        d.map { |x| x.to_s(16) }
        .join('')
        .to_i(16)
        .to_s(2)
        .split('')
        .each_with_index
        .map { |b,i| OBD.methods(false)[i+1] if b == '1' }
        .compact 
       }
    )
  end

  def self.monitor_status_since_clear
    Command.new("Monitor status since clear", 1, 1, nil,
      lambda { |x| x }
    )
  end

  def self.freeze_dtc
    Command.new("Freeze DTC", 1, 2, nil,
      lambda { |x| x }
    )
  end

  def self.fuel_system_status
    Command.new("Fuel system status", 1, 3, nil,
      lambda { |x, a|
        case x[0..1].to_i(16)
        when 0
          :inactive
        when 1
          :open_loop_insufficient_engine_temp
        when 2
          :closed_loop
        when 4
          :open_loop_load_decel
        when 8
          :open_loop_failure
        when 16
          :closed_loop_fault
        end
      }
    )
  end

  def self.calculated_engine_load
    Command.new("Calculated engine load", 1, 4, '%',
      lambda { |x, a| a / 2.55 }
    )
  end

  def self.engine_coolent_temperature
    Command.new("Engine coolent temperature", 1, 5, '*F',
      lambda { |x, a| (a - 40.0) * 1.8 + 32.0 }
    )
  end

  def self.short_term_fuel_trim_bank_1
    Command.new("Short term fuel trim bank 1", 1, 6, '%',
      lambda { |x, a| a * 0.78125 - 100 }
    )
  end

  def self.long_term_fuel_trim_bank_1
    Command.new("Long term fuel trim bank 1", 1, 7, '%' ,
      lambda { |x, a| a * 0.78125 - 100 }
    )
  end

  def self.short_term_fuel_trim_bank_2
    Command.new("Short term fuel trim bank 2", 1, 8, '%',
      lambda { |x, a| a * 0.78125 - 100 }
    )
  end

  def self.long_term_fuel_trim_bank_2
    Command.new("Long term fuel trim bank 2", 1, 9, '%',
      lambda { |x, a| a * 0.78125 - 100 }
    )
  end

  def self.fuel_pressure
    Command.new("Fuel pressure", 1, 10, 'psi',
      lambda { |x, a| a * 3 * 0.145038 }
    )
  end

  def self.intake_manifold_absolute_pressure
    Command.new("Intake MAP", 1, 11, 'psi',
      lambda { |x, a| a  * 0.145038 }
    )
  end

  def self.engine_rpm
    Command.new("Engine RPM", 1, 12, 'rpm',
      lambda { |x, a| ((256 * a) + d[1]) / 4.0 }
    )
  end

  def self.vehicle_speed
    Command.new("Vehicle Speed", 1, 13, 'mph',
      lambda { |x, a| a * 0.62137119 }
    )
  end

  def self.timing_advance
    Command.new("Timing Advance", 1, 14, '*',
      lambda { |x, a| a / 2.0 - 64.0 }
    )
  end

  def self.intake_air_temperature
    Command.new("Intake air temperature", 1, 15, '*F',
      lambda { |x, a| (a - 40.0) * 1.8 + 32.0 }
    )
  end

  def self.maf_air_flow_rate
    Command.new("Mass Air Flow Rate", 1, 16, 'grams/sec',
      lambda { |x, a, b| (256.0 * a + b) / 100.0 }
    )
  end

  def self.throttle_position
    Command.new("Throttle Position", 1, 17, '%',
      lambda { |x, a| a / 2.55 }
    )
  end

  def self.commanded_secondary_air_status
    Command.new("Commanded secondary air status", 1, 18, nil,
      lambda { |x| x },
    )
  end

  def self.oxygen_sensors_present
    Command.new("Oxygen sensors present", 1, 19, nil,
      lambda { |x| x },
    )
  end

  def self.bank_1_sensor_1_oxygen_sensor_voltage
    Command.new("Bank 1 sensor 1 oxygen sensor voltage", 1, 20, nil,
      lambda { |x| x }
    )
  end

  def self.bank_1_sensor_2_oxygen_sensor_voltage
    Command.new("Bank 1 sensor 2 oxygen sensor voltage", 1, 21, nil,
      lambda { |x| x }
    )
  end

  def self.bank_1_sensor_3_oxygen_sensor_voltage
    Command.new("Bank 1 sensor 3 oxygen sensor voltage", 1, 22, nil,
      lambda { |x| x }
    )
  end

  def self.bank_1_sensor_4_oxygen_sensor_voltage
    Command.new("Bank 1 sensor 4 oxygen sensor voltage", 1, 23, nil,
      lambda { |x| x }
    )
  end

  def self.bank_2_sensor_1_oxygen_sensor_voltage
    Command.new("Bank 2 sensor 1 oxygen sensor voltage", 1, 24, nil,
      lambda { |x| x }
    )
  end

  def self.bank_2_sensor_2_oxygen_sensor_voltage
    Command.new("Bank 2 sensor 2 oxygen sensor voltage", 1, 25, nil,
      lambda { |x| x }
    )
  end

  def self.bank_2_sensor_3_oxygen_sensor_voltage
    Command.new("Bank 2 sensor 3 oxygen sensor voltage", 1, 26, nil,
      lambda { |x| x }
    )
  end

  def self.bank_2_sensor_4_oxygen_sensor_voltage
    Command.new("Bank 2 sensor 4 oxygen sensor voltage", 1, 27, nil,
      lambda { |x| x }
    )
  end

  def self.obd_standards_vehicle_conforms_to
    Command.new("Obd_standards_vehicle_conforms_to", 1, 28, nil,
      lambda { |x| x } 
    )
  end

  def self.oxygen_sensors_present_2
    Command.new("Oxygen sensors present 2", 1, 29, nil,
      lambda { |x| x } 
    )
  end

  def self.aux_input_status
    Command.new("Aux input status", 1, 30, "",
      lambda { |x| (x == 1).inspect }
    )
  end

  def self.run_time_since_engine_start
    Command.new("Run time since engine start", 1, 31, "seconds",
      lambda { |x, a, b| 256.0 * a + b } # seconds
    )
  end

  def self.pids_supported_2
    Command.new("pids_supported_2", 1, 32, "",
      lambda { |x, a|
        d.map { |x| x.to_s(16) }
          .join('')
          .to_i(16)
          .to_s(2)
        # .split('')
        # .each_with_index
        # .map { |b,i| OBD.methods(false)[i+33] if b == '1' }
        # .compact
      }
    )
  end

  # def self.distance_traveled_with_mil_on
  #   Command.new("distance_traveled_with_mil_on", 1, 33, "",
  #     lambda { |x, a| d.to_s + 'km'}
  #   )
  # end

  def self.absolute_barometric_pressure
    Command.new("Absolute Barometric Pressure", 1, 51, "psi",
      lambda { |x, a| a * 0.145038 }
    )
  end

  def self.pids_supported_3
    Command.new("pids_supported_2", 1, 64, "",
      lambda { |x, a|
        d.map { |x| x.to_s(16) }
          .join('')
          .to_i(16)
          .to_s(2)
        # .split('')
        # .each_with_index
        # .map { |b,i| OBD.methods(false)[i+65] if b == '1' }
        # .compact
      }
    )
  end

  def self.fuel_air_commanded_equivalence_ratio
    Command.new("Fuel–Air commanded equivalence ratio", 1, 68, nil,
      lambda { |x, a, b|
         (2.0/65536.0)*((256.0*a)+b)
      }
    )
  end

  def self.pids_supported_4
    Command.new("pids_supported_2", 1, 96, "",
      lambda { |x, a|
        d.map { |x| x.to_s(16) }
          .join('')
          .to_i(16)
        .to_s(2)
        # .split('')
        # .each_with_index
        # .map { |b,i| OBD.methods(false)[i+97] if b == '1' }
        # .compact
      }
    )
  end

  def self.pids_supported_5
    Command.new("pids_supported_5", 1, 128, "",
      lambda { |x, a|
        d.map { |x| x.to_s(16) }
          .join('')
          .to_i(16)
          .to_s(2)
          # .split('')
          # .each_with_index
          # .map { |b,i| OBD.methods(false)[i+129] if b == '1' }
          # .compact
      }
    )
  end

  def self.pids_supported_6
    Command.new("pids_supported_2", 1, 160, "",
      lambda { |x, a|
                d.map { |x| x.to_s(16) }
        .join('')
        .to_i(16)
        .to_s(2)
        # .split('')
        # .each_with_index
        # .map { |b,i| OBD.methods(false)[i+161] if b == '1' }
        # .compact
      }
    )
  end

  def self.engine_coolant_temperature_6
    Command.new("Engine coolant temperature", 1, 103, '*F',
      lambda { |x, a|(x.split('\r').first[2..3].to_i(16) - 40.0) * 1.8 + 32.0 }
    )
  end

  def self.pids_supported_7
    Command.new("pids_supported_2", 1, 192, "",
      lambda { |x, a|
        d.map { |x| x.to_s(16) }
          .join('')
          .to_i(16)
          .to_s(2)
        # .split('')
        # .each_with_index
        # .map { |b,i| OBD.methods(false)[i+193] if b == '1' }
        # .compact
      }
    )
  end

# "atrv" => [:battery_voltage, lambda {|x| x.to_s}],

end