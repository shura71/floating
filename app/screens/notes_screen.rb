class NotesScreen < PM::Screen
  title 'Описание'
  
  def will_appear
    @view_setup ||= set_up_view
  end

  def set_up_view
    set_attributes self.view, {
      background_color: UIColor.whiteColor
    }
    
    @place_view ||= begin 
      label = add UILabel.alloc.initWithFrame([[ 10, 70 ], [ self.view.width - 20, self.view.height - 20  ]])
      label.font = UIFont.fontWithName("Helvetica", size:15)
      label.numberOfLines = 0
      label
    end
    
    @place_view.text = @record.notes
    @place_view.sizeToFit
    self.view.addSubview(@place_view)

    true
  end
  
  def record=(record)
    @record = record
  end
end