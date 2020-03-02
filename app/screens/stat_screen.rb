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
       title: I18n.t("ВАШИ РЫБАЛКИ"),
       cells: [
         { properties: { ftitle: 'ВСЕГО РЫБАЛОК', fsubtitle: Fishing.all.size.to_s }, cell_class: FishingShowCell },
         { properties: { ftitle: 'КОЛИЧЕСТВО ХВОСТОВ, ШТ', fsubtitle: Fishing.sum(:fishAmount).to_s }, cell_class: FishingShowCell },
         { properties: { ftitle: 'ОБЩИЙ ВЕС, КГ', fsubtitle: Fishing.sum(:fishWeight).round(2).to_s }, cell_class: FishingShowCell },
         { properties: { ftitle: 'ПРОДОЛЖИТЕЛЬНОСТЬ, ЧАСОВ', fsubtitle: Fishing.sum(:duration).to_s }, cell_class: FishingShowCell },
         { properties: 
           { 
             ftitle: 'ПО ФАЗАМ ЛУНЫ',
             records: Fishing.all 
           }, height: 300, cell_class: FishingPieChartCell 
         }
       ],
       footer: "В статистике учитываются все Ваши записи",
      },
      { 
       title: I18n.t("ТРОФЕИ"),
       footer: "Отметьте трофеи в записи о рыбалке",
       cells: Fishing.where(:isFavorite).eq(true).sort_by(:fishingDate, order: :descending).map do |record|
         {
           properties: {
             ftitle: "#{record.fish}, #{record.fishWeight.round(2)} кг",
             fsubtitle: "#{record.place}, #{record.region}"
           },
           image: { image: record.cropped_cover, radius: 10 },
           accessory_type: UITableViewCellAccessoryDisclosureIndicator,
           action: :favorite_clicked,
           arguments: { id: record.id },
           cell_class: FishingFavoriteCell
         } 
       end
      } 
    ]
  end
  
  def favorite_clicked(args)
    open ShowScreen.new(nav_bar: true, record: Fishing.where(:id).eq(args[:id]).first)
  end
end