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
    weather = ['Ясно','Облачно','Пасмурно','Дождь','Снег','Tуман','Метель','Ветер']
    wind_directions = {
      '0'  => "Cеверный",
      '45' => "Cеверо-восточный",
      '90' => "Восточный",
      '135' => "Юго-восточный",
      '180' => "Южный",
      '215' => "Юго-западный",
      '270' =>  "Западный",
      '315' => "Северо-западный"
    }
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
              value: @record ? @record.temperature : 0,
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
              value: @record ? @record.pressure : '',
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
              value: @record ? @record.windDirection : '0',
              appearance: {
                  font: UIFont.fontWithName('Helvetica', size: 12.0),
                  detail_font: UIFont.fontWithName('Helvetica', size: 12.0),
                  color: UIColor.grayColor,
                  detail_color: UIColor.blackColor
              },
              options: Hash[wind_directions.keys.map do |key|
                            [key, wind_directions[key]]
                       end],
            },
            {
              title:       'Скорость ветра, м/с',
              name: :windSpeed,
              type: :integer,
              required: false,
              value: @record ? @record.windSpeed : '',
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
                unless NSUserDefaults.standardUserDefaults["meteostat_key"].blank?
                  hud = JGProgressHUD.progressHUDWithStyle(JGProgressHUDStyleDark)
                  hud.textLabel.text = "Загрузка метеоданных"
                  hud.showInView(app.screen.view)
                  row = self.form.formRowAtIndex(NSIndexPath.indexPathForRow(2,inSection: 5))
                  row.value = 740
                  self.reloadFormRow(row)
                  hud.dismiss
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
    mp values
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
        cover: UIImageJPEGRepresentation(values['images'][0], 1),
        images: NSKeyedArchiver.archivedDataWithRootObject(values['images'].map {|img| UIImageJPEGRepresentation(img, 1)})
      )
    end
    cdq.save
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
end

class NotesController < ProMotion::XLFormViewController 
  attr_accessor :rowDescriptor
  
  def viewDidLoad    
    text_view = UITextView.new
    text_view.delegate = self
    text_view.backgroundColor = UIColor.whiteColor
    text_view.frame = CGRectMake(
      0,
      0,
      self.view.bounds.size.width,
      self.view.bounds.size.height
    )
    text_view.font = UIFont.fontWithName("Helvetica", size:15)
    
    text_view.text = rowDescriptor.value
    self.view.addSubview(text_view)
  end
  
  def textViewDidChange(textView)
    rowDescriptor.value = textView.text
  end
end

class MapController < ProMotion::XLFormViewController  
  PIN_COLORS = {
        red: MKPinAnnotationColorRed,
        green: MKPinAnnotationColorGreen,
        purple: MKPinAnnotationColorPurple
  }
  
  attr_accessor :rowDescriptor
  
  def viewDidLoad
      self.title = "Карта"
      @map = MKMapView.alloc.initWithFrame(self.view.bounds)
      @map.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      @map.mapType = MKMapTypeSatellite
      @map.showsUserLocation = true
      @map.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2D.new(rowDescriptor.value.latitude, rowDescriptor.value.longitude), MKCoordinateSpanMake(0.5, 0.5)), animated:true)
      self.view.addSubview(@map)  
      @map.delegate = self
      unless rowDescriptor.value.nil?
        @map.setCenterCoordinate(rowDescriptor.value)
        self.title = sprintf("%0.4f, %0.4f", rowDescriptor.value.latitude, rowDescriptor.value.longitude)
        @annotation = ProMotion::MapScreenAnnotation.new({
          latitude: rowDescriptor.value.latitude, 
          longitude: rowDescriptor.value.longitude, 
          title: '',
          pin_color: :green
        })
        @map.addAnnotation(@annotation)
      end
  end
  
  def mapView(map_view, viewForAnnotation:annotation)
    return if (annotation.is_a? MKUserLocation) 
    params = annotation.params
    identifier = params[:identifier]
    if view = map_view.dequeueReusableAnnotationViewWithIdentifier(identifier)
      view.annotation = annotation
    else
      # Set the pin properties
      if params[:image]
        view = MKAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:identifier)
      else
        view = MKPinAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:identifier)
      end
    end
    view.image = params[:image] if view.respond_to?("image=") && params[:image]
    view.animatesDrop = params[:animates_drop] if view.respond_to?("animatesDrop=")
    view.draggable = true
    view.pinColor = (PIN_COLORS[params[:pin_color]] || params[:pin_color]) if view.respond_to?("pinColor=")
    view.canShowCallout = params[:show_callout] if view.respond_to?("canShowCallout=")

    view
  end
  
  def mapView(map_view, annotationView:view, didChangeDragState:newState, fromOldState:oldState)
    if newState == MKAnnotationViewDragStateEnding
      rowDescriptor.value = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude,view.annotation.coordinate.longitude)
      # self.title = sprintf("%0.4f, %0.4f", view.annotation.coordinate.latitude,view.annotation.coordinate.longitude)
    end
  end
end

class CLLocationValueTrasformer < PM::ValueTransformer
  def transformed_value(value)
      return nil if value.nil?
      
      sprintf("%0.4f, %0.4f", value.latitude, value.longitude)
  end
end