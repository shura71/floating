class ShareText < UIActivityItemProvider

  attr_accessor :text

  # The placeholder text
  def activityViewControllerPlaceholderItem(controller)
    ""
  end

  # The text that will be inserted into the Tweet / Email / SMS etc.
  # You could easily respond to more activity types if you wanted
  def activityViewController(controller, itemForActivityType: activityType)
    if activityType == UIActivityTypePostToTwitter
      "#{text} #{twitter_handle} #{hashtag}"
    else
      "#{text}"
    end
  end

  def hashtag
    "#catchandrelease"
  end

  def twitter_handle
    "@poplavok"
  end

end