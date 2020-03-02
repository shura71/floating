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
           footer: 'Вы можете добавить не более 7 фото',
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
            footer: 'Если не указывать дату и время, то будут использованы текущие',
            cells: [
              {
                title:       'Дата рыбалки',
                name: :fishingDate,
                type: :datetime,
                required: true,
                value: @record ? @record.fishingDate : Time.now,
                appearance: {
                    font: UIFont.fontWithName('Helvetica', size: 12.0),
                    detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                    color: UIColor.grayColor,
                    detail_color: UIColor.blackColor
                }
              },
              {
                title:       'Длительность, часов',
                name: :duration,
                type: :number,
                required: true,
                value: @record ? @record.duration : '',
                appearance: {
                    font: UIFont.fontWithName('Helvetica', size: 12.0),
                    detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                    color: UIColor.grayColor,
                    detail_color: UIColor.blackColor,
                    alignment: :right
                }
              }
            ]
          },
          {
          title: I18n.t("LOCATION"),
          footer: 'Укажите место ловли для удобного поиска в дальнейшем',
          cells: [
            {
              title:       'Место рыбалки',
              name: :place,
              type: :text,
              required: true,
              value: @record ? @record.place : '',
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.grayColor,
                  detail_color: UIColor.blackColor,
                  alignment: :right
              }
            },
            {
              title:       'Регион',
              name: :region,
              type: :text,
              required: true,
              value: @record ? @record.region : '',
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.grayColor,
                  detail_color: UIColor.blackColor,
                  alignment: :right
              }
            }
          ]
          },
          {
          title: I18n.t("CATCH"),
          footer: 'Опишите подробнее Вашу рыбалку',
          cells: [
            {
              title:       'Рыба',
              name: :fish,
              type: :text,
              required: true,
              value: @record ? @record.fish : '',
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.grayColor,
                  detail_color: UIColor.blackColor,
                  alignment: :right
              }
            },
            {
              title:       'Наживка',
              name: :bait,
              type: :text,
              required: true,
              value: @record ? @record.bait : '',
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.grayColor,
                  detail_color: UIColor.blackColor,
                  alignment: :right
              }
            },
            {
              title:       'Количество, шт',
              name: :fishAmount,
              type: :integer,
              required: true,
              value: @record ? @record.fishAmount : '',
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.grayColor,
                  detail_color: UIColor.blackColor,
                  alignment: :right
              }
            },
            {
              title:       'Вес, кг',
              name: :fishWeight,
              type: :text,
              required: true,
              value: @record ? @record.fishWeight.round(2) : '',
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.grayColor,
                  detail_color: UIColor.blackColor,
                  alignment: :right
              },
              keyboard_type: :numbers_punctuation
            },
            {
              title:       'Описание',
              name: :notes,
              type: :selector_push,
              view_controller_class: NotesController,
              required: false,
              value: @record ? @record.notes : '',
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.grayColor,
                  detail_color: UIColor.blackColor
              }
            }
          ],
          },
          {
            title: I18n.t("LOCATION MAP"),
            footer: 'На карте будут указаны GPS координаты рыбалки',
            cells: [
              {
                title: 'Координаты',
                type: :selector_push,
                name: :coordinates,
                view_controller_class: MapController,
                value_transformer: CLLocationValueTrasformer,
                value: CLLocationCoordinate2DMake(@record ? @record.lat : @lat, @record ? @record.lon : @lon),
                appearance: {
                    font: UIFont.fontWithName('Helvetica', size: 12.0),
                    detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                    color: UIColor.grayColor,
                    detail_color: UIColor.blackColor,
                }
              }
            ]
          },
          {
          title: I18n.t("WEATHER DATA"),
          footer: "Добавьте описание погоды. При наличии ключа доступа к meteodata API (задается в настройках приложения) данные могут быть загружены по нажатию на соответствующую кнопку.",
          cells: [
            {
              title:       'Погода',
              name: :weather,
              type: :selector_picker_view,
              required: true,
              value: @record ? @record.weather : 0,
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.grayColor,
                  detail_color: UIColor.blackColor
              },
              options: Hash[weather.each_with_index.map do |str, idx|
                            [idx, str]
                       end],
            },
            {
              title:       'Температура',
              name: :temperature,
              type: :selector_picker_view,
              required: true,
              value: @record ? @record.temperature : 15,
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.grayColor,
                  detail_color: UIColor.blackColor
              },
              options: Hash[(-30..40).map do |temp|
                            [temp, temp > 0 ? "+#{temp}" : temp.to_s]
                       end],
            },
            {
              title:       'Атомосферное давление, мм. рт. столба',
              name: :pressure,
              type: :integer,
              required: false,
              value: @record ? @record.pressure : 0,
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.grayColor,
                  detail_color: UIColor.blackColor,
                  alignment: :right
              }
            },
            {
              title:       'Направление ветра',
              name: :windDirection,
              type: :selector_picker_view,
              required: false,
              value: @record ? @record.windDirection : 0,
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.grayColor,
                  detail_color: UIColor.blackColor
              },
              options: Hash[wind_directions.each_with_index.map do |str, idx|
                            [idx, str]
                       end],
            },
            {
              title:       'Скорость ветра, м/с',
              name: :windSpeed,
              type: :integer,
              required: false,
              value: @record ? @record.windSpeed : 0,
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.grayColor,
                  detail_color: UIColor.blackColor,
                  alignment: :right
              }
            },
            {
              title: 'Загрузить',
              name: :click_me,
              type: :button,
              on_click: -> (cell) {
                @coordinates = value_for_cell(:coordinates)
                @date = value_for_cell(:fishingDate)
                unless NSUserDefaults.standardUserDefaults['meteostat_key'].blank?
                hud = JGProgressHUD.progressHUDWithStyle(JGProgressHUDStyleDark)
                  hud.textLabel.text = "Загрузка метеоданных"
                  hud.showInView(app.screen.view)
                  # https://api.meteostat.net/
                  unless $cache.has_key?("#{@coordinates.latitude.round(1)}-#{@coordinates.longitude.round(1)}")
                    AFMotion::JSON.get("https://api.meteostat.net/v1/stations/nearby?lat=#{@coordinates.latitude}&lon=#{@coordinates.longitude}&limit=1&key=#{NSUserDefaults.standardUserDefaults['meteostat_key']}") do |result|
                      if result.success?
                        $cache["#{@coordinates.latitude.round(1)}-#{@coordinates.longitude.round(1)}"] = result.object['data'][0]['id']
                        AFMotion::JSON.get("https://api.meteostat.net/v1/history/hourly?station=#{result.object['data'][0]['id']}&start=#{@date.strftime("%Y-%m-%d")}&end=#{@date.strftime("%Y-%m-%d")}&time_format=Y-m-d%20H:i&key=#{NSUserDefaults.standardUserDefaults['meteostat_key']}") do |result|
                          if result.success?
                            update_weather_date(result)
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
                    AFMotion::JSON.get("https://api.meteostat.net/v1/history/hourly?station=#{$cache["#{@coordinates.latitude.round(1)}-#{@coordinates.longitude.round(1)}"]}&start=#{@date.strftime("%Y-%m-%d")}&end=#{@date.strftime("%Y-%m-%d")}&time_format=Y-m-d%20H:i&key=#{NSUserDefaults.standardUserDefaults['meteostat_key']}") do |result|
                      if result.success?
                        update_weather_date(result)
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
          footer: 'Эта запись будет отображаться в разделе Трофеи',
          cells: [
            {
              title: "Добавить в трофеи",
              name: :isFavorite,
              type: :switch,
              value: @record ? @record.isFavorite : false
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
  
  def update_weather_date(result)
    result.object['data'].each do |res|
      if res['time'] == @date.strftime("%Y-%m-%d %H:00:00")
        if res['condition']
          row = self.form.formRowAtIndex(NSIndexPath.indexPathForRow(0,inSection: 5))
          weather =  Weather::CONDITIONS
          val = case res['condition']
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
        row.value = XLFormOptionsObject.alloc.initWithValue(res['temperature'].round.to_i, displayText: res['temperature'] ? "+#{res['temperature']}" : res['temperature'].to_s)
        self.reloadFormRow(row)
      
        row = self.form.formRowAtIndex(NSIndexPath.indexPathForRow(2,inSection: 5))
        row.value = res['pressure'] ? (res['pressure'] / 1.333).round.to_i : 740
        self.reloadFormRow(row)
      
        row = self.form.formRowAtIndex(NSIndexPath.indexPathForRow(3,inSection: 5))
        val = res['winddirection'] / 45
        wind_directions = Weather::WIND_DIRECTIONS
        row.value = XLFormOptionsObject.alloc.initWithValue(val.to_s, displayText: wind_directions[val])
        self.reloadFormRow(row)
      
        row = self.form.formRowAtIndex(NSIndexPath.indexPathForRow(4,inSection: 5))
        row.value = (res['windspeed'] / 3.6).round.to_i
        self.reloadFormRow(row)
      
        self.tableView.reloadData
      end
    end
  end
end