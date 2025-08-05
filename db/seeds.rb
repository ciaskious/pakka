require "open-uri"
require "faker"
require "marcel"

puts "🧹 Cleaning up old records..."
ChecklistItem.destroy_all
Item.destroy_all
Trip.destroy_all
User.destroy_all

puts "👤 Creating users..."

# === User data ===
user_data = [
  { email: "duparcrobin@gmail.com", first_name: "Robin", username: "duparcrobin", password: "1946kitt", avatar_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753732269/robin_y06loa.jpg" },
  { email: "ciaskious@gmail.com", first_name: "Asia", username: "ciaskious", password: "1946kitt", avatar_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753732269/asia_ssajaw.png" },
  { email: "joanagaalves@gmail.com", first_name: "Joana", last_name: "Azevedo", username: "joanagaalves", password: "1946kitt", avatar_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753732269/joana_oijl6g.jpg" },
]

users = user_data.map do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |user|
    user.first_name = attrs[:first_name]
    user.username = attrs[:username]
    user.password = attrs[:password]
  end.tap do |user|
    begin
      file = URI.open(attrs[:avatar_url])
      user.avatar.attach(
        io: file,
        filename: File.basename(URI.parse(attrs[:avatar_url]).path),
        content_type: Marcel::MimeType.for(file),
      )
      puts "✅ Created user: #{user.email} with avatar"
    rescue OpenURI::HTTPError => e
      puts "⚠️ Could not fetch avatar for #{user.email}: #{e.message}"
    end
  end
end

puts "📦 Creating reusable items..."

# 12 shared items, distributed 4 per user
shared_items = [
  { name: "Toothbrush", category: "toiletries" },
  { name: "Shampoo", category: "toiletries" },
  { name: "Passport", category: "documents" },
  { name: "Travel Insurance", category: "documents" },
  { name: "Flip Flops", category: "clothing" },
  { name: "Hoodie", category: "clothing" },
  { name: "Power Bank", category: "electronics" },
  { name: "Phone Charger", category: "electronics" },
  { name: "Snacks", category: "food" },
  { name: "Reusable Water Bottle", category: "food" },
  { name: "Painkillers", category: "medication" },
  { name: "Plasters", category: "medication" },
]

users.each_with_index do |user, index|
  # give each user 4 unique reusable items
  user_items = shared_items.slice(index * 4, 4)
  user_items.each do |item_attrs|
    item = user.items.create!(item_attrs.merge(reusable: true))
    puts "Created reusable item: #{item.name} (#{item.category}) for #{user.email}"
  end
  puts "🧳 #{user.email} now has #{user.items.reusable.count} reusable items"
end

accommodation_options = Trip::ACCOMMODATION_OPTIONS

puts "🗺️ Creating trips..."

trip_data = [
  { title: "Summer Escape", destination: "Lisbon", country: "Portugal", location: "Lisbon", cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733288/lisbon_bmoivj.jpg" },
  { title: "Mountain Retreat", destination: "Zermatt", country: "Switzerland", location: "Alps", cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733288/zermatt_zc5drx.jpg" },
  { title: "City Break", destination: "Berlin", country: "Germany", location: "Berlin", cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733343/berlin_lji0wm.avif" },
  { title: "Island Hopping", destination: "Santorini", country: "Greece", location: "Aegean Sea", cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733288/santorini_xslml6.avif" },
  { title: "Desert Adventure", destination: "Marrakech", country: "Morocco", location: "Atlas Mountains", cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733288/marrakech_iifnyv.jpg" },
  { title: "Scandinavian Escape", destination: "Stockholm", country: "Sweden", location: "Stockholm", cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733288/stockholm_ps2mrj.avif" },
  { title: "Jungle Trek", destination: "Ubud", country: "Indonesia", location: "Bali", cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733288/ubud_zuqriu.jpg" },
  { title: "Cultural Tour", destination: "Kyoto", country: "Japan", location: "Kyoto", cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733288/ubud_zuqriu.jpg" },
  { title: "Road Trip", destination: "California", country: "USA", location: "Pacific Coast", cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733288/california_vxedbe.webp" },
]

users.each_with_index do |user, index|
  user_trip_data = trip_data.slice(index * 3, 3)
  user_trip_data.each_with_index do |trip_attrs, i|
    trip = user.trips.create!(
      title: trip_attrs[:title],
      destination: trip_attrs[:destination],
      country: trip_attrs[:country],
      location: trip_attrs[:location],
      start_date: Date.today + (i * 10),
      end_date: Date.today + (i * 10) + 5,
      accommodation_type: accommodation_options.sample,
      public: [true, false].sample,
    )
    begin
      file = URI.open(trip_attrs[:cover_url])
      trip.cover_image.attach(
        io: file,
        filename: File.basename(URI.parse(trip_attrs[:cover_url]).path),
        content_type: Marcel::MimeType.for(file),
      )
    rescue OpenURI::HTTPError => e
      puts "⚠️ Could not fetch cover for trip #{trip.title}: #{e.message}"
    end
    # Add 3 reusable checklist items
    user.items.reusable.reorder("RANDOM()").limit(3).each do |item|
      trip.checklist_items.create!(
        name: item.name,
        category: item.category,
        item_id: item.id,
        checked: [true, false].sample,
      )
      puts "Creating checklist item from item ID #{item.id} for trip #{trip.title}"
    end
    # Add 3 non-reusable checklist items
    3.times do
      name = Faker::Commerce.product_name
      category = user.items.reusable.sample.category
      custom_item = user.items.create!(name: name, category: category, reusable: false)
      trip.checklist_items.create!(
        name: custom_item.name,
        category: custom_item.category,
        item_id: custom_item.id,
        checked: [true, false].sample,
      )
      puts "Created custom checklist item: #{custom_item.name} for trip #{trip.title}"
    end
    puts "✅ Created #{trip.title} for #{user.email}"
  end
end

puts "🌿 Seeding complete!"
