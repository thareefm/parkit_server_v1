class ParkingspotsController < ApplicationController

  def api1
    parkingspots = Parkingspot.closeby_no_rules(40.7400447,-73.9896498, 1, "MONDAY")
    render json: parkingspots
  end

  def api2
    parkingspots = Parkingspot.closeby_with_rules(40.7400447,-73.9896498, 1, "MONDAY", "5PM")
    render json: parkingspots
  end

end
