class AboutScreen < PM::TableScreen
  title I18n.t("About app")

  def on_init
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(I18n.t("More"), image:UIImage.imageNamed('float-24.png'), tag:1)
  end

  def will_appear
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemStop, target:self, action:"close") if Device.ipad?
  end

  def table_data
    [{
      title: app.name,
      cells: [{
        title: I18n.t("Version"),
        subtitle: App.info_plist['CFBundleShortVersionString'],
      }, {
        title: I18n.t("Copyright"),
        subtitle: "#{copyright_year} Shura Scherban",
      }]
    }, {
      title: app.name + " " + I18n.t("is open source:"),
      cells: [{
        title: I18n.t("View on GitHub"),
        action: :launch_github,
        image: "github"
      }, {
        title: I18n.t("Found a bug?"),
        subtitle: I18n.t("Log it here."),
        action: :launch_bug,
        image: "issue"
      }]
    }, {
      title: I18n.t("Tell Your friends:"),
      cells: [{
        title: I18n.t("Share the app"),
        subtitle: "Email, Tweet ... Facebook",
        action: :share_app,
        image: "share",
      }]
    }]
  end

  def launch_bug
    open_url('https://github.com/shura71/floating/issues')
  end

  def launch_github
    open_url('https://github.com/shura71/floating')
  end

  def open_url(url)
    App.open_url url
  end

  def share_app
    BW::UIActivityViewController.new(
      items: I18n.t("I'm using the Poplavok app. Check it out!") + " https://github.com/shura71/floating",
      animated: true,
      excluded: [
        :add_to_reading_list,
        :air_drop,
        :copy_to_pasteboard,
        :print
      ]
    ) do |activity_type, completed|
      # Nothing to see here... please move along
    end
  end

  def copyright_year
    start_year = '2019'
    this_year = Time.now.year

    start_year == this_year ? this_year : "#{start_year}-#{this_year}"
  end

  def close
    dismissModalViewControllerAnimated(true)
  end
end