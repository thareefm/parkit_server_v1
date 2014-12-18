class CreateParkingspots < ActiveRecord::Migration
  def change
    create_table :parkingspots do |t|
      t.string :boroughcode
      t.string :statusordernumber
      t.integer :signsequence
      t.integer :distance
      t.string :arrowpoints
      t.float :longitude
      t.float :latitude
      t.string :signdescription
      t.string :sunday, array: true, default: []
      t.string :monday, array: true, default: []
      t.string :tuesday, array: true, default: []
      t.string :wednesday, array: true, default: []
      t.string :thursday, array: true, default: []
      t.string :friday, array: true, default: []
      t.string :saturday, array: true, default: []
      t.timestamps
    end
  end
end

