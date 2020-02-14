class FishingFavoriteCell < PM::TableViewCell
  def ftitle=(place)
    @place_view ||= begin 
      label = add UILabel.alloc.initWithFrame([[ 75, 3 ], [ self.contentView.frame.size.width - 75 , 20 ]])
      label.font = UIFont.fontWithName("Helvetica", size:15)
      label
    end
    @place_view.text = "#{place}"
    self.contentView.addSubview(@place_view)
  end
  
  def fsubtitle=(region)
    @region_view ||= begin 
      label = add UILabel.alloc.initWithFrame([[ 75, 21 ], [ self.contentView.frame.size.width - 75 , 20 ]])
      label.font = UIFont.fontWithName("Helvetica", size:12)
      label.color = UIColor.lightGrayColor # beautiful
      label
    end
    @region_view.text = "#{region}"
    self.contentView.addSubview(@region_view)
  end
end