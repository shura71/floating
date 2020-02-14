schema "0001 initial" do
  entity "Fishing" do
    datetime :fishingDate, optional: false 
    float :lat, optional: false
    float :lon, optional: false
    integer16 :duration, optional: false
    boolean :isFavorite, default: false
    string :place, optional: false
    string :region, optional: false
    string :fish, optional: false
    string :notes
    integer16 :fishAmount, optional: false
    string :bait, optional: false
    float :fishWeight, optional: false
    integer16 :temperature, optional: false
    integer16 :weather, optional: false
    binary :cover
    binary :images
  end
end
