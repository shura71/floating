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
      @map.mapType = MKMapTypeHybrid
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
  
  def mapView(map_view, regionWillChangeAnimated:animated)
    if @annotation
      @annotation.coordinate = @map.centerCoordinate
      rowDescriptor.value = CLLocationCoordinate2DMake(@annotation.coordinate.latitude,@annotation.coordinate.longitude)
    end
  end
  
  def mapView(map_view, regionDidChangeAnimated:animated)
    if @annotation
      @annotation.coordinate = @map.centerCoordinate
      rowDescriptor.value = CLLocationCoordinate2DMake(@annotation.coordinate.latitude,@annotation.coordinate.longitude)
    end
  end
end

class CLLocationValueTrasformer < PM::ValueTransformer
  def transformed_value(value)
      return nil if value.nil?
      
      sprintf("%0.4f, %0.4f", value.latitude, value.longitude)
  end
end