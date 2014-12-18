class ScheduleParser
  TIME_FRAGMENT = /((?:\d{1,2}(?::30)?(?:AM|PM)?|MIDNIGHT|NOON))/
  TIME_SEPARATOR = /\s?(?:-|TO)\s?/
  TIMES_EXP = /#{TIME_FRAGMENT}#{TIME_SEPARATOR}#{TIME_FRAGMENT}/
  DAYS_EXP = /(ANYTIME)|((?:EXCEPT\s)|(?:INCLUDING\s))?((?:MONDAY|\bMON\b)|(?:TUESDAY|\bTUES\b)|(?:WEDNESDAY|\bWED\b)|(?:THURSDAY|\bTHURS\b)|(?:FRIDAY|\bFRI\b)|(?:SATURDAY|\bSAT\b)|(?:SUNDAY|\bSUN\b)|(?:THRU))\s?((?:MONDAY|\bMON\b)|(?:TUESDAY|\bTUES\b)|(?:WEDNESDAY|\bWED\b)|(?:THURSDAY|\bTHURS\b)|(?:FRIDAY|\bFRI\b)|(?:SATURDAY|\bSAT\b)|(?:SUNDAY|\bSUN\b)|(?:THRU))?\s?((?:MONDAY|\bMON\b)|(?:TUESDAY|\bTUES\b)|(?:WEDNESDAY|\bWED\b)|(?:THURSDAY|\bTHURS\b)|(?:FRIDAY|\bFRI\b)|(?:SATURDAY|\bSAT\b)|(?:SUNDAY|\bSUN\b)|(?:THRU))?/
  DAYS_OF_WEEK=["SUNDAY" , "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"]
  ARRAY_OF_NON_RULES = ["Curb Line", "Property Line", "Building Line"]
  HASH = {
    SUNDAY: nil,
    MONDAY: nil,
    TUESDAY: nil,
    WEDNESDAY: nil,
    THURSDAY: nil,
    FRIDAY: nil,
    SATURDAY: nil
  }


  def call(string_to_parse)
    if string_to_parse != nil
      times = extract_times(string_to_parse)
      dates = extract_dates(string_to_parse)
      result = combine(dates, times)
    else
      result = HASH
    end
      return result
    # MAYBE IN THE FUTURE:
    # dates = extract_dates(string_to_parse)
    # all_exceptions = combine(dates, times)
  end


  def extract_times(string_to_parse)
    times = string_to_parse.scan TIMES_EXP
    if (ARRAY_OF_NON_RULES).include?(string_to_parse)
      times = nil
    end
    if times == nil
      times = nil
    elsif times.empty?
      times = [["12AM", "11:59PM"]]
    elsif ["M", "N", "T"].include?(times[0][-1][-1]) && ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].include?(times[-1][-1][-1])
      times = [times[0]]
    elsif  ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].include?(times[-1][-1][-1]) && (string_to_parse).include?("NO PARKING")
      times = [["12AM", "11:59PM"]]
    elsif ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].include?(times[-1][-1][-1])
      times = nil
    else
      times.map! { |time| change_words_into_times(time) }
      times.map! { |time| format_times(time)}
    end
  end

  def extract_dates(string_to_parse)
    dates = string_to_parse.scan DAYS_EXP
    dates.empty? ? (dates = DAYS_OF_WEEK) : dates_modify(dates)
  end

  def dates_modify(dates)
    dates.reject! { |d| d.empty? }
    dates.flatten!.compact!
    dates.map! {|d| d.strip }
    dates.map! {|d| change_abv_days_to_days(d) }
  end

  def combine(dates, times)
   if dates.include?("INCLUDING")
     HASH.update(HASH){|k,v| v=times}
   elsif dates.include?("EXCEPT")
     HASH.update(HASH){ |k,v| dates.include?(k.to_s) ? v=nil : v=times }
   elsif dates.include?("ANYTIME")
     HASH.update(HASH){|k,v| v=times}
   elsif dates.include?("THRU")
     begin_day_index = DAYS_OF_WEEK.index(dates[0])
     end_day_index = DAYS_OF_WEEK.index(dates[-1])
     range = (begin_day_index..end_day_index).to_a
     modified_dates = []
     range.each {|number| modified_dates << DAYS_OF_WEEK[number]}
     HASH.update(HASH){|k,v| modified_dates.include?(k.to_s) ? v=times : v=nil }
   else
     HASH.update(HASH){|k,v| dates.include?(k.to_s) ? v=times : v=nil }
   end
  end


  def change_words_into_times(times)
    times.map do |time|
      case time
        when "MIDNIGHT" then "12AM"
        when "NOON" then "12PM"
        else time
      end
    end
  end

  def change_abv_days_to_days(date)
      case date
        when "SUN" then "SUNDAY"
        when "MON" then "MONDAY"
        when "TUES" then "TUESDAY"
        when "WED" then "WEDNESDAY"
        when "THURS" then "THURSDAY"
        when "FRI" then "FRIDAY"
        when "SAT" then "SATURDAY"
        else date
      end
  end

  def format_times(times)
    return times if times == ['', '']
    desired_endings = ["AM", "PM"]
    start_time_ending = times[0][-2..-1]
    end_time_ending = times[1][-2..-1]
    return times if desired_endings.include?(start_time_ending) && desired_endings.include?(end_time_ending)
    start_time = times[0]
    end_time = times[1]
    if end_time_ending
    start_time << end_time_ending
    [start_time, end_time]
    else
      times = nil
    end
  end

end
