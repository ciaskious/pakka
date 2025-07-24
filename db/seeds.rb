puts "🧹 Cleaning up old records..."
ChecklistItem.destroy_all
Item.destroy_all
Trip.destroy_all
User.destroy_all

puts "🌱 Seeding database..."

# === User data ===
user_data = [
  { email: "duparcrobin@gmail.com", username: "Robin", password: "1946kitt" },
  { email: "ciaskious@gmail.com", username: "Asia", password: "1946kitt" },
  { email: "joanagaalves@gmail.com", username: "Joana", password: "1946kitt" },
]

# === Reusable items ===
shared_items = [
  { name: "Toothbrush", description: "Toiletries" },
  { name: "Passport", description: "Documents" },
  { name: "Flip flops", description: "Clothing" },
  { name: "Notebook", description: "Stationery" },
  { name: "Snacks", description: "Food" },
  { name: "Travel pillow", description: "Comfort" },
  { name: "Power bank", description: "Electronics" },
]

user_data.each_with_index do |user_info, i|
  user = User.create!(user_info)

  # Assign reusable items to user
  items = shared_items.map do |item_data|
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

  # Add checklists items (linked)
  items.each do |item|
    trip.checklist_items.create!(
      name: item.name,
      item: item,
      checked: [true, false].sample,
    )
  end
end

puts "✅ Seeding complete!"
