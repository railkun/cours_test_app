require 'yaml'

    class Metroinfopoint
      attr_accessor  :station, :time

            def initialize(path_to_timing_file: "", path_to_lines_file: "")
    @config = YAML.load_file('config/config.yml')
    @time = YAML.load_file('config/timing4.yml')['timing']
    @station = @config['stations']
  end

  def calculate(from_station:, to_station:)
    { price: calculate_price(from_station: from_station, to_station: to_station),
      time: calculate_time(from_station: from_station, to_station: to_station) }
  end

  def calculate_price(from_station:, to_station:)
    calculated('price', from_station, to_station)
  end

  def calculate_time(from_station:, to_station:)
    calculated('time', from_station, to_station)
  end

  def calculated(travel_attributes, from_station, to_station)
    route = station_route(from_station, to_station)
    stations = route.count
    total = 0
    a = 0

    while a+1 < stations
      config = time.select { |e| e['start'].to_s == route[a] && e['end'].to_s == route[a+1] }[0]
      a = a + 1
      total = total +  info[data]
    end

    total
  end

  def station_route(from_station, to_station)
    reserve_station = ''
    middle_station = ''

    first_station = station.find { |e| e if e[0] == to_station || e[0] == from_station }[0]

    if first_station == from_station
      last_station = to_station
    else
      last_station = from_station
    end

    from_line = station[first_station][0]
    to_line = station[last_station][0]

    result = 0
    mass = []

    while first_station != last_station do
      if mass.include? (first_station)
        mass.slice!(-1) while mass.last != middle_station
        first_station = reserve_station
      end

      mass.push(first_station)

      if (from_line != to_line) && (station[first_station].count > 1)
        config = time.select { |e| e['start'].to_s == first_station }
        from_line = station[first_station][1]
        middle_station = first_station
        config.find { |e| first_station = e['end'].to_s if station[e['end'].to_s] == [from_line] }
        config.select { |e| reserve_station = e['end'].to_s if station[e['end'].to_s] == [from_line] }
      else
        config = time.find { |e| e['start'].to_s == first_station }
        first_station = config['end'].to_s
      end
    end

    mass.push(last_station)
  end
end
