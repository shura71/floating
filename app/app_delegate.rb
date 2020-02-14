class AppDelegate < PM::Delegate
  include CDQ # Remove this if you aren't using CDQ

  status_bar true, animation: :fade

  # Without this, settings in StandardAppearance will not be correctly applied
  # Remove this if you aren't using StandardAppearance
  ApplicationStylesheet.new(nil).application_setup

  def on_load(app, options)
    cdq.setup
    $cache = {}
    Fishing.create_copy_of_database_if_needed
    Fishing.import_from_sqlite if Fishing.all.size == 0
    open_tab_bar HomeScreen.new(nav_bar: true), CalendarScreen.new(nav_bar: true), MapScreen.new(nav_bar: true), StatScreen.new(nav_bar: true)
  end
end
