class StatScreen < PM::GroupedTableScreen
  title I18n.t("Statistics")
  
  def on_init
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(I18n.t("Statistics"), image:UIImage.imageNamed('pie-chart-24.png'), tag:4)
  end
  
  def on_load
    NSNotificationCenter.defaultCenter.addObserver(self, selector: "fishingChanged:", name: "reloadFishing", object: nil)
  end 
  
  def fishingChanged(notification)
    update_table_data
  end
  
  def table_data
    [
      { 
       title: I18n.t('YOUR FISHING'),
       cells: [
         { properties: { ftitle: I18n.t('TOTAL FISHING'), fsubtitle: Fishing.all.size.to_s }, cell_class: FishingShowCell },
         { properties: { ftitle: I18n.t('NUMBER OF TAILS, PCS'), fsubtitle: Fishing.sum(:fishAmount).to_s }, cell_class: FishingShowCell },
         { properties: { ftitle: I18n.t('TOTAL WEIGHT, KG'), fsubtitle: Fishing.sum(:fishWeight).round(2).to_s }, cell_class: FishingShowCell },
         { properties: { ftitle: I18n.t('DURATION, HOURS'), fsubtitle: Fishing.sum(:duration).to_s }, cell_class: FishingShowCell }
       ],
       footer: I18n.t('The statistics take into account all your records'),
      },
      { 
       title: I18n.t("TROPHIES"),
       footer: I18n.t('Mark trophies in fishing record'),
       cells: Fishing.where(:isFavorite).eq(true).sort_by(:fishingDate, order: :descending).map do |record|
         {
           properties: {
             ftitle: "#{record.fish}, #{record.fishWeight.round(2)} кг",
             fsubtitle: "#{record.place}, #{record.region}"
           },
           image: { 
             image: record.cropped_cover, 
             radius: 10,
             size: 40 
           },
           accessory_type: UITableViewCellAccessoryDisclosureIndicator,
           action: :favorite_clicked,
           arguments: { id: record.id },
           cell_class: FishingFavoriteCell
         } 
       end
      }, 
      { 
       title: I18n.t('CHARTS'),
       cells: [
         { properties: 
           { 
             ftitle: I18n.t('BY PHASE OF THE MOON'),
             records: Fishing.all 
           }, height: 300, cell_class: FishingPieChartCell 
         },
         { properties: 
           { 
             ftitle: I18n.t('BY WEATHER'),
             records: Fishing.all 
           }, height: 300, cell_class: FishingPieChartCell2 
         }
       ]
      }
    ]
  end
  
  def favorite_clicked(args)
    open ShowScreen.new(nav_bar: true, record: Fishing.where(:id).eq(args[:id]).first)
  end
end