require 'rspec'
require 'yaml'
require File.join(Dir.pwd, 'metro_infopoint')
path_to_file = File.join(Dir.pwd, 'config', "timing#{ENV['VARIANT']}.yml")
timing_data = YAML.load_file(path_to_file)['timing']


FROM_TO_PAIRS = [
  { from_station:'shevchenkivska',
    to_station: 'kiborgiv',
    calculated_time:
		  timing_data.find { |e| e['start'].to_s == 'shevchenkivska' && e['end'].to_s == 'banderivska' }['time'] +
		    timing_data.find { |e| e['start'].to_s == 'banderivska' && e['end'].to_s == 'sheptyckogo' }['time'] +
		      timing_data.find { |e| e['start'].to_s == 'sheptyckogo' && e['end'].to_s == 'kiborgiv' }['time'],
    calculated_price:
      timing_data.find { |e| e['start'].to_s == 'shevchenkivska' && e['end'].to_s == 'banderivska' }['price'] +
        timing_data.find { |e| e['start'].to_s == 'banderivska' && e['end'].to_s == 'sheptyckogo' }['price'] +
          timing_data.find { |e| e['start'].to_s == 'sheptyckogo' && e['end'].to_s == 'kiborgiv' }['price'] },
  { from_station:'lemberska',
    to_station: 'nezalezhna',
    calculated_time:
      timing_data.find { |e| e['start'].to_s == 'halytska' && e['end'].to_s == 'lemberska' }['time'] +
        timing_data.find { |e| e['start'].to_s == 'sheptyckogo' && e['end'].to_s == 'halytska' }['time'] +
          timing_data.find { |e| e['start'].to_s == 'banderivska' && e['end'].to_s == 'sheptyckogo' }['time'] +
            timing_data.find { |e| e['start'].to_s == 'nezalezhna' && e['end'].to_s == 'banderivska' }['time'],
    calculated_price:
      timing_data.find { |e| e['start'].to_s == 'halytska' && e['end'].to_s == 'lemberska' }['price'] +
        timing_data.find { |e| e['start'].to_s == 'sheptyckogo' && e['end'].to_s == 'halytska' }['price'] +
          timing_data.find { |e| e['start'].to_s == 'banderivska' && e['end'].to_s == 'sheptyckogo' }['price'] +
            timing_data.find { |e| e['start'].to_s == 'nezalezhna' && e['end'].to_s == 'banderivska' }['price'] },
  { from_station:'konotopska',
    to_station: 'banderivska',
    calculated_time:
      timing_data.find { |e| e['start'].to_s == 'konotopska' && e['end'].to_s == 'shevchenkivska' }['time'] +
        timing_data.find { |e| e['start'].to_s == 'shevchenkivska' && e['end'].to_s == 'banderivska' }['time'],
    calculated_price:
      timing_data.find { |e| e['start'].to_s == 'konotopska' && e['end'].to_s == 'shevchenkivska' }['price'] +
        timing_data.find { |e| e['start'].to_s == 'shevchenkivska' && e['end'].to_s == 'banderivska' }['price'] }
]


class MetroInfopointDouble
  def initialize(path_to_timing_file:, path_to_lines_file:)
    # initialization here
  end

  def calculate(from_station:, to_station:)
    { price: calculate_price(from_station: from_station, to_station: to_station),
      time: calculate_time(from_station: from_station, to_station: to_station) }
  end

  def calculate_price(from_station:, to_station:)
    FROM_TO_PAIRS.find { |e| e[:from_station] == from_station && e[:to_station] == to_station }[:calculated_price]
  end

  def calculate_time(from_station:, to_station:)
    FROM_TO_PAIRS.find { |e| e[:from_station] == from_station && e[:to_station] == to_station }[:calculated_time]
  end
end



RSpec.describe MetroInfopoint do
  let(:object) { MetroInfopoint.new(path_to_timing_file: '', path_to_lines_file: '') }

  describe 'valid class' do
    it { expect(MetroInfopoint).to respond_to(:new) }
    it { expect(object).to respond_to(:calculate_time, :calculate_price, :calculate) }
  end

  describe '#calculate_price' do
    FROM_TO_PAIRS.each do |e|
      it { expect(object.calculate_price(from_station: e[:from_station], to_station: e[:to_station])).to eq(e[:calculated_price]) }
    end
  end

  describe '#calculate_time' do
    FROM_TO_PAIRS.each do |e|
      it { expect(object.calculate_time(from_station: e[:from_station], to_station: e[:to_station])).to eq(e[:calculated_time]) }
    end
  end

  describe '#calculate' do
    FROM_TO_PAIRS.each do |e|
      result = { price: e[:calculated_price], time: e[:calculated_time] }
      it { expect(object.calculate(from_station: e[:from_station], to_station: e[:to_station])).to eq(result) }
    end
  end
end
