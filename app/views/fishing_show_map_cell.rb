class FishingShowMapCell < PM::TableViewCell
  def coordinates=(coordinates)
    # https://stackoverflow.com/questions/31354428/mkmapview-change-annotation-image
    @map = MKMapView.alloc.initWithFrame([[ 0, 0 ], [ 100 , 50 ]])
    @map.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    @map.mapType = MKMapTypeHybrid
    @map.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2D.new(coordinates[0], coordinates[1]), MKCoordinateSpanMake(0.5, 0.5)), animated:true)
    @map.zoomEnabled = false
    @map.scrollEnabled = false
    @map.userInteractionEnabled = false
    @map.delegate = self
    @annotation = ProMotion::MapScreenAnnotation.new({latitude: coordinates[0], longitude: coordinates[1], pin_color: :green, title: ''})
    @map.addAnnotation(@annotation)
    self.contentView.addSubview(@map)
    @place_view ||= begin 
      label = add UILabel.alloc.initWithFrame([[ 140, 5 ], [ self.contentView.frame.size.width - 130 , 40 ]])
      label.font = UIFont.fontWithName("Helvetica", size:12)
      label.color = UIColor.lightGrayColor 
      label.numberOfLines = 0
      label
    end
    cllocation = CLLocation.alloc.initWithLatitude(coordinates[0], longitude:coordinates[1])
    onReverseGeocode = Proc.new do |placemarks, error|
      unless error
        placemark = placemarks.lastObject
        @place_view.text = placemark.addressDictionary["FormattedAddressLines"].join(', ')
      end
    end
    CLGeocoder.new.reverseGeocodeLocation(cllocation, preferredLocale: NSLocale.localeWithLocaleIdentifier(I18n.locale), completionHandler: onReverseGeocode)
    self.contentView.addSubview(@place_view)
  end
end