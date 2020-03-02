class NotesController < ProMotion::XLFormViewController
  attr_accessor :rowDescriptor
  
  def viewDidLoad    
    text_view = UITextView.new
    text_view.delegate = self
    text_view.backgroundColor = UIColor.whiteColor
    text_view.frame = CGRectMake(
      0,
      0,
      self.view.bounds.size.width,
      self.view.bounds.size.height
    )
    text_view.font = UIFont.fontWithName("Helvetica", size:15)
    
    text_view.text = rowDescriptor.value
    self.view.addSubview(text_view)
  end
  
  def textViewDidChange(textView)
    rowDescriptor.value = textView.text
  end
end