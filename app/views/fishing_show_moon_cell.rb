class FishingShowMoonCell < PM::TableViewCell
  def ftitle=(place)
    @place_view ||= begin 
      label = add UILabel.alloc.initWithFrame([[ 15, 0 ], [ self.contentView.frame.size.width - 15 , 30 ]])
      label.font = UIFont.fontWithName("Helvetica", size:12)
      label.color = UIColor.lightGrayColor # beautiful
      label
    end
    @place_view.text = "#{place}"
    self.contentView.addSubview(@place_view)
  end
  
  def fsubtitle=(region)
    @region_view ||= begin 
      label = add UILabel.alloc.initWithFrame([[ 15, 14 ], [ self.contentView.frame.size.width - 15 , 30 ]])
      label.font = UIFont.fontWithName("Helvetica", size:15)
      label
    end
    @region_view.text = "#{region}"
    self.contentView.addSubview(@region_view)
  end
  
  def fimage=(image)
    @imageView ||= begin
      imageView = add UIImageView.alloc.initWithImage(image)
      imageView.frame = [[app.window.frame.size.width - 40, 5], [30, 30]]
      imageView
    end
    self.contentView.addSubview(@imageView)
  end
end