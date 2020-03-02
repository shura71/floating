class FishingPieChartCell < PM::TableViewCell
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
    @phases = ['Новолуние', 'Молодая', 'Первая ¼', 'Прибывающая', 'Полнолуние', 'Убывающая', 'Последняя ¼', 'Старая']
    @values = @phases.each_with_index.map {|x, ph| Fishing.where(:moonPhase).eq(ph).size } 
    # Alternative: https://github.com/toamitkumar/motion-plot
    @chart_view = YTPieChart.alloc.initWithFrame([[ (app.screen.view.window.frame.size.width - 280)/3 * 2, 10 ], [ 280, 280 ]])
    @chart_view.dataSource = self
    @chart_view.delegate = self
    @chart_view.reloadData
    self.contentView.addSubview(@chart_view)
  end  
  
  def numberOfSlicesInChart(chart)
    @phases.size
  end
  
  def chart(chart, valueForSliceAtIndex:index)
    @values[index] 
  end
  
  def chart(chart, colorForSliceAtIndex:index)
    [UIColor.blueColor.with(a:0.25),
     UIColor.greenColor.with(a:0.25),
     UIColor.redColor.with(a:0.25), 
     UIColor.magentaColor.with(a:0.25),
     UIColor.purpleColor.with(a:0.25),
     UIColor.orangeColor.with(a:0.25),
     UIColor.yellowColor.with(a:0.25),
     UIColor.grayColor.with(a:0.25)
     ][index]
  end
  
  def chart(chart, titleForSliceAtIndex:index)
    "#{@phases[index]} (#{@values[index]})"
  end
end