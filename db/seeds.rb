# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


data = []


file = File.read('testdb.json')

data_hash = JSON.parse(file)

data_hash.each do |sign|
  @parser = ScheduleParser.new
  string_to_parse = sign["signdescription"]
  rule_hash = @parser.call(string_to_parse)
  primary_hash = {
    boroughcode: sign["boroughcode"],
    statusordernumber: sign["statusordernumber"],
    signsequence: sign["signsequence"],
    distance: sign["distance"],
    arrowpoints: sign["arrowpoints"],
    longitude: sign["longitude"],
    latitude: sign["latitude"],
    signdescription: sign["signdescription"],
    sunday: rule_hash[:SUNDAY],
    monday: rule_hash[:MONDAY],
    tuesday: rule_hash[:TUESDAY],
    wednesday: rule_hash[:WEDNESDAY],
    thursday: rule_hash[:THURSDAY],
    friday: rule_hash[:FRIDAY],
    saturday: rule_hash[:SATURDAY]
  }
  data << primary_hash
end

Parkingspot.create(data)

