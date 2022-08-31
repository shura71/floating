class FishingMap < PM::MapScreen
  def annotation_data
    [
      {
          longitude: @record.lon,
          latitude: @record.lat,
          title: "",
          pin_color: :green
      }
    ]
  end
  
  def record=(record)
    @record = record
  end
  
  def on_appear
    map.mapType = MKMapTypeHybrid
    map.zoomEnabled = true
    set_region region(coordinate: CLLocationCoordinate2DMake(@record.lat, @record.lon), span: [0.03, 0.03])
  end
end