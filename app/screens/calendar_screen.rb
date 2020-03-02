class CalendarScreen < PM::Screen
  title I18n.t("Calendar")
  
  nav_bar_button :right, system_item: :add, style: :plain, action: :add_new_record, tint_color: UIColor.blackColor
  
  def on_init
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(I18n.t("Calendar"), image:UIImage.imageNamed('calendar-24.png'), tag:2)
    @fishings = []
  end
    
  def fishingChanged(notification)
    @dates = {}
    Fishing.all.each do |fishing|
      key = fishing.fishingDate.strftime("%Y-%m-%d")
      if @dates.has_key?(key)
        @dates[key] << fishing.id
      else
        @dates[key] = [fishing.id]
      end
    end
    @calendar.reloadData
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
      NSNotificationCenter.defaultCenter.addObserver(self, selector: "fishingChanged:", name: "reloadFishing", object: nil)
      @calendar = FSCalendar.alloc.initWithFrame(CGRectMake(10, 55, self.view.width - 20, self.view.height / 2))
      @calendar.dataSource = self
      @calendar.delegate = self
      @calendar.backgroundColor = UIColor.whiteColor
      @calendar.firstWeekday = 2
      @calendar.appearance.headerTitleColor = UIColor.blackColor
      @calendar.appearance.weekdayTextColor = UIColor.blackColor
      @calendar.appearance.todayColor = UIColor.blackColor
      self.view.addSubview(@calendar)
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
     cell.textLabel.text = "#{@fishings[indexPath.row].fish}, #{@fishings[indexPath.row].fishWeight.round(2)} кг"
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
     fishing = @fishings[indexPath.row]
     
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
     
     @myTableView.deselectRowAtIndexPath(indexPath, animated: true)
  end
   
  def add_new_record
     open EditScreen.new(nav_bar: true)
   end
end