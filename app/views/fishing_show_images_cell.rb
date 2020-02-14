class FishingShowImagesCell < PM::TableViewCell
  def crop(original_image)
    image = UIImage.imageWithData(original_image)
    
    imageHeight = image.size.height
    imageWidth = image.size.width
    
    if imageHeight > imageWidth 
      imageHeight = imageWidth
    else
      imageWidth = imageHeight
    end

    size = CGSize.new(imageWidth, imageHeight)
    x = (image.size.width - size.width) / 2
    y = (image.size.height - size.height) / 2
    
    cropRect = CGRect.new([x, y], [size.height, size.width])
    
    image.crop(cropRect)
  end
  
  def fimages=(images)
    @scrollView = UIScrollView.alloc.init
    @scrollView.frame = CGRectMake(0, 0, app.window.frame.size.width, 120)
    @scrollView.showsHorizontalScrollIndicator = true
    @scrollView.contentSize = CGSizeMake(15 + 125 * images.size, @scrollView.frame.size.height)
    @images = images
    @slides = []
    images.each_with_index do |image, i|
      imageView = add UIImageView.alloc.initWithImage(crop(image))
      imageView.frame = [[15 + 125 * i, 0], [120, 120]]
      tap = UITapGestureRecognizer.alloc.initWithTarget(self, action: 'imageTapped:')
      imageView.addGestureRecognizer(tap)
      imageView.userInteractionEnabled = true
      @slides << KSPhotoItem.itemWithSourceView(imageView, image: UIImage.imageWithData(image))
      @scrollView.addSubview(imageView)
    end
    self.contentView.addSubview(@scrollView)
  end
  
  def imageTapped(gestureRecognizer)
    if gestureRecognizer.state == UIGestureRecognizerStateEnded
      photoView = gestureRecognizer.view
      i = ((photoView.frame[0][0] - 15) / 125).to_i
      browser = KSPhotoBrowser.browserWithPhotoItems(@slides, selectedIndex:i)
      browser.showFromViewController(app.screen)
    end
  end
end