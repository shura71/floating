class MapScreen < PM::MapScreen
  title I18n.t("Map")
  nav_bar (Device.ios_version.to_i < 15) 
  
  def on_init
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(I18n.t("Map"), image:UIImage.imageNamed('world-24.png'), tag:3)
  end
  
  def on_appear
    map.mapType = MKMapTypeHybrid
    map.zoomEnabled = true
    show_user_location
  end

  def on_load
    NSNotificationCenter.defaultCenter.addObserver(self, selector: "fishingChanged:", name: "reloadFishing", object: nil)
  end 
  
  def fishingChanged(notification)
    update_annotation_data
  end
  
  def annotation_data
    @data ||= Fishing.all.map do |fishing|
      {
        longitude: fishing.lon,
        latitude: fishing.lat,
        title: "#{fishing.place}, #{fishing.region}",
        subtitle: fishing.fishingDate.strftime("%d.%m.%Y %H:%M"),
        action: :pin_clicked, 
        id: fishing.id
      }
    end
    @data
  end
  
  def pin_clicked
    fishing = Fishing.where(:id).eq(selected_annotations.first.id).first
    
    controller = BottomSheetController.new
    controller.title = fishing.fishingDate.strftime("%d.%m.%Y %H:%M")
    controller.fishing = fishing
    controller.root_controller = self
    windowRect = self.view.window.frame
    controller.contentSizeInPopup = CGSizeMake(windowRect.size.width, 400)
    
    popupController = STPopupController.alloc.initWithRootViewController(controller)
    popupController.style = STPopupStyleBottomSheet
    popupController.containerView.layer.cornerRadius = 5
    popupController.presentInViewController(self)
  end
end