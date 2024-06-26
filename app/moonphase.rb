module Moonphase
  VERSION = '0.0.1'
  # Moon
  # Create a Moon object. <tt>my_moon = Moonphase::Moon.new</tt>
  # Get the phase of the moon. <tt>my_moon.getphase("4/11")</tt>
  # Put the moon phase to stdout <tt>puts my_moon.phase</tt>
  class Moon
    # create a new moon instance, initialize it's phase to unknown.
    # current usage: my_moon = Moonphase::Moon.new
    def initialize
      @phase = "unknown phase"
    end
    attr_accessor :phase
    
    # getphase(arg)
    # Pass either a Time object like <tt>Time.now</tt> or a +String+ that +Time+ can parse like <tt>"4/11"</tt> or <tt>"Dec 31"</tt>
    # Current usage: <tt>my_moon.getphase("4/11")</tt>s
    def getphase(arg)
      # accept only String or Time types
      # if a string parse it into a time object then reformat
      if arg.class == String
        time = Time.parse(arg)
        date = time.strftime("%m %d %Y")
        # perform the calculation by calling the private method calcphase       
        calcphase(date)        
      # else if it's already a time object then just reformat.  
      elsif arg.class == Time
        date = arg.strftime("%m %d %Y")
        # perform the calcualtion by calling the private method calcphase       
        calcphase(date)
      # some basic error handling. raise an argument error if not string or time types
      else
        raise "wrong type must be string or time"
      end
    end
    
    private
    # Calculates the phase of the moon. 
    # A string is passed to +calcphase+ from +getphase+. The attribute phase of class Moon is updated as a result. 
    # Sections of this code including calculation were taken from the following:
    # Python code by HAB
    # http://www.daniweb.com/code/snippet492.html
    # and translated into Ruby by Chase Southard on 4/4/2009
    def calcphase(arg)
      
      # some constants to allow for the moon phase calculation. although, using local variables.
      ages = [18, 0, 11, 22, 3, 14, 25, 6, 17, 28, 9, 20, 1, 12, 23, 4, 15, 26, 7]
      offsets = [-1, 1, 0, 1, 2, 3, 4, 5, 7, 7, 9, 9]
      description = ["new (totally dark)",
          "waxing crescent (increasing to full)",
          "in its first quarter (increasing to full)",
          "waxing gibbous (increasing to full)",
          "full (full light)",
          "waning gibbous (decreasing from full)",
          "in its last quarter (decreasing from full)",
          "waning crescent (decreasing from full)"]
      
      # split the string argument into its components separated by spaces
      m, d, y = arg.split(/\s/)
      # make them into integers for calculations
      month = m.to_i
      day = d.to_i
      year = y.to_i
      
      # adjust day for a 30 calendar. I think.
      day = 1 if day == 31
      
      days_into_phase = ((ages[(year + 1) % 19] + ((day + offsets[month-1]) % 30) + (if year < 1900 then 1 else 0 end)) % 30)

      index = ((days_into_phase + 2) * 16/59.0).to_i

      index = 7 if index > 7
      
      # modify phase
      self.phase = description[index]
      
      index
    end
  end
  
end