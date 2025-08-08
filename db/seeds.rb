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
  { email: "duparcrobin@gmail.com", first_name: "Robin", last_name: "Du Parc", username: "duparcrobin", password: "1946kitt", avatar_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753732269/robin_y06loa.jpg" },
  { email: "ciaskious@gmail.com", first_name: "Asia", last_name: "Kaloudi", username: "ciaskious", password: "1946kitt", avatar_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753732269/asia_ssajaw.png" },
  { email: "joanagaalves@gmail.com", first_name: "Joana", last_name: "Azevedo", username: "joanagaalves", password: "1946kitt", avatar_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753732269/joana_oijl6g.jpg" },
]

users = user_data.map do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |user|
    user.first_name = attrs[:first_name]
    user.last_name = attrs[:last_name]
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
  { name: "Pill", category: "medication" },
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

puts "🗺️ Creating trips..."

trip_data = [
  { title: "Lisbon Summer Escape", destination: "Lisbon", country: "Portugal", location: "Lisbon", start_date: Date.tomorrow.strftime("%Y-%m-%d"), end_date: (Date.tomorrow + 7.days).strftime("%Y-%m-%d"), accommodation_type: "apartment", public: true, cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733288/lisbon_bmoivj.jpg" },
  { title: "Alpine Ski Adventure", destination: "Zermatt", country: "Switzerland", location: "Alps", start_date: (Date.today + 3.days).strftime("%Y-%m-%d"), end_date: (Date.today + 10.days).strftime("%Y-%m-%d"), accommodation_type: "cabin", public: true, cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733288/zermatt_zc5drx.jpg" },
  { title: "Berlin Weekend", destination: "Berlin", country: "Germany", location: "Berlin", start_date: Date.tomorrow.strftime("%Y-%m-%d"), end_date: (Date.tomorrow + 4.days).strftime("%Y-%m-%d"), accommodation_type: "hotel", public: true, cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733343/berlin_lji0wm.avif" },
  { title: "Santorini Getaway", destination: "Santorini", country: "Greece", location: "Aegean Sea", start_date: (Date.today + 5.days).strftime("%Y-%m-%d"), end_date: (Date.today + 12.days).strftime("%Y-%m-%d"), accommodation_type: "resort", public: true, cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733288/santorini_xslml6.avif" },
  { title: "Marrakech Discovery", destination: "Marrakech", country: "Morocco", location: "Atlas Mountains", start_date: Date.tomorrow.strftime("%Y-%m-%d"), end_date: (Date.tomorrow + 7.days).strftime("%Y-%m-%d"), accommodation_type: "homestay", public: true, cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733288/marrakech_iifnyv.jpg" },
  { title: "Stockholm Summer", destination: "Stockholm", country: "Sweden", location: "Stockholm", start_date: (Date.today + 2.days).strftime("%Y-%m-%d"), end_date: (Date.today + 9.days).strftime("%Y-%m-%d"), accommodation_type: "hotel", public: true, cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733288/stockholm_ps2mrj.avif" },
  { title: "Bali Jungle Retreat", destination: "Ubud", country: "Indonesia", location: "Bali", start_date: Date.tomorrow.strftime("%Y-%m-%d"), end_date: (Date.tomorrow + 15.days).strftime("%Y-%m-%d"), accommodation_type: "homestay", public: true, cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733288/ubud_zuqriu.jpg" },
  { title: "Kyoto Cultural Journey", destination: "Kyoto", country: "Japan", location: "Kyoto", start_date: (Date.today + 4.days).strftime("%Y-%m-%d"), end_date: (Date.today + 14.days).strftime("%Y-%m-%d"), accommodation_type: "campsite", public: true, cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733287/kyoto_pgjpyo.jpg" },
  { title: "Pacific Coast Roadtrip", destination: "California", country: "USA", location: "Highway 1", start_date: Date.tomorrow.strftime("%Y-%m-%d"), end_date: (Date.tomorrow + 13.days).strftime("%Y-%m-%d"), accommodation_type: "campsite", public: true, cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1753733288/california_vxedbe.webp" },
  { title: "Chamonix Ski Week", destination: "Chamonix", country: "France", location: "Mont Blanc", start_date: (Date.today + 3.days).strftime("%Y-%m-%d"), end_date: (Date.today + 10.days).strftime("%Y-%m-%d"), accommodation_type: "cabin", public: true, cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1754689224/patrick-boucher-w2DBsig0eEY-unsplash_gv9ku7.jpg" },
  { title: "Vietnam Backpacking", destination: "Hanoi", country: "Vietnam", location: "Northern Vietnam", start_date: Date.tomorrow.strftime("%Y-%m-%d"), end_date: (Date.tomorrow + 20.days).strftime("%Y-%m-%d"), accommodation_type: "hostel", public: true, cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1754689293/florian-wehde-lY87gHWdGNo-unsplash_jje6j3.jpg" },
  { title: "Arctic Lights Expedition", destination: "Tromsø", country: "Norway", location: "Arctic Circle", start_date: (Date.today + 6.days).strftime("%Y-%m-%d"), end_date: (Date.today + 13.days).strftime("%Y-%m-%d"), accommodation_type: "hotel", public: true, cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1754689345/bjorn-are-with-andreassen-vPg790ZGCCM-unsplash_y51fnf.jpg" },
  { title: "Tuscan Wine Tour", destination: "Tuscany", country: "Italy", location: "Chianti Region", start_date: Date.tomorrow.strftime("%Y-%m-%d"), end_date: (Date.tomorrow + 7.days).strftime("%Y-%m-%d"), accommodation_type: "resort", public: true, cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1754689398/johny-goerend-pnigODapPek-unsplash_zi1hxw.jpg" },
  { title: "Serengeti Safari", destination: "Serengeti", country: "Tanzania", location: "National Park", start_date: (Date.today + 5.days).strftime("%Y-%m-%d"), end_date: (Date.today + 15.days).strftime("%Y-%m-%d"), accommodation_type: "cabin", public: true, cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1754689455/hu-chen-0LwfbRtQ-ac-unsplash_em5wkk.jpg" },
  { title: "Rio Carnival Fever", destination: "Rio de Janeiro", country: "Brazil", location: "Copacabana", start_date: (Date.today + 2.days).strftime("%Y-%m-%d"), end_date: (Date.today + 9.days).strftime("%Y-%m-%d"), accommodation_type: "hostel", public: true, cover_url: "https://res.cloudinary.com/djls9crmj/image/upload/v1754689487/raphael-nogueira-espuILpsRUw-unsplash_psszjl.jpg" }
]

users.each_with_index do |user, index|
  user_trip_data = trip_data.slice(index * 5, 5)
  user_trip_data.each_with_index do |trip_attrs, i|
    trip = user.trips.create!(
      title: trip_attrs[:title],
      destination: trip_attrs[:destination],
      country: trip_attrs[:country],
      location: trip_attrs[:location],
      start_date: trip_attrs[:start_date],
      end_date: trip_attrs[:end_date],
      accommodation_type: trip_attrs[:accommodation_type],
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
        item_id: custom_item.id,
        checked: [true, false].sample,
      )
      puts "Created custom checklist item: #{custom_item.name} for trip #{trip.title}"
    end
    puts "✅ Created #{trip.title} for #{user.email}"
  end
end

puts "🌿 Seeding complete!"
