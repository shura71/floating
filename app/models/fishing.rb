class Fishing < CDQManagedObject
  scope :sort_date, sort_by(:fishingDate, order: :descending)
  
  MONTH_NAMES = [
    "янв",
    "фев",
    "мар",
    "апр",
    "май",
    "июн",
    "июл",
    "авг",
    "сен",
    "окт",
    "ноя",
    "дек"
  ]
  
  def self.import_from_sqlite3
    path = NSBundle.mainBundle.pathForResource("poplavok", ofType:"sqlite")
    db = SQLite3::Database.new(path)
    db.execute("SELECT * FROM ZNOTE") do |row|
      Fishing.create(
        id: results.stringForColumn("Z_PK").to_i,
        fishingDate: Time.at(row[:ZDATE] + 946731600) + 1.year + 5.hours, 
        lat: row[:ZCOORDLATITUDE].to_f, 
        lon: row[:ZCOORDLONGITUDE].to_f, 
        duration: row[:ZDURATION].to_i,
        isFavorite: (row[:ZISFAVORITE] == 'YES'), 
        place: row[:ZPLACE], 
        region: row[:ZREGION], 
        fish: row[:ZULOVNAME], 
        notes: row[:ZTEXT], 
        fishAmount: row[:ZULOVAMOUNT].to_i, 
        bait: row[:ZULOVBAIT],
        fishWeight: row[:ZULOVWEIGHT].gsub(/,/,'.').to_f, 
        temperature: row[:ZTEMPERATURE].to_i - 50, 
        weather: row[:ZWEATHER].to_i,
        cover: row[:ZCOVERIMAGE],
        images: row[:ZIMAGESARRAY]
      )
    end
    cdq.save
    mp "Imported #{Fishing.count} record(s)"
  end
  
  def self.create_copy_of_database_if_needed
    fileManager = NSFileManager.defaultManager
    error = Pointer.new(:object)
    appDBPath = "float.sqlite".document_path
    unless fileManager.fileExistsAtPath(appDBPath)
      defaultDBPath =  NSBundle.mainBundle.pathForResource("poplavok", ofType:"sqlite")
      success = fileManager.copyItemAtPath(defaultDBPath, toPath:appDBPath, error:error)  
      NSAssert(success, "Failed to create writable database file with message '%@'.", error[0].description)
    end
  end
  
  def self.import_from_sqlite
    path = "float.sqlite".document_path
    db = FMDatabase.databaseWithPath(path)
    db.open
    results = db.executeQuery("SELECT * FROM ZNOTE")
    while results.next do 
      time = Time.at(results.stringForColumn("ZDATE").to_i + 946731600) + 1.year + 5.hours
      Fishing.create(
        id: results.stringForColumn("Z_PK").to_i,
        fishingDate: time, 
        lat: results.stringForColumn("ZCOORDLATITUDE").to_f, 
        lon: results.stringForColumn("ZCOORDLONGITUDE").to_f, 
        duration: results.stringForColumn("ZDURATION").to_i,
        isFavorite: (results.stringForColumn("ZISFAVORITE") == 'YES'), 
        place: results.stringForColumn("ZPLACE"), 
        region: results.stringForColumn("ZREGION"), 
        fish: results.stringForColumn("ZULOVNAME"), 
        notes: results.stringForColumn("ZTEXT"), 
        fishAmount: results.stringForColumn("ZULOVAMOUNT").to_i, 
        bait: results.stringForColumn("ZULOVBAIT"),
        fishWeight: results.stringForColumn("ZULOVWEIGHT").sub(',', ".").to_f, 
        temperature: results.stringForColumn("ZTEMPERATURE").to_i - 50, 
        weather: results.stringForColumn("ZWEATHER").to_i,
        cover: results.dataForColumn("ZCOVERIMAGE"),
        images: results.dataForColumn("ZIMAGESARRAY")
      )
    end
    cdq.save
  end
  
  def cropped_cover
    image = UIImage.imageWithData(cover)
    
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
    
    image.crop(cropRect) # https://www.rubydoc.info/github/rubymotion/sugarcube/
  end
  
  def cell
    {
      image: {
        image: cropped_cover,
        radius: 10
      },
      height: 80,
      cell_class: FishingCell,
      properties: {
       month_year: "#{MONTH_NAMES[fishingDate.month - 1]} #{fishingDate.strftime("%y")}",
       day: fishingDate.strftime("%d"),
       fish: fish,
       fish_weight: fishWeight.round(2),
       place: place,
       region: region
      },
      action: :record_show,
      arguments: { record: self },
      editing_style: :delete
    }
  end
end