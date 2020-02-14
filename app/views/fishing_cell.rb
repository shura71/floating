class FishingCell < PM::TableViewCell
  def month_year=(year)
      # Make the UILabel, but *only* if it doesn't exist yet.
      @year_released_view ||= begin
        label = add UILabel.alloc.initWithFrame([[ self.contentView.frame.size.width - 2, 2 ], [ 50, 20 ]])
        label.font = UIFont.fontWithName("Helvetica-Bold", size:12)
        label.backgroundColor = UIColor.lightGrayColor # beautiful
        label.color = UIColor.whiteColor # beautiful
        label.textAlignment = UITextAlignmentCenter
        label
      end
      # Now set the label text, regardless of if it's a new cell
      # or an old one, freshly dequeued.
      @year_released_view.text = "#{year}"
      self.contentView.addSubview(@year_released_view)
    end

    def day=(price)
      @price_view ||= begin 
        label = add UILabel.alloc.initWithFrame([[ self.contentView.frame.size.width - 2, 22 ], [ 50, 30 ]])
        label.font = UIFont.fontWithName("Helvetica-Bold", size:24)
        label.color = UIColor.lightGrayColor # beautiful
        label.textAlignment = UITextAlignmentCenter
        label
      end
      @price_view.text = "#{price}"
      self.contentView.addSubview(@price_view)
    end
  
    def fish=(fish)
      @fish_view ||= begin 
        label = add UILabel.alloc.initWithFrame([[ 112, 39 ], [ self.contentView.frame.size.width - 80 , 30 ]])
        label.font = UIFont.fontWithName("Helvetica", size:15)
        label
      end
      @fish_view.text = "#{fish}"
      self.contentView.addSubview(@fish_view)
    end
    
    def fish_weight=(weight)
      @fish_weight_view ||= begin 
        label = add UILabel.alloc.initWithFrame([[ 112, 56 ], [ self.contentView.frame.size.width - 130 , 30 ]])
        label.font = UIFont.fontWithName("Helvetica", size:12)
        label.color = UIColor.lightGrayColor # beautiful
        label
      end
      @fish_weight_view.text = "Улов #{weight} кг"
      self.contentView.addSubview(@fish_weight_view)
    end
    
    def place=(place)
      @place_view ||= begin 
        label = add UILabel.alloc.initWithFrame([[ 112, 2 ], [ self.contentView.frame.size.width - 130 , 30 ]])
        label.font = UIFont.fontWithName("Helvetica", size:15)
        label
      end
      @place_view.text = "#{place}"
      self.contentView.addSubview(@place_view)
    end
    
    def region=(region)
      @region_view ||= begin 
        label = add UILabel.alloc.initWithFrame([[ 112, 19 ], [ self.contentView.frame.size.width - 130 , 30 ]])
        label.font = UIFont.fontWithName("Helvetica", size:12)
        label.color = UIColor.lightGrayColor # beautiful
        label
      end
      @region_view.text = "#{region}"
      self.contentView.addSubview(@region_view)
    end
end
