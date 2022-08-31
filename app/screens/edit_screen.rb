class EditScreen < PM::XLFormScreen
  title I18n.t("Fishing")

  form_options required: :asterisks,
               on_save: { system_item: :save, action: :'save_form:' },
               on_cancel: { system_item: :stop, action: :cancel_form },
               auto_focus: false
               
  def viewDidLoad
    @lat = @lon = 0
    super
  end

  def form_data
    weather = Weather::CONDITIONS
    wind_directions = Weather::WIND_DIRECTIONS
    unless @record
      @locationManager = CLLocationManager.alloc.init
      @locationManager.requestWhenInUseAuthorization
      @locationManager.delegate = self
      @locationManager.startUpdatingLocation
    end
    [
          { 
           title: I18n.t("PHOTOS"),
           footer: I18n.t('You can add not more than 7 photos'),
           name: :images,
           options: [:insert, :delete, :reorder],
           cells: if not @record or NSKeyedUnarchiver.unarchiveObjectWithData(@record.images).size == 0
           [
             {
               type: :image,
               name: :image,
               title: '',
               on_add: -> {
                 @current_images ||= 1
                 @current_images += 1

                 if @current_images >= 7
                   section = section_with_tag(:images)
                   section.options = [:delete]
                 end
               },
               on_remove: -> {
                 @current_images -= 1

                 if @current_images < 7
                   section = section_with_tag(:images)
                   section.options = [:insert, :delete]
                 end
               }
             }
           ]
           else
             NSKeyedUnarchiver.unarchiveObjectWithData(@record.images).map do |image|
                {
                  type: :image,
                  name: :image,
                  title: '',
                  value: UIImage.imageWithData(image),
                  on_add: -> {
                    @current_images ||= 1
                    @current_images += 1

                    if @current_images >= 4
                      section = section_with_tag(:images)
                      section.options = [:delete]
                    end
                  },
                  on_remove: -> {
                    @current_images -= 1

                    if @current_images < 4
                      section = section_with_tag(:images)
                      section.options = [:insert, :delete]
                    end
                  }
                }
             end
           end
           # cells: [
           #   {
           #     name: :cover,
           #     type: :image,
           #     value: @record ? UIImage.imageWithData(NSKeyedUnarchiver.unarchiveObjectWithData(@record.images)[0]) : nil,
           #     height: 120
           #   }
           # ]
          } ,
          {
            title:  I18n.t("DATE AND TIME"),
            footer: I18n.t('If you do not specify a date and time, the current ones will be used'),
            cells: [
              {
                title: I18n.t('Fishing date'),
                name: :fishingDate,
                type: :datetime_inline,
                required: true,
                value: @record ? @record.fishingDate : Time.now,
                appearance: {
                    font: UIFont.fontWithName('Helvetica', size: 12.0),
                    detail_font: UIFont.fontWithName('Helvetica', size: 15.0),
                    color: UIColor.placeholderTextColor,
                    detail_color: UIColor.labelColor
                },
                properties: {
                  # minute_interval: 15 - see min/max
                }
              },
              {
                title: I18n.t('Duration, hours'),
                name: :duration,
                type: :number,
                required: true,
                value: @record ? @record.duration : '',
                appearance: {
                    font: UIFont.fontWithName('Helvetica', size: 12.0),
                    detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                    color: UIColor.placeholderTextColor,
                    detail_color: UIColor.labelColor,
                    alignment: :right,
                    "textField.textColor" => UIColor.labelColor,
                    "textField.font" => UIFont.fontWithName('Helvetica', size: 15.0)
                }
              }
            ]
          },
          {
          title: I18n.t("LOCATION"),
          footer: I18n.t('Specify the place of fishing for easy search in the future'),
          cells: [
            {
              title: I18n.t('Fishing place'),
              name: :place,
              type: :text,
              required: true,
              value: @record ? @record.place : '',
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.placeholderTextColor,
                  detail_color: UIColor.labelColor,
                  alignment: :right,
                  "textField.textColor" => UIColor.labelColor,
                  "textField.font" => UIFont.fontWithName('Helvetica', size: 15.0)
              }
            },
            {
              title: I18n.t('Region'),
              name: :region,
              type: :text,
              required: true,
              value: @record ? @record.region : '',
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.placeholderTextColor,
                  detail_color: UIColor.labelColor,
                  alignment: :right,
                  "textField.textColor" => UIColor.labelColor,
                  "textField.font" => UIFont.fontWithName('Helvetica', size: 15.0)
              }
            }
          ]
          },
          {
          title: I18n.t("CATCH"),
          footer: I18n.t('Describe your fishing details'),
          cells: [
            {
              title: I18n.t('Fish'),
              name: :fish,
              type: :text,
              required: true,
              value: @record ? @record.fish : '',
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.placeholderTextColor,
                  detail_color: UIColor.labelColor,
                  alignment: :right,
                  "textField.textColor" => UIColor.labelColor,
                  "textField.font" => UIFont.fontWithName('Helvetica', size: 15.0)
              }
            },
            {
              title: I18n.t('Bait'),
              name: :bait,
              type: :text,
              required: true,
              value: @record ? @record.bait : '',
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.placeholderTextColor,
                  detail_color: UIColor.labelColor,
                  alignment: :right,
                  "textField.textColor" => UIColor.labelColor,
                  "textField.font" => UIFont.fontWithName('Helvetica', size: 15.0)
              }
            },
            {
              title: I18n.t('Quantity, pcs'),
              name: :fishAmount,
              type: :integer,
              required: true,
              value: @record ? @record.fishAmount : '',
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.placeholderTextColor,
                  detail_color: UIColor.labelColor,
                  alignment: :right,
                  "textField.textColor" => UIColor.labelColor,
                  "textField.font" => UIFont.fontWithName('Helvetica', size: 15.0)
              }
            },
            {
              title: I18n.t('Weight, lb'),
              name: :fishWeight,
              type: :text,
              required: true,
              value: @record ? @record.fishWeight.round(2) : '',
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.placeholderTextColor,
                  detail_color: UIColor.labelColor,
                  alignment: :right,
                  "textField.textColor" => UIColor.labelColor,
                  "textField.font" => UIFont.fontWithName('Helvetica', size: 15.0)
              },
              keyboard_type: :numbers_punctuation
            },
            {
              title: I18n.t('Description'),
              name: :notes,
              type: :selector_push,
              view_controller_class: NotesController,
              required: false,
              value: @record ? @record.notes : '',
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 15.0),
                  color: UIColor.placeholderTextColor,
                  detail_color: UIColor.labelColor
              }
            }
          ],
          },
          {
            title: I18n.t("LOCATION MAP"),
            footer: I18n.t('The GPS coordinates of the fishing will be indicated on the map'),
            cells: [
              {
                title: I18n.t('Coordinates'),
                type: :selector_push,
                name: :coordinates,
                view_controller_class: MapController,
                value_transformer: CLLocationValueTrasformer,
                value: CLLocationCoordinate2DMake(@record ? @record.lat : @lat, @record ? @record.lon : @lon),
                appearance: {
                    font: UIFont.fontWithName('Helvetica', size: 12.0),
                    detail_font: UIFont.fontWithName('Helvetica', size: 15.0),
                    color: UIColor.placeholderTextColor,
                    detail_color: UIColor.labelColor,
                }
              }
            ]
          },
          {
          title: I18n.t("WEATHER DATA"),
          footer: I18n.t('Add a weather description. If there is an access key to the meteodata API (specified in the application settings), data can be downloaded by clicking on the corresponding button.'),
          cells: [
            {
              title: I18n.t('Weather'),
              name: :weather,
              type: :selector_picker_view,
              required: true,
              value: @record ? @record.weather : 0,
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 15.0),
                  color: UIColor.placeholderTextColor,
                  detail_color: UIColor.labelColor
              },
              options: Hash[weather.each_with_index.map do |str, idx|
                            [idx, str]
                       end],
            },
            {
              title: I18n.t('Temperature'),
              name: :temperature,
              type: :selector_picker_view,
              required: true,
              value: @record ? @record.temperature : 15,
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 15.0),
                  color: UIColor.placeholderTextColor,
                  detail_color: UIColor.labelColor
              },
              options: Hash[(-30..40).map do |temp|
                            [temp, temp > 0 ? "+#{temp}" : temp.to_s]
                       end],
            },
            {
              title: I18n.t('Pressure, hg mm'),
              name: :pressure,
              type: :integer,
              required: false,
              value: @record ? @record.pressure : 0,
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.placeholderTextColor,
                  detail_color: UIColor.labelColor,
                  alignment: :right,
                  "textField.textColor" => UIColor.labelColor,
                  "textField.font" => UIFont.fontWithName('Helvetica', size: 15.0)                  
              }
            },
            {
              title: I18n.t('Wind direction'),
              name: :windDirection,
              type: :selector_picker_view,
              required: false,
              value: @record ? @record.windDirection : 0,
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 15.0),
                  color: UIColor.placeholderTextColor,
                  detail_color: UIColor.labelColor
              },
              options: Hash[wind_directions.each_with_index.map do |str, idx|
                            [idx, str]
                       end],
            },
            {
              title: I18n.t('Wind speed, m/s'),
              name: :windSpeed,
              type: :integer,
              required: false,
              value: @record ? @record.windSpeed : 0,
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.placeholderTextColor,
                  detail_color: UIColor.labelColor,
                  alignment: :right,
                  "textField.textColor" => UIColor.labelColor,
                  "textField.font" => UIFont.fontWithName('Helvetica', size: 15.0)
              }
            },
            {
              title: I18n.t('Download'),
              name: :click_me,
              type: :button,
              on_click: -> (cell) {
                @coordinates = value_for_cell(:coordinates)
                @date = value_for_cell(:fishingDate)
                unless NSUserDefaults.standardUserDefaults['meteostat_key'].blank?
                hud = JGProgressHUD.progressHUDWithStyle(JGProgressHUDStyleDark)
                  hud.textLabel.text = I18n.t("Weather data loading")
                  hud.showInView(app.screen.view)
                  # https://dev.meteostat.net/api/
                  @client = AFMotion::SessionClient.build("https://meteostat.p.rapidapi.com/") do
                    session_configuration :default
                    header "Accept", "application/json"
                    header "x-rapidapi-key", NSUserDefaults.standardUserDefaults['meteostat_key']
                    header "x-rapidapi-host", "meteostat.p.rapidapi.com"

                    response_serializer :json
                  end
                  unless $cache.has_key?("#{@coordinates.latitude.round(1)}-#{@coordinates.longitude.round(1)}")
                    @client.get("stations/nearby?lat=#{@coordinates.latitude}&lon=#{@coordinates.longitude}&limit=1") do |result|
                      if result.success?
                        $cache["#{@coordinates.latitude.round(1)}-#{@coordinates.longitude.round(1)}"] = result.object['data'][0]['id']
                        @client.get("stations/hourly?station=#{result.object['data'][0]['id']}&start=#{@date.strftime("%Y-%m-%d")}&end=#{@date.strftime("%Y-%m-%d")}") do |result|
                          if result.success?
                            # TODO: show error message
                            update_weather_data(result)
                            hud.dismiss
                          elsif result.failure?
                            hud.dismiss
                            app.alert(result.error.localizedDescription)
                          else
                            hud.dismiss
                          end
                        end
                      elsif result.failure?
                        hud.dismiss
                        app.alert(result.error.localizedDescription)
                      else
                        hud.dismiss
                      end
                    end
                  else
                    @client.get("stations/hourly?station=#{$cache["#{@coordinates.latitude.round(1)}-#{@coordinates.longitude.round(1)}"]}&start=#{@date.strftime("%Y-%m-%d")}&end=#{@date.strftime("%Y-%m-%d")}") do |result|
                      if result.success?
                        update_weather_data(result)
                        hud.dismiss
                      elsif result.failure?
                        hud.dismiss
                        app.alert(result.error.localizedDescription)
                      else
                        hud.dismiss
                      end
                    end
                  end
                end
              },
              enabled: (not NSUserDefaults.standardUserDefaults['meteostat_key'].blank?)
            }
          ]
          },
          {      
          title: I18n.t("TROPHIES"),
          footer: I18n.t('This entry will be displayed in the Trophies section.'),
          cells: [
            {
              title: I18n.t('Add to trophies'),
              name: :isFavorite,
              type: :switch,
              value: @record ? @record.isFavorite : false,
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 15.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.placeholderTextColor,
                  detail_color: UIColor.labelColor
              }
            }
          ]
         }
    ]
  end
  
  def record=(record)
    @record = record
  end
  
  def save_form(values)
    m = Moonphase::Moon.new
    unless @record
      Fishing.create(
        id: (Fishing.max(:id).is_a?(Array) ? 1 : Fishing.max(:id) + 1),
        fishingDate: values['fishingDate'], 
        lat: values['coordinates'].latitude, 
        lon: values['coordinates'].longitude, 
        duration: values['duration'],
        isFavorite: values['isFavorite'], 
        place: values['place'], 
        region: values['region'], 
        fish: values['fish'], 
        notes: values['notes'], 
        fishAmount: values['fishAmount'], 
        bait: values['bait'],
        fishWeight: values['fishWeight'].to_f, 
        temperature: values['temperature'], 
        weather: values['weather'],
        pressure: values['pressure'],
        windDirection: values['windDirection'].to_i,
        windSpeed: values['windSpeed'],        
        moonPhase: m.getphase(values['fishingDate']),
        cover: UIImageJPEGRepresentation(values['images'][0], 1),
        images: NSKeyedArchiver.archivedDataWithRootObject(values['images'].map {|img| UIImageJPEGRepresentation(img, 1)})
      )
    else
      @record.update(
        fishingDate: values['fishingDate'], 
        lat: values['coordinates'].latitude, 
        lon: values['coordinates'].longitude, 
        duration: values['duration'],
        isFavorite: values['isFavorite'], 
        place: values['place'], 
        region: values['region'], 
        fish: values['fish'], 
        notes: values['notes'], 
        fishAmount: values['fishAmount'], 
        bait: values['bait'],
        fishWeight: values['fishWeight'].to_f, 
        temperature: values['temperature'], 
        weather: values['weather'],
        pressure: values['pressure'],
        windDirection: values['windDirection'].to_i,
        windSpeed: values['windSpeed'],
        moonPhase: m.getphase(values['fishingDate']),
        cover: UIImageJPEGRepresentation(values['images'][0], 1),
        images: NSKeyedArchiver.archivedDataWithRootObject(values['images'].map {|img| UIImageJPEGRepresentation(img, 1)})
      )
    end
    cdq.save
    NSNotificationCenter.defaultCenter.postNotificationName("reloadFishing", object: nil)
    @record = nil
    close
  end
    
  def cancel_form
    @record = nil
    close
  end
  
  def locationManager(manager, didUpdateLocations:locations)
    coordinate = locations[0].coordinate
    @lat = coordinate.latitude
    @lon = coordinate.longitude
    manager.stopUpdatingLocation
    row = self.form.formRowAtIndex(NSIndexPath.indexPathForRow(0,inSection: 4))
    row.value = CLLocationCoordinate2DMake(@lat, @lon)
    self.reloadFormRow(row)
  end
  
  def update_weather_data(result)
    result.object['data'].each do |res|
      if res['time'] == @date.utc.strftime("%Y-%m-%d %H:00:00")
        if res['coco']
          row = self.form.formRowAtIndex(NSIndexPath.indexPathForRow(0,inSection: 5))
          weather =  Weather::CONDITIONS
          val = case res['coco']
          when 1..2
            0
          when 3
            1
          when 4
            2
          when 5..6
            5
          when 7..11,17..26
            3
          when 12..16
            4
          when 27
            7
          end
          row.value = XLFormOptionsObject.alloc.initWithValue(val, displayText: weather[val])
          self.reloadFormRow(row)
        end
      
        row = self.form.formRowAtIndex(NSIndexPath.indexPathForRow(1,inSection: 5))
        row.value = XLFormOptionsObject.alloc.initWithValue(res['temp'].round.to_i, displayText: res['temp'] ? "+#{res['temp']}" : res['temp'].to_s)
        self.reloadFormRow(row)
      
        row = self.form.formRowAtIndex(NSIndexPath.indexPathForRow(2,inSection: 5))
        row.value = res['pres'] ? (res['pres'] / 1.333).round.to_i : 740
        self.reloadFormRow(row)
      
        row = self.form.formRowAtIndex(NSIndexPath.indexPathForRow(3,inSection: 5))
        val = res['wdir'] / 45
        wind_directions = Weather::WIND_DIRECTIONS
        row.value = XLFormOptionsObject.alloc.initWithValue(val.to_s, displayText: wind_directions[val])
        self.reloadFormRow(row)
      
        row = self.form.formRowAtIndex(NSIndexPath.indexPathForRow(4,inSection: 5))
        row.value = (res['wspd'] / 3.6).round.to_i
        self.reloadFormRow(row)
      
        self.tableView.reloadData
      end
    end
  end
end