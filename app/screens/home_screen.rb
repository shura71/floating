class HomeScreen < ProMotion::DataTableScreen
  title I18n.t("Fishing activities")
  
  nav_bar_button :right, system_item: :add, style: :plain, action: :add_new_record, tint_color: UIColor.labelColor
  
  model Fishing, scope: :sort_date
  
  def on_init
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(I18n.t("Fishing activities"), image:UIImage.imageNamed('float-24.png'), tag:1)
  end
  
  def fishingChanged(notification)
    update_table_data
  end
  
  def on_load
    NSNotificationCenter.defaultCenter.addObserver(self, selector: "fishingChanged:", name: "reloadFishing", object: nil)
  end
  
  def get_searchable_params
    params = {hide_initially: true, hides_search_bar_when_scrolling: true, fields: [:place,:region,:fish]}
    
    params[:search_results_updater] ||= params[:searchResultsUpdater]
    params[:hides_nav_bar] = params[:hidesNavigationBarDuringPresentation] if params[:hides_nav_bar].nil?
    params[:obscures_background] = params[:obscuresBackgroundDuringPresentation] if params[:obscures_background].nil?
    params[:hides_search_bar_when_scrolling] = params[:hidesSearchBarWhenScrolling] if params[:hides_search_bar_when_scrolling].nil?

    params[:delegate] ||= self
    params[:search_results_updater] ||= self
    params[:search_bar_delegate] ||= self
    params[:hides_nav_bar] = true if params[:hides_nav_bar].nil?
    params[:obscures_background] = false if params[:obscures_background].nil?
    params[:hides_search_bar_when_scrolling] = false if params[:hides_search_bar_when_scrolling].nil?

    params
  end
  
  def fetch_controller
    if searching? and not search_string.blank?
      search_fetch_controller
    else
      @fetch_controller ||= NSFetchedResultsController.alloc.initWithFetchRequest(
        fetch_scope.fetch_request,
        managedObjectContext: fetch_scope.context,
        sectionNameKeyPath: nil,
        cacheName: nil
      )
    end
  end
  
  def new_frc_with_search(search_string)
     return if @data_table_predicate_fields.blank?

     # Create the predicate from the predetermined fetch scope.
     where = @data_table_predicate_fields.map{|f| "#{f} CONTAINS[cd] \"#{search_string}\"" }.join(" OR ")
     search_scope = fetch_scope.where(where)
     mp "#{where}"

     # Create the search FRC with the predicate and set delegate
     search = NSFetchedResultsController.alloc.initWithFetchRequest(
       search_scope.fetch_request,
       managedObjectContext: search_scope.context,
       sectionNameKeyPath: nil,
       cacheName: nil
     )
     search.delegate = search_delegate

     # Perform the fetch
     error_ptr = Pointer.new(:object)
     unless search.performFetch(error_ptr)
       raise "Error performing fetch: #{error_ptr[2].description}"
     end

     search
  end
  
  def dt_searchDisplayController(controller, shouldReloadTableForSearchString:search_string)
    @_data_table_search_string = search_string
    reset_search_frc
    true
  end
      
  def search_fetch_controller
    @_search_fetch_controller ||= new_frc_with_search(search_string)
  end
  
  def updateSearchResultsForSearchController(search_controller)
   search_string = search_controller.searchBar.text
   dt_searchDisplayController(search_controller, shouldReloadTableForSearchString: search_string) if @_data_table_searching
   update_table_data
  end
  
  def screen_setup
    set_up_fetch_controller

    set_up_header_footer_views
    make_data_table_searchable(content_controller: self, search_bar: get_searchable_params)
    set_up_refreshable
    set_up_longpressable
    set_up_row_height
  end
  
  def will_begin_search
    @_data_table_searching = true
  end
    
  def will_end_search
    @_data_table_searching = false
  end
  
  def record_show(args={})
    open ShowScreen.new(nav_bar: true, record: args[:record])
  end
  
  def add_new_record
    open EditScreen.new(nav_bar: true)
  end
  
  def on_cell_deleted(cell, index_path)
    Fishing.where(:id).eq(cell[:arguments][:record].id).first.destroy
    cdq.save
    false
  end
end
