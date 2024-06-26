class ShowScreen < PM::GroupedTableScreen
  def on_init
    set_nav_bar_buttons :right, [
      {system_item: :edit, style: :plain, action: :edit_record, tint_color: UIColor.labelColor}, 
      {system_item: :action, style: :plain, action: :share_record, tint_color: UIColor.labelColor}
    ]
  end
  
  def table_data
    weather = Weather::CONDITIONS
    moon_phases = Weather::MOON_PHASES
    wind_directions = Weather::WIND_DIRECTIONS
    fishing_data = [
        { 
         title: I18n.t("PHOTOS"),
         cells: [
           { properties: { fimages: NSKeyedUnarchiver.unarchiveObjectWithData(@record.images)}, height: 120, cell_class: FishingShowImagesCell }
         ]
        } ,
        {
        title: I18n.t("DATE AND TIME"),
        cells: [
          { properties: { ftitle: I18n.t('Fishing date'), fsubtitle: @record.fishingDate.strftime('%Y-%m-%d %H:%M')}, cell_class: FishingShowCell },
          { properties: { ftitle: I18n.t('Duration, hours'), fsubtitle: @record.duration.to_s}, cell_class: FishingShowCell },
        ]
        },
        {
        title: I18n.t("LOCATION"),
        cells: [
          { properties: { ftitle: I18n.t('Fishing place'), fsubtitle: @record.place}, cell_class: FishingShowCell },
          { properties: { ftitle: I18n.t('Region'), fsubtitle: @record.region}, cell_class: FishingShowCell },
        ]
        },
        {
        title: I18n.t("CATCH"),
        cells: [
          { properties: { ftitle: I18n.t('Fish'), fsubtitle: @record.fish}, cell_class: FishingShowCell },
          { properties: { ftitle: I18n.t('Bait'), fsubtitle: @record.bait}, cell_class: FishingShowCell },
          { properties: { ftitle: I18n.t('Quantity, pcs'), fsubtitle: @record.fishAmount.to_s}, cell_class: FishingShowCell },
          { properties: { ftitle: I18n.t('Weight, lb'), fsubtitle: @record.fishWeight.round(2).to_s}, cell_class: FishingShowCell },
          { 
            properties: { 
              ftitle: I18n.t('Description'), 
              fsubtitle: @record.notes
            }, 
            cell_class: FishingShowCell,
            accessory_type: UITableViewCellAccessoryDisclosureIndicator,
            action: :notes_clicked
         }
        ]
        },
        {
        title: I18n.t("WEATHER DATA"),
        cells: [
          { 
            properties: { 
              ftitle: I18n.t('Weather'), 
              fsubtitle: "#{weather[@record.weather]} #{@record.temperature > 0 ? '+' : ''}#{@record.temperature} °С"
            }, 
            cell_class: FishingShowCell,
            accessory_type: UITableViewCellAccessoryNone
          },
          { 
            properties: { 
              ftitle: I18n.t('Wind'), 
              fsubtitle: @record.windSpeed  > 0 ? "#{wind_directions[@record.windDirection]}, #{@record.windSpeed.to_i} #{I18n.t('m/s')}" : '-'
            }, 
            cell_class: FishingShowCell,
            accessory_type: UITableViewCellAccessoryNone
          },
          { 
            properties: { 
              ftitle: I18n.t('Pressure, hg mm'), 
              fsubtitle: "#{@record.pressure > 0 ? @record.pressure : '-'}"
            }, 
            cell_class: FishingShowCell,
            accessory_type: UITableViewCellAccessoryNone
          },
          { 
            # TODO: calculate illumination
            properties: { 
              ftitle: I18n.t('Moon'), 
              fsubtitle: moon_phases[@record.moonPhase],
              fimage: UIImage.imageNamed("phases-0#{ @record.moonPhase }.png")
            }, 
            cell_class: FishingShowMoonCell,
            accessory_type: UITableViewCellAccessoryNone
          }
        ]
        },
        { 
        title: I18n.t("LOCATION MAP"),
        cells: [
          {
            properties: {
              coordinates: [@record.lat, @record.lon]
            }, 
            cell_class: FishingShowMapCell, 
            height: 50, 
            accessory_type: UITableViewCellAccessoryDisclosureIndicator,
            action: :map_clicked
          }
        ]
        },
        {      
        title: I18n.t("TROPHIES"),
        cells: [
          {
            title: I18n.t('Add to trophies'),
            accessory: {
              view: :switch,
              value: (@record.isFavorite == 1),
              action: :switched
            }
          }
        ]
      }
    ]
  end
      
  def switched()
    f = Fishing.where(:id).eq(@record.id).first
    f.isFavorite = (f.isFavorite == 0)
    NSNotificationCenter.defaultCenter.postNotificationName("reloadFishing", object: nil)
    cdq.save 
  end
  
  def photo_clicked
    images = NSKeyedUnarchiver.unarchiveObjectWithData(@record.images)
    MotionImager.new({
      image: UIImage.imageWithData(images[0]),
      presenting_from: WeakRef.new(self),
    }).show
  end
  
  def map_clicked
    open FishingMap.new(nav_bar: true, record: @record)
  end
  
  def notes_clicked
    open NotesScreen.new(nav_bar: true, record: @record)
  end
  
  def edit_record
    open EditScreen.new(nav_bar: true, record: @record)
  end
  
  def screenshot
    window = UIApplication.sharedApplication.keyWindow
    UIGraphicsBeginImageContextWithOptions(
      window.bounds.size,
      false,
      UIScreen.mainScreen.scale
    )
    window.drawViewHierarchyInRect(
      window.bounds,
      afterScreenUpdates:true
    )
    image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    image
  end
    
  def share_record
    tc_share_text = ShareText.alloc.init
    tc_share_text.text = "#{I18n.t("Fishing")}. #{@record.place}, #{@record.region}. [#{@record.lat}, #{@record.lon}]"
    controller = UIActivityViewController.alloc.initWithActivityItems(
      [tc_share_text, @record.cropped_cover],
      applicationActivities: nil
    )

    controller.excludedActivityTypes = [
      UIActivityTypePrint,
      UIActivityTypeAssignToContact,
      UIActivityTypeAddToReadingList,
      UIActivityTypePostToFlickr,
      UIActivityTypeAirDrop
    ]

    self.presentViewController(
      controller,
      animated:true,
      completion:nil
    )
  end
  
  def record=(record)
    @record = record
  end
    
  def will_appear
    if @record
      @record = Fishing.where(:id).eq(@record.id).first
      update_table_data
    end
  end
end