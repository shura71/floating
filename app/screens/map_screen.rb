class MapScreen < PM::MapScreen
  title I18n.t("Map")
  
  def on_init
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(I18n.t("Map"), image:UIImage.imageNamed('world-24.png'), tag:3)
  end
  
  def on_appear
    map.mapType = MKMapTypeSatellite
    map.zoomEnabled = true
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
    weather = ['Ясно','Облачно','Пасмурно','Дождь','Снег','Tуман','Метель','Ветер']
    
    fishing = Fishing.where(:id).eq(selected_annotations.first.id).first
    controller = UIViewController.new
    controller.title = fishing.fishingDate.strftime("%d.%m.%Y %H:%M")
    windowRect = self.view.window.frame
    controller.contentSizeInPopup = CGSizeMake(windowRect.size.width, 400)
    
    @slides = []
    images = NSKeyedUnarchiver.unarchiveObjectWithData(fishing.images)
    imageView = UIImageView.alloc.initWithImage(crop(images[0]))
    images.each do |image|
      @slides << UIImage.imageWithData(image)
    end
    imageView.frame = [[15, 5], [70, 70]]
    imageView.layer.setCornerRadius(10)
    imageView.layer.setMasksToBounds(true)
    controller.view.addSubview(imageView) 
    
    label = UILabel.alloc.initWithFrame([[ 100, 6 ], [ windowRect.size.width - 105 , 30 ]])
    label.font = UIFont.fontWithName("Helvetica-Bold", size:18)
    label.color = UIColor.blackColor 
    label.baselineAdjustment = UIBaselineAdjustmentAlignCenters
    label.text = "#{fishing.fish}, #{fishing.fishWeight.round(2)} кг"
    controller.view.addSubview(label) 
    
    label = UILabel.alloc.initWithFrame([[ 100, 30 ], [ windowRect.size.width - 105 , 30 ]])
    label.font = UIFont.fontWithName("Helvetica", size:15)
    label.color = UIColor.blackColor 
    label.text = "#{fishing.place}, #{fishing.region}"
    controller.view.addSubview(label) 
    
    imageView1 = UIImageView.alloc.initWithImage(UIImage.imageNamed("lure-50.png"))
    imageView1.frame = [[15, 85], [24, 24]]
    controller.view.addSubview(imageView1) 
    
    label = UILabel.alloc.initWithFrame([[ 15, 105 ], [ windowRect.size.width / 3 - 30 , 30 ]])
    label.font = UIFont.fontWithName("Helvetica", size:15)
    label.color = UIColor.blackColor 
    label.baselineAdjustment = UIBaselineAdjustmentAlignCenters
    label.text = fishing.bait
    controller.view.addSubview(label) 

    imageView2 = UIImageView.alloc.initWithImage(UIImage.imageNamed("fish-48.png"))
    imageView2.frame = [[35 + windowRect.size.width / 3, 85], [24, 24]]
    controller.view.addSubview(imageView2) 
    
    label = UILabel.alloc.initWithFrame([[ 35 + windowRect.size.width / 3, 105 ], [ windowRect.size.width / 3 - 30 , 30 ]])
    label.font = UIFont.fontWithName("Helvetica", size:15)
    label.color = UIColor.blackColor 
    label.baselineAdjustment = UIBaselineAdjustmentAlignCenters
    label.text = fishing.fishAmount.to_s
    controller.view.addSubview(label) 
    
    imageView3 = UIImageView.alloc.initWithImage(UIImage.imageNamed("weather-50.png"))
    imageView3.frame = [[windowRect.size.width / 3 * 2, 85], [24, 24]]
    controller.view.addSubview(imageView3) 
    
    label = UILabel.alloc.initWithFrame([[ windowRect.size.width / 3 * 2, 105 ], [ windowRect.size.width / 3 , 30 ]])
    label.font = UIFont.fontWithName("Helvetica", size:15)
    label.color = UIColor.blackColor 
    label.baselineAdjustment = UIBaselineAdjustmentAlignCenters
    label.text = "#{weather[fishing.weather]} #{fishing.temperature > 0 ? '+' : ''}#{fishing.temperature} °С"
    controller.view.addSubview(label) 
    
    imagePlayer = ImagePlayerView.alloc.initWithFrame([[ 0, 140 ], [ windowRect.size.width , 260 ]]) 
    imagePlayer.imagePlayerViewDelegate = self
    imagePlayer.scrollInterval = 0
    imagePlayer.pageControlPosition = ICPageControlPosition_BottomCenter
    imagePlayer.hidePageControl = true if @slides.size == 1
    imagePlayer.reloadData
    controller.view.addSubview(imagePlayer) 
    
    popupController = STPopupController.alloc.initWithRootViewController(controller)
    popupController.style = STPopupStyleBottomSheet
    popupController.containerView.layer.cornerRadius = 5
    popupController.presentInViewController(self)
  end
  
  def crop(original_image)
    image = UIImage.imageWithData(original_image)
   
    imageHeight = image.size.height
    imageWidth = image.size.width
   
    if imageHeight > imageWidth 
      imageHeight = imageWidth
    else
      imageWidth = imageHeight
    end

    size = CGSize.new(imageWidth, imageHeight)
    x = (image.size.width - size.width) / 2
    y = (image.size.height - size.height) / 2
   
    cropRect = CGRect.new([x, y], [size.height, size.width])
   
    image.crop(cropRect)
  end
  
  def crop_to_size(image, size)
    scaleFactor = 1.0
    scaledWidth = size[0]
    scaledHeight = size[1]
    thumbnailPoint = CGPointMake(0, 0)

    widthFactor = size[0] / image.size.width
    heightFactor = size[1] / image.size.height

    if widthFactor > heightFactor 
       scaleFactor = widthFactor
    else 
       scaleFactor = heightFactor
   end

   scaledWidth = image.size.width * scaleFactor
   scaledHeight = image.size.height * scaleFactor

   if widthFactor > heightFactor 
     thumbnailPoint.y = (size[1] - scaledHeight) * 0.5
   elsif widthFactor < heightFactor 
     thumbnailPoint.x = (size[0]- scaledWidth) * 0.5
   end
      
   UIGraphicsBeginImageContextWithOptions(size, true, 0)

   thumbnailRect = CGRectZero
   thumbnailRect.origin = thumbnailPoint
   thumbnailRect.size.width = scaledWidth
   thumbnailRect.size.height = scaledHeight

   image.drawInRect(thumbnailRect)
   returnImage = UIGraphicsGetImageFromCurrentImageContext()

   UIGraphicsEndImageContext()

   returnImage
  end
  
  def numberOfItems
    @slides.size
  end
  
  def imagePlayerView(imagePlayerView, loadImageForImageView:imageView, index:index)
    windowRect = self.view.window.frame
    imageView.image = crop_to_size(@slides[index], [ windowRect.size.width , 260 ])
  end
end