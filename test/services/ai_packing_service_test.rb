# test/services/ai_packing_service_test.rb
require "test_helper"

class AiPackingServiceTest < ActiveSupport::TestCase
  def setup
    @user = users(:one) # Assuming you have fixtures
    @trip = trips(:one) # Assuming you have fixtures
  end

  test "should initialize with trip" do
    service = AiPackingService.new(@trip)
    assert_equal @trip, service.trip
    assert_not_nil service.client
  end

  test "should format travel period correctly" do
    service = AiPackingService.new(@trip)
    context = service.send(:ai_prompt_context)

    assert_includes context[:period], @trip.start_date.strftime('%B %d')
    assert_includes context[:period], @trip.end_date.strftime('%B %d')
  end

  test "should handle API errors gracefully" do
    service = AiPackingService.new(@trip)

    # Mock the client to raise an error
    service.client.stub :chat, -> { raise StandardError.new("API Error") } do
      result = service.generate_suggestions
      assert_includes result, "Sorry, we couldn't generate packing suggestions"
    end
  end
end
