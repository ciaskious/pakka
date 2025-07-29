# app/services/ai_packing_service.rb
class AiPackingService < ApplicationService
  attr_reader :trip, :client

  def initialize(trip)
    @trip = trip
    @client = OpenAI::Client.new
  end

  def call
    generate_suggestions
  end

  private

  def generate_suggestions
    response = client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: user_prompt }
        ],
        temperature: default_temperature,
        max_tokens: default_max_tokens
      }
    )

    parse_response(response)
  rescue StandardError => e
    Rails.logger.error "AI Packing Service Error: #{e.message}"
    "Sorry, we couldn't generate packing suggestions at the moment. Please try again later."
  end

  def default_temperature
    # Plus conservateur pour voyages courts, plus créatif pour longs voyages
    trip_duration_in_days <= 3 ? 0.3 : 0.5
  end

  def default_max_tokens
    # Plus de détails pour voyages longs
    trip_duration_in_days <= 7 ? 600 : 900
  end

  def ai_prompt_context
    {
      destination: trip.destination,
      country: trip.country,
      period: formatted_travel_period,
      duration: trip_duration_in_days,
      title: trip.title
    }
  end

  def formatted_travel_period
    if trip.start_date.year == trip.end_date.year
      "#{trip.start_date.strftime('%B %d')} to #{trip.end_date.strftime('%B %d, %Y')}"
    else
      "#{trip.start_date.strftime('%B %d, %Y')} to #{trip.end_date.strftime('%B %d, %Y')}"
    end
  end

  def trip_duration_in_days
    (trip.end_date - trip.start_date).to_i + 1
  end

  def system_prompt
    <<~PROMPT.strip
      You are a professional travel packing assistant with expertise in helping travelers pack efficiently for various destinations and trip types.

      Your role is to:
      - Provide practical, destination-specific packing recommendations
      - Consider local climate, culture, and travel logistics
      - Suggest essential items while avoiding overpacking
      - Include safety and health considerations

      Return only a clean, organized checklist with one item per line.
      Group items by category (Clothing, Electronics, Personal Care, Documents, etc.) if helpful.
      No commentary, introductions, or explanations - just the practical checklist.
    PROMPT
  end

  def user_prompt
    context = ai_prompt_context

    <<~PROMPT.strip
      I am going on a trip called "#{context[:title]}" to #{context[:destination]}, #{context[:country]} from #{context[:period]}.
      The trip will last #{context[:duration]} #{context[:duration] == 1 ? 'day' : 'days'}.

      Based on this destination and travel duration, please generate a practical packing checklist including:
      - Appropriate clothing for the destination and season
      - Essential electronics and accessories
      - Personal care and hygiene items
      - Important documents and travel essentials
      - Any destination-specific considerations

      Format as a simple checklist - one item per line.
    PROMPT
  end

  def parse_response(response)
    if response.dig("choices", 0, "message", "content")
      content = response["choices"][0]["message"]["content"].strip
      return content if content.present?
    end

    "No packing suggestions available at the moment."
  end
end
