class CalendarScreen < PM::Screen
  title I18n.t("Calendar")
  
  nav_bar_button :right, system_item: :add, style: :plain, action: :add_new_record, tint_color: UIColor.blackColor
  
  def on_init
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(I18n.t("Calendar"), image:UIImage.imageNamed('calendar-24.png'), tag:2)
    @fishings = []
  end
  
  def on_load
      @dates = {}
      Fishing.all.each do |fishing|
        key = fishing.fishingDate.strftime("%Y-%m-%d")
        if @dates.has_key?(key)
          @dates[key] << fishing.id
        else
          @dates[key] = [fishing.id]
        end
      end
      calendar = FSCalendar.alloc.initWithFrame(CGRectMake(10, 55, self.view.width - 20, self.view.height / 2))
      calendar.dataSource = self
      calendar.delegate = self
      calendar.backgroundColor = UIColor.whiteColor
      calendar.appearance.headerTitleColor = UIColor.blackColor
      calendar.appearance.weekdayTextColor = UIColor.blackColor
      calendar.appearance.todayColor = UIColor.blackColor
      self.view.addSubview(calendar)
      @myTableView = UITableView.alloc.initWithFrame(CGRectMake(0, self.view.height / 2 + 65, self.view.width, self.view.height / 2 - 40), style:UITableViewStylePlain)
      @myTableView.dataSource = self
      @myTableView.delegate = self
      self.view.addSubview(@myTableView)
  end
  
  def load_view
    self.view = UIView.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    self.view.backgroundColor = UIColor.whiteColor
  end
  
  def calendar(calendar, numberOfEventsForDate:date)
    if @dates.has_key?(date.strftime("%Y-%m-%d"))
      @dates[date.strftime("%Y-%m-%d")].size
    else
      0
    end
  end
  
  def calendar(calendar, appearance:appearance, eventDefaultColorsForDate:date)
      # appearance.eventDefaultColor
      [UIColor.lightGrayColor,UIColor.lightGrayColor,UIColor.blackColor]
  end
  
  def calendar(calendar, appearance:appearance, fillDefaultColorForDate:date)
    if @dates.has_key?(date.strftime("%Y-%m-%d"))
      UIColor.lightGrayColor.with(a: 0.25)
    else
      nil
    end
  end
  
  def calendar(calendar, didSelectDate:date, atMonthPosition:monthPosition)
    @fishings = []
    if @dates.has_key?(date.strftime("%Y-%m-%d"))
      Fishing.where(:id).in(@dates[date.strftime("%Y-%m-%d")]).each {|rec| @fishings << rec }
    end
    @myTableView.reloadData
  end
  
  def tableView(tableView, numberOfRowsInSection:section)
    @fishings.size
  end
   
   def tableView(tableView, cellForRowAtIndexPath:indexPath)
     @reuseIdentifier ||= "CELL_IDENTIFIER"
     cell = tableView.dequeueReusableCellWithIdentifier (@reuseIdentifier) || begin
         UITableViewCell.alloc.initWithStyle (UITableViewCellStyleSubtitle, reuseIdentifier: @reuseIdentifier)
     end
     cell.textLabel.text = "#{@fishings[indexPath.row].fish}, #{@fishings[indexPath.row].fishWeight.round(2)}кг"
     cell.textLabel.font = UIFont.fontWithName("Helvetica", size:15)
     cell.detailTextLabel.text = "#{@fishings[indexPath.row].place}, #{@fishings[indexPath.row].region}"
     cell.detailTextLabel.color = UIColor.lightGrayColor
     cell.detailTextLabel.font = UIFont.fontWithName("Helvetica", size:12)
     cell.imageView.image = @fishings[indexPath.row].cropped_cover
     cell.imageView.layer.setCornerRadius(10)
     cell.imageView.layer.setMasksToBounds(true)
     cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
     cell
   end
   
   def tableView(tableView, heightForRowAt:indexPath)
     44.0
   end
   
   def tableView(tableView, didSelectRowAtIndexPath:indexPath) 
     weather = ['Ясно','Облачно','Пасмурно','Дождь','Снег','Tуман','Метель','Ветер']
     
     fishing = @fishings[indexPath.row]
     controller = UIViewController.new
     controller.title = fishing.fishingDate.strftime("%d.%m.%Y %H:%M")
     windowRect = self.view.window.frame
     controller.contentSizeInPopup = CGSizeMake(windowRect.size.width, 400)
     
     # item = UIBarButtonItem.alloc.initWithTitle(title, style: UIBarButtonItemStylePlain,  target: Proc.new { App.alert('One') } ,action: :call)
     
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
     
     #navitem = UINavigationItem.alloc.initWithTitle("Test")
     #navitem.rightBarButtonItem = item
     #navitem.hidesBackButton = true
     #popupController.navigationBar.pushNavigationItem(navitem, animated: false);
     #popupController.navigationBarHidden = true
     
     @myTableView.deselectRowAtIndexPath(indexPath, animated: true)
   end
   
   def numberOfItems
     @slides.size
   end
   
   def imagePlayerView(imagePlayerView, loadImageForImageView:imageView, index:index)
     windowRect = self.view.window.frame
     imageView.image = crop_to_size(@slides[index], [ windowRect.size.width , 260 ])
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
   
   def add_new_record
     open EditScreen.new(nav_bar: true)
   end
end