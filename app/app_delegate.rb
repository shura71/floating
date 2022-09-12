class AppDelegate < PM::Delegate
  include CDQ # Remove this if you aren't using CDQ

  status_bar true, animation: :fade
  # tint_color "#581A27".to_color

  # Without this, settings in StandardAppearance will not be correctly applied
  # Remove this if you aren't using StandardAppearance
  ApplicationStylesheet.new(nil).application_setup

  def on_load(app, options)
    cdq.setup
    
    # https://nemecek.be/blog/127/how-to-disable-automatic-transparent-tabbar-in-ios-15
    if Device.ios_version.to_i >= 13
      tabBarAppearance =  UITabBarAppearance.new
      tabBarAppearance.configureWithDefaultBackground
      tabBarAppearance.backgroundColor = UIColor.systemBackgroundColor
      UITabBar.appearance.standardAppearance = tabBarAppearance 
      UITabBar.appearance.scrollEdgeAppearance = tabBarAppearance  if Device.ios_version.to_i >= 15
    end

    $cache = {}
    Fishing.create_copy_of_database_if_needed
    Fishing.import_from_sqlite if Fishing.all.size == 0
    open_tab_bar HomeScreen.new(nav_bar: true), CalendarScreen.new(nav_bar: true), MapScreen.new(nav_bar: true), StatScreen.new(nav_bar: true), AboutScreen.new(nav_bar: true)
  end
end
