require 'geokit'

class Parkingspot < ActiveRecord::Base
  scope :sunday_no_rules, -> { where("sunday IS NULL")}
  scope :sunday_has_rules, -> { where("sunday IS NOT NULL")}

  scope :monday_no_rules, -> {where("monday IS NULL")}
  scope :monday_has_rules, -> {where("monday IS NOT NULL")}

  scope :tuesday_no_rules, -> {where("tuesday IS NULL")}
  scope :tuesday_has_rules, -> {where("tuesday IS NOT NULL")}

  scope :wednesday_no_rules, -> {where("wednesday IS NULL")}
  scope :wednesday_has_rules, -> {where("wednesday IS NOT NULL")}

  scope :thursday_no_rules, -> {where("thursday IS NULL")}
  scope :thursday_has_rules, -> {where("thursday IS NOT NULL")}

  scope :friday_no_rules, -> {where("friday IS NULL")}
  scope :friday_has_rules, -> {where("friday IS NOT NULL")}

  scope :saturday_no_rules, -> {where("saturday IS NULL")}
  scope :saturday_has_rules, -> {where("saturday IS NOT NULL")}

  acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude



  def self.closeby_no_rules(latitude, longitude, distance, day)
    day.downcase!
    ps_no_rules = []
    case day
      when "sunday"
        spots_closeby = Parkingspot.sunday_no_rules.within(distance, :origin => [latitude, longitude]).all
      when "monday"
        spots_closeby = Parkingspot.monday_no_rules.within(distance, :origin => [latitude, longitude]).all
      when "tuesday"
        spots_closeby = Parkingspot.tuesday_no_rules.within(distance, :origin => [latitude, longitude]).all
      when "wednesday"
        spots_closeby = Parkingspot.wednesday_no_rules.within(distance, :origin => [latitude, longitude]).all
      when "thursday"
        spots_closeby = Parkingspot.thursday_no_rules.within(distance, :origin => [latitude, longitude]).all
      when "friday"
        spots_closeby = Parkingspot.friday_no_rules.within(distance, :origin => [latitude, longitude]).all
      when "saturday"
        spots_closeby = Parkingspot.saturday_no_rules.within(distance, :origin => [latitude, longitude]).all
    end
    spots_closeby.each do
      |spot|
      spots = {
        :latitude => spot["latitude"],
        :longitude => spot["longitude"],
        :sign => spot["signdescription"]
      }
      ps_no_rules << spots
    end
    return ps_no_rules
  end

  def self.closeby_with_rules(latitude, longitude, distance, day, time)
    ps_rules = []
    current_time = Chronic.parse(time).to_i
    spots_closeby = Parkingspot.get_days_rules(day).within(distance, :origin => [latitude, longitude]).all
    spots_closeby.each do |spot|
      spot["#{day}"].each do |range|
        start_time = Chronic.parse(range[0]).to_i
        end_time = Chronic.parse(range[-1]).to_i
        range = start_time..end_time
        if range.include?(current_time)
          x = {
            :latitude => spot["latitude"],
            :longitude => spot["longitude"],
            :sign => spot["signdescription"]
          }
          ps_rules << x
        end
      end
    end
    return ps_rules
  end

  def self.get_days_rules(day)
  day.downcase!
    case day
      when "sunday" then self.sunday_has_rules
      when "monday" then self.monday_has_rules
      when "tuesday" then self.tuesday_has_rules
      when "wednesday" then self.wednesday_has_rules
      when "thursday" then self.thursday_has_rules
      when "friday" then self.friday_has_rules
      when "saturday" then self.saturday_has_rules
      else
    end
  end

end
