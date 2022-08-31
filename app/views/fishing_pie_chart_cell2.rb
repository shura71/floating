class FishingPieChartCell2 < PM::TableViewCell
  def ftitle=(place)
    @place_view ||= begin 
      label = add UILabel.alloc.initWithFrame([[ 15, 0 ], [ self.contentView.frame.size.width - 15 , 30 ]])
      label.font = UIFont.fontWithName("Helvetica", size:12)
      label.color = UIColor.lightGrayColor # beautiful
      label
    end
    @place_view.text = "#{place}"
    self.contentView.addSubview(@place_view)
  end
  
  def records=(records)
    @records = records
    @conditions = Weather::CONDITIONS
    @values = @conditions.each_with_index.map {|x, ph| Fishing.where(:weather).eq(ph).size } 
    @chart_view = YTPieChart.alloc.initWithFrame([[ (app.screen.view.window.frame.size.width - 280)/3 * 2, 10 ], [ 280, 280 ]])
    @chart_view.dataSource = self
    @chart_view.delegate = self
    @chart_view.reloadData
    self.contentView.addSubview(@chart_view)
  end  
  
  def numberOfSlicesInChart(chart)
    @values.select { |_, value| value != 0 }.size
  end
  
  def chart(chart, valueForSliceAtIndex:index)
    @values[index] 
  end
  
  def chart(chart, colorForSliceAtIndex:index)
    [
       UIColor.colorWithRed(0.08, green: 0.14, blue: 0.35, alpha: 0.25),
       UIColor.colorWithRed(0.09, green: 0.42, blue: 0.63, alpha: 0.25),
       UIColor.colorWithRed(0.10, green: 0.67, blue: 0.87, alpha: 0.25), 
       UIColor.colorWithRed(0.10, green: 0.79, blue: 0.90, alpha: 0.25),
       UIColor.colorWithRed(0.11, green: 0.89, blue: 0.74, alpha: 0.25),
       UIColor.colorWithRed(0.43, green: 0.94, blue: 0.82, alpha: 0.25),
       UIColor.colorWithRed(0.78, green: 0.98, blue: 0.93, alpha: 0.25),
       UIColor.colorWithRed(0.16, green: 0.02, blue: 0.42, alpha: 0.25)
     ][index]
  end
  
  def chart(chart, titleForSliceAtIndex:index)
    @values[index] != 0 ? "#{@conditions[index]} (#{(@values[index]/(@records.size * 1.0) * 100).round(1)})%" : ""
  end
end