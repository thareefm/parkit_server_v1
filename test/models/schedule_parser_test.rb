require 'test_helper'

class ScheduleParserTest < ActiveSupport::TestCase
  def setup
    @parser = ScheduleParser.new
  end

  def test__times_cannot_park_before_sunup
    input = "NO PARKING MIDNIGHT-6AM INCLUDING SUNDAY"
    expected = [["12AM", "6AM"]]
    actual = @parser.extract_times(input)
    assert_equal expected, actual
  end

  def test_times_no_parking_sat_noon
    input = "NO PARKING 1PM-MIDNIGHT (SINGLE ARROW)"
    expected = [["1PM", "12AM"]]
    actual = @parser.extract_times(input)
    assert_equal expected, actual
  end

  def test_times_no_parking_anytime
    input = "NO PARKING ANYTIME"
    expected = [["12AM", "11:59PM"]]
    actual = @parser.extract_times(input)
    assert_equal expected, actual
  end

  def test_times_adding_meridian_split
    input = "NO PARKING 7-10AM "
    expected = [["7AM","10AM"]]
    actual = @parser.extract_times(input)
    assert_equal expected, actual
  end

  def test_times_two_time_pairs
    input = "NO PARKING 7-9AM 4-7PM"
    expected = [["7AM", "9AM"],["4PM", "7PM"]]
    actual = @parser.extract_times(input)
    assert_equal expected, actual
  end

  def test_times_using_to_as_seperator
    input = "NO PARKING (SANITATION BROOM SYMBOL) 11AM TO 12:30PM MON & THURS"
    expected = [["11AM", "12:30PM"]]
    actual = @parser.extract_times(input)
    assert_equal expected, actual
  end

  def test_dates_cannot_park_including_sunday
    input = "NO PARKING MIDNIGHT-6AM INCLUDING SUNDAY"
    expected = ["INCLUDING", "SUNDAY"]
    actual = @parser.extract_dates(input)
    assert_equal expected, actual
  end

  def test_dates_abbreviated
    input = "NO PARKING SAT SUN HOILDAYS MAY 15 - SEPT 30"
    expected = ["SATURDAY", "SUNDAY"]
    actual = @parser.extract_dates(input)
    assert_equal expected, actual
  end

  def test_dates_no_parking_sunday_and_holidays
    input = "NO PARKING SUNDAY & HOLIDAYS (SINGLE ARROW)"
    expected = ["SUNDAY"]
    actual = @parser.extract_dates(input)
    assert_equal expected, actual
  end

  def test_dates_no_parking_sat
    input = "NO PARKING 1PM-MIDNIGHT SATURDAY (SINGLE ARROW)"
    expected = ["SATURDAY"]
    actual = @parser.extract_dates(input)
    assert_equal expected, actual
  end

  def test_dates_mon_thru_fri
    input = "NO PARKING 8AM-6PM MON THRU FRI EXCEPT STATE OWNED VEHICLES"
    expected = ["MONDAY", "THRU", "FRIDAY"]
    actual = @parser.extract_dates(input)
    assert_equal expected, actual
  end

  def test_dates_no_parking_anytime
    input = "NO PARKING ANYTIME"
    expected = ["ANYTIME"]
    actual = @parser.extract_dates(input)
    assert_equal expected,actual
  end

  def test_dates
    input = "NO PARKING (SANITATION BROOM SYMBOL) 7:30-8:30AM EXCEPT SUN"
    expected = ["EXCEPT", "SUNDAY"]
    actual = @parser.extract_dates(input)
    assert_equal expected, actual
  end

  def test_td_cannot_park_anytime
    input = "NO PARKING ANYTIME"
    expected = {
      :SUNDAY =>  [["12AM", "11:59PM"]],
      :MONDAY =>  [["12AM", "11:59PM"]],
      :TUESDAY => [["12AM", "11:59PM"]] ,
      :WEDNESDAY =>  [["12AM", "11:59PM"]],
      :THURSDAY => [["12AM", "11:59PM"]],
      :FRIDAY => [["12AM", "11:59PM"]],
      :SATURDAY => [["12AM", "11:59PM"]]
    }
    actual = @parser.call(input)
    assert_equal expected, actual
  end

  def test_td_cannot_park_bf_sunup
    input = "NO PARKING MIDNIGHT-6AM INCLUDING SUNDAY"
    expected = {
      :SUNDAY =>  [["12AM", "6AM"]],
      :MONDAY =>  [["12AM", "6AM"]],
      :TUESDAY => [["12AM", "6AM"]] ,
      :WEDNESDAY =>  [["12AM", "6AM"]],
      :THURSDAY => [["12AM", "6AM"]],
      :FRIDAY => [["12AM", "6AM"]],
      :SATURDAY => [["12AM", "6AM"]]
    }
    actual = @parser.call(input)
    assert_equal expected, actual
  end

  def test_td_can_park_anytime_on_sundays
    input = "NO PARKING 7-9AM 4-7PM EXCEPT SUNDAY"
    expected = {
        SUNDAY: nil,
        MONDAY: [["7AM", "9AM"],["4PM", "7PM"]],
        TUESDAY: [["7AM", "9AM"],["4PM", "7PM"]],
        WEDNESDAY: [["7AM", "9AM"],["4PM", "7PM"]],
        THURSDAY: [["7AM", "9AM"],["4PM", "7PM"]],
        FRIDAY: [["7AM", "9AM"],["4PM", "7PM"]],
        SATURDAY: [["7AM", "9AM"],["4PM", "7PM"]]
      }
    actual = @parser.call(input)
    assert_equal expected, actual
  end

  def test_td_no_parking_on_saturday
    input = "NO PARKING 1PM-MIDNIGHT SATURDAY (SINGLE ARROW)"
    expected = {
      SUNDAY: nil,
      MONDAY: nil,
      TUESDAY: nil,
      WEDNESDAY: nil,
      THURSDAY: nil,
      FRIDAY: nil,
      SATURDAY: [["1PM", "12AM"]]
    }
    actual = @parser.call(input)
    assert_equal expected, actual
  end

  def test_td_no_parking_mon_thru_friday
    input = "NO PARKING 8AM-6PM MON THRU FRI EXCEPT STATE OWNED VEHICLES"
    expected = {
      SUNDAY: nil,
      MONDAY: [["8AM", "6PM"]],
      TUESDAY: [["8AM", "6PM"]],
      WEDNESDAY: [["8AM", "6PM"]],
      THURSDAY: [["8AM", "6PM"]],
      FRIDAY: [["8AM", "6PM"]],
      SATURDAY: nil
    }
    actual = @parser.call(input)
    assert_equal expected, actual
  end

  def test_td_no_parking_mon_and_friday
    input = "NO PARKING (SANITATION BROOM SYMBOL) 9-10:30AM MON & THURS"
    expected = {
      SUNDAY: nil,
      MONDAY: [["9AM", "10:30AM"]],
      TUESDAY: nil,
      WEDNESDAY: nil,
      THURSDAY: [["9AM", "10:30AM"]],
      FRIDAY: nil,
      SATURDAY: nil
    }
    actual = @parser.call(input)
    assert_equal expected, actual
  end

  def test_td_night_regulation
    input = "NIGHT REGULATION (MOON & STARS SYMBOLS) NO PARKING (SANITATION BROOM SYMBOL) 3AM-6AM MON WED FRI"
    expected = {
      SUNDAY: nil,
      MONDAY: [["3AM", "6AM"]],
      TUESDAY: nil,
      WEDNESDAY: [["3AM", "6AM"]],
      THURSDAY: nil,
      FRIDAY: [["3AM", "6AM"]],
      SATURDAY: nil
    }
    actual = @parser.call(input)
    assert_equal expected, actual
  end

  def test_td_muni_meter_regulation
    input = "1 HR MUNI-METER PARKING 9AM-7PM EXCEPT SUNDAY"
    expected = {
      SUNDAY: nil,
      MONDAY: [["9AM", "7PM"]],
      TUESDAY: [["9AM", "7PM"]],
      WEDNESDAY: [["9AM", "7PM"]],
      THURSDAY: [["9AM", "7PM"]],
      FRIDAY: [["9AM", "7PM"]],
      SATURDAY: [["9AM", "7PM"]]
    }
    actual = @parser.call(input)
    assert_equal expected, actual
  end

  def test_td_curb_line
    input = "Curb Line"
    expected = {
        SUNDAY: nil,
        MONDAY: nil,
        TUESDAY: nil,
        WEDNESDAY: nil,
        THURSDAY: nil,
        FRIDAY: nil,
        SATURDAY: nil
      }
    actual = @parser.call(input)
    assert_equal expected, actual
  end


  def test_random_rules
   input = "NO PARKING ANYTIME (SUPERSEDES R7-40 DON'T USE --R7-40)"
   expected = {
     :SUNDAY =>  [["12AM", "11:59PM"]],
     :MONDAY =>  [["12AM", "11:59PM"]],
     :TUESDAY => [["12AM", "11:59PM"]] ,
     :WEDNESDAY =>  [["12AM", "11:59PM"]],
     :THURSDAY => [["12AM", "11:59PM"]],
     :FRIDAY => [["12AM", "11:59PM"]],
     :SATURDAY => [["12AM", "11:59PM"]]
   }
    actual = @parser.call(input)
    assert_equal expected, actual
  end

  def test_td_no_standing
    input = "NO STANDING ANYTIME (ARROW)(REPLACED BY SP-10BA)"
    expected = {
      :SUNDAY =>  [["12AM", "11:59PM"]],
      :MONDAY =>  [["12AM", "11:59PM"]],
      :TUESDAY => [["12AM", "11:59PM"]] ,
      :WEDNESDAY =>  [["12AM", "11:59PM"]],
      :THURSDAY => [["12AM", "11:59PM"]],
      :FRIDAY => [["12AM", "11:59PM"]],
      :SATURDAY => [["12AM", "11:59PM"]]
    }
    actual = @parser.call(input)
    assert_equal expected, actual
  end

  def test_bus_stop_sign
    input = "BUS STOP SIGN (BUS & HANDICAP SYMBOLS) NO STANDING W/ SINGLE ARROW"
    expected = {
      :SUNDAY =>  [["12AM", "11:59PM"]],
      :MONDAY =>  [["12AM", "11:59PM"]],
      :TUESDAY => [["12AM", "11:59PM"]] ,
      :WEDNESDAY =>  [["12AM", "11:59PM"]],
      :THURSDAY => [["12AM", "11:59PM"]],
      :FRIDAY => [["12AM", "11:59PM"]],
      :SATURDAY => [["12AM", "11:59PM"]]
    }
    actual = @parser.call(input)
    assert_equal expected, actual
  end

  def test_random_string
    input = "14 STREET & UNION SQ (BOTTOM LOCATION PANEL)(USE AS EXAMPLE FOR DIFFERENT LOCATION)"
    expected = {
      :SUNDAY =>  [["12AM", "11:59PM"]],
      :MONDAY =>  [["12AM", "11:59PM"]],
      :TUESDAY => [["12AM", "11:59PM"]] ,
      :WEDNESDAY =>  [["12AM", "11:59PM"]],
      :THURSDAY => [["12AM", "11:59PM"]],
      :FRIDAY => [["12AM", "11:59PM"]],
      :SATURDAY => [["12AM", "11:59PM"]]
    }
    actual = @parser.call(input)
    assert_equal expected, actual
  end

  def test_long_string_with_lots_of_numbers_and_incorrect_spacing
    input = "NO PARKING (SANITATION BROOM SYMBOL)9:30-11AM TUES & FRI (SUPERSEDES SP-63C DATED 6-24-85 (12X18) & SUPERSEDED SP-358C DATED 6-17-92"
    expected = {
      :SUNDAY =>  nil,
      :MONDAY =>  nil,
      :TUESDAY => [["9:30AM", "11AM"]],
      :WEDNESDAY =>  nil,
      :THURSDAY => nil,
      :FRIDAY => [["9:30AM", "11AM"]],
      :SATURDAY => nil
    }
    actual = @parser.call(input)
    assert_equal expected, actual
  end

  def test_td_mon_thru_friday
  input = "NO PARKING 8AM-6PM MON THRU FRI (ARROW) (SUPERSEDED BY R7-45RA)"
  expected = {
    :SUNDAY =>  nil,
    :MONDAY =>  [["8AM", "6PM"]],
    :TUESDAY => [["8AM", "6PM"]],
    :WEDNESDAY => [["8AM", "6PM"]],
    :THURSDAY => [["8AM", "6PM"]],
    :FRIDAY => [["8AM", "6PM"]],
    :SATURDAY => nil
  }
  actual = @parser.call(input)
  assert_equal expected, actual
  end

  def test_times
    input = "NO PARKING 8AM-6PM MON THRU FRI (ARROW) (SUPERSEDED BY R7-45RA)"
    expected = [["8AM", "6PM"]]
    actual = @parser.extract_times(input)
    assert_equal expected, actual
  end

  def test_td_tues_and_friday
    input = "NO PARKING (SANITATION BROOM SYMBOL) 11:30AM TO 1PM TUES & FRI W/SINGLE ARROW"
    expected = {
      :SUNDAY =>  nil,
      :MONDAY =>  nil,
      :TUESDAY => [["11:30AM", "1PM"]],
      :WEDNESDAY => nil,
      :THURSDAY => nil,
      :FRIDAY => [["11:30AM", "1PM"]],
      :SATURDAY => nil
    }
    actual = @parser.call(input)
    assert_equal expected, actual
  end

end
