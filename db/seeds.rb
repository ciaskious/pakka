puts "🧹 Cleaning up old records..."
ChecklistItem.destroy_all
Item.destroy_all
Trip.destroy_all
User.destroy_all

puts "🌱 Seeding database..."

# === User data ===
user_data = [
  { email: "duparcrobin@gmail.com", first_name: "Robin", password: "1946kitt" },
  { email: "ciaskious@gmail.com", first_name: "Asia", password: "1946kitt" },
  { email: "joanagaalves@gmail.com", first_name: "Joana", password: "1946kitt" },
]

# === Reusable items ===
shared_items = [
  { name: "Toothbrush", category: "Toiletries" },
  { name: "Passport", category: "Documents" },
]

# === Custom checklist items ===
custom_checklist_items = [
  { name: "Flip flops", category: "Clothing" },
  { name: "Notebook", category: "Stationery" },
  { name: "Snacks", category: "Food" },
  { name: "Travel pillow", category: "Comfort" },
  { name: "Power bank", category: "Electronics" },
]

user_data.each_with_index do |user_info, i|
  user = User.create!(user_info)

  # Assign reusable items to user
  reusable_items = shared_items.map do |item_data|
    user.items.create!(item_data)
  end

  # Create a trip for each user
  trip = user.trips.create!(
    title: "Trip ##{i + 1}",
    destination: "Destination #{i + 1}",
    country: "Country #{i + 1}",
    start_date: Date.today + i.days,
    end_date: Date.today + (i + 7).days,
    public: i.even?,
  )

  # Add reusable checklist items (linked)
  reusable_items.each do |item|
    trip.checklist_items.create!(
      name: item.name,
      item: item,
      checked: [true, false].sample,
    )
  end

  # Add custom checklist items (not linked)
  custom_checklist_items.each do |custom|
    trip.checklist_items.create!(
      name: custom[:name],
      category: custom[:category],
      checked: [true, false].sample,
    )
  end
end

puts "✅ Seeding complete!"
