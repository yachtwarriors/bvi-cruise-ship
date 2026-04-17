module FaqHelper
  # Builds FAQ entries for a given page. Questions come from GSC query data —
  # we use real search queries (or PAA boxes) instead of inventing questions.
  # Answers lead with data (ship count, passenger total) when the page has it;
  # static context fills in the rest.
  #
  # context must include:
  #   :today_visits       — Array<CruiseVisit> for today
  #   :today_passengers   — Integer
  #   :today            — Date (BVI/USVI time)
  # Optional:
  #   :today_peak       — "red"|"yellow"|"green" (locations only)
  #   :best_time        — String like "10am – 12pm" (locations only)
  #   :location_name    — String (locations only)
  def build_faqs(page_key, context)
    visits = Array(context[:today_visits])
    ship_count = visits.size
    passengers = context[:today_passengers].to_i
    today = context[:today]
    ships_sentence = faq_ships_sentence(visits, passengers, today)

    case page_key
    when :home
      faqs_home(ships_sentence)
    when :usvi
      faqs_usvi(ships_sentence)
    when :tortola
      faqs_tortola(ships_sentence)
    when :virgin_gorda
      faqs_virgin_gorda(ships_sentence)
    when :st_thomas
      faqs_st_thomas(ships_sentence)
    when :st_croix
      faqs_st_croix(ships_sentence)
    when :the_baths
      faqs_the_baths(context, ships_sentence)
    when :cane_garden_bay
      faqs_cane_garden_bay(context, ships_sentence)
    when :white_bay
      faqs_white_bay(context, ships_sentence)
    when :magens_bay
      faqs_magens_bay(context, ships_sentence)
    when :coki_beach
      faqs_coki_beach(context, ships_sentence)
    when :national_park_beaches
      faqs_national_park_beaches(context, ships_sentence)
    when :rainbow_beach
      faqs_rainbow_beach(context, ships_sentence)
    when :buck_island
      faqs_buck_island(context, ships_sentence)
    else
      []
    end
  end

  private

  def faq_ships_sentence(visits, passengers, today)
    if visits.empty?
      "No cruise ships are scheduled today (#{today.strftime('%B %-d, %Y')})."
    else
      names = visits.map(&:ship_name).uniq.first(4).join(", ")
      "Today (#{today.strftime('%B %-d, %Y')}) #{visits.size} cruise ship#{visits.size == 1 ? ' is' : 's are'} scheduled, carrying approximately #{number_with_delimiter(passengers)} passengers: #{names}."
    end
  end

  def today_crowd_sentence(context)
    visits = Array(context[:today_visits])
    loc = context[:location_name]
    return "No cruise ships are scheduled today, so #{loc} should be at normal crowd levels." if visits.empty?

    risk = case context[:today_peak]
    when "red" then "high"
    when "yellow" then "moderate"
    else "low"
    end
    best = context[:best_time]
    prefix = "Today #{visits.size} ship#{visits.size == 1 ? '' : 's'} in port carrying #{number_with_delimiter(context[:today_passengers].to_i)} passengers, so #{loc} crowd risk is #{risk}."
    best && best != "early morning (before 10am) or late afternoon (after 3pm)" ? "#{prefix} Best time to visit today: #{best}." : prefix
  end

  # --- Port & overview pages -------------------------------------------------

  def faqs_home(ships)
    [
      { question: "What is the BVI cruise ship schedule today?",
        answer: "#{ships} This schedule is pulled daily from the BVI Ports Authority and cruise line published itineraries." },
      { question: "What cruise ports are in the BVI?",
        answer: "The British Virgin Islands have cruise ship activity at four anchorages: Road Town (Tortola) is the main pier; Spanish Town and Gorda Sound (Virgin Gorda) host tender calls; and Jost Van Dyke receives small-ship anchor calls." },
      { question: "Does BVI Ports Authority publish the cruise ship schedule?",
        answer: "Yes — BVI Ports Authority publishes the official arrival schedule. This site pulls that schedule daily and overlays beach-specific crowd forecasts based on ship capacity and typical excursion patterns." },
      { question: "What time do cruise ships arrive in the BVI?",
        answer: "Most cruise ships arrive at Road Town between 7am and 9am and depart between 4pm and 6pm. Crowds at beaches like The Baths and Cane Garden Bay peak between 10am and 2pm." },
      { question: "Are there cruise ships in Tortola tomorrow?",
        answer: "Check the 7-day schedule above. The next-day and week-ahead views show every scheduled ship by port." }
    ]
  end

  def faqs_usvi(ships)
    [
      { question: "What is the US Virgin Islands cruise ship schedule?",
        answer: "#{ships} The USVI has two cruise ports: Charlotte Amalie on St. Thomas (Havensight and Crown Bay terminals) and Frederiksted on St. Croix. This page shows the 7-day schedule for both." },
      { question: "Where do cruise ships dock in the USVI?",
        answer: "Most USVI cruise traffic is at Charlotte Amalie, St. Thomas — ships dock at either Havensight or Crown Bay terminal. Smaller and niche itineraries call at Frederiksted, St. Croix." },
      { question: "How many cruise ships visit St. Thomas each day?",
        answer: "St. Thomas typically hosts 1-4 cruise ships per day in high season (October-April), with up to 20,000 passengers on peak days. The schedule above shows exact counts for the next 7 days." },
      { question: "What is the cruise ship schedule for St. Croix?",
        answer: "St. Croix receives fewer cruise calls than St. Thomas — typically one ship at a time at Frederiksted's Ann E. Abramson Pier. See the St. Croix section above for the current week." }
    ]
  end

  def faqs_tortola(ships)
    [
      { question: "What cruise ships are in Tortola today?",
        answer: ships },
      { question: "What is the Tortola cruise ship schedule?",
        answer: "Tortola's cruise port is Road Town on the south coast. The 7-day schedule above shows every scheduled ship at Road Town, pulled daily from BVI Ports Authority and cruise line itineraries." },
      { question: "Where do cruise ships dock in Tortola?",
        answer: "Cruise ships dock at Road Town Harbour on Tortola's south coast. Taxis and tour operators meet passengers at the pier. Negotiate fares before riding — government-regulated rates apply." },
      { question: "How far is Cane Garden Bay from the Tortola cruise port?",
        answer: "Cane Garden Bay is about a 20-minute taxi ride over the hill from the Road Town cruise terminal. It fills up quickly on ship days." },
      { question: "Can cruise passengers visit The Baths from Tortola?",
        answer: "Yes — most Road Town cruise itineraries sell a ferry excursion to The Baths on Virgin Gorda. It's a 30-minute ferry each way plus ~2-3 hours at The Baths." },
      { question: "Are there cruise ships in Tortola tomorrow?",
        answer: "The schedule above shows tomorrow and the next 6 days. Use the date picker to jump to a specific day." }
    ]
  end

  def faqs_virgin_gorda(ships)
    [
      { question: "What is the Virgin Gorda cruise ship schedule?",
        answer: "#{ships} Virgin Gorda receives cruise ships at two tender anchorages: Spanish Town (The Valley) on the south end and Gorda Sound (North Sound) on the northeast." },
      { question: "Can cruise ship passengers visit The Baths from Virgin Gorda?",
        answer: "Yes — The Baths National Park is a 10-minute taxi ride from Spanish Town, the main tender dock on Virgin Gorda. Taxi fares are government-regulated, typically $5-7 per person. Park entrance is $3 per person." },
      { question: "How crowded is The Baths when cruise ships are at Virgin Gorda?",
        answer: "The Baths is the primary excursion destination for virtually all Virgin Gorda cruise passengers. On ship days, crowds peak between 10am and 2pm. Check the `/the-baths` page for hourly crowd forecasts." },
      { question: "Where do cruise ships dock at Virgin Gorda?",
        answer: "Ships don't dock — they anchor offshore and tender passengers to the Spanish Town dock, or occasionally to Gorda Sound (North Sound) for smaller vessels." }
    ]
  end

  def faqs_st_thomas(ships)
    [
      { question: "What is the cruise ship schedule for St. Thomas USVI?",
        answer: "#{ships} St. Thomas receives cruise ships at two terminals in Charlotte Amalie: Havensight (adjacent to Yacht Haven Grande) and Crown Bay (west of downtown)." },
      { question: "What is the port of St. Thomas cruise ship schedule?",
        answer: "The port of St. Thomas (Charlotte Amalie) is the busiest cruise port in the Caribbean, hosting 1-4 ships per day in high season. This page shows today and the next 6 days." },
      { question: "Where do cruise ships dock in St. Thomas?",
        answer: "Most St. Thomas cruise traffic docks at Havensight or Crown Bay in Charlotte Amalie. Magens Bay is a 20-minute taxi ride from both terminals; Coki Beach and Coral World are about 25 minutes east." },
      { question: "What is the best time to visit Magens Bay?",
        answer: "On cruise days, Magens Bay crowds peak between 10am and 2pm. Arrive before 10am or after 3pm for fewer crowds. On days with no ships in port, any time is a good time." },
      { question: "How much does Magens Bay cost?",
        answer: "Magens Bay Beach has a $5 per person entrance fee. Parking is additional. Taxi fares from cruise terminals are regulated — expect $10-13 per person each way." }
    ]
  end

  def faqs_st_croix(ships)
    [
      { question: "What is the cruise ship schedule for St. Croix?",
        answer: "#{ships} St. Croix receives cruise ships at the Ann E. Abramson Pier in Frederiksted on the west coast. Calls are less frequent than St. Thomas, typically one ship at a time." },
      { question: "Where do cruise ships dock in St. Croix?",
        answer: "All cruise ships dock at the Ann E. Abramson Pier in Frederiksted. Rainbow Beach is walkable from the pier in under 5 minutes. Christiansted, the main town, is a 30-minute taxi ride east." },
      { question: "Can cruise passengers visit Buck Island?",
        answer: "Yes — Buck Island Reef National Monument is accessible by excursion boat from Frederiksted or Christiansted. Trips typically take ~45 minutes each way, with 2-3 hours of snorkeling on the reef." }
    ]
  end

  # --- Beach / attraction pages ---------------------------------------------

  def faqs_the_baths(ctx, _ships)
    best = ctx[:best_time]
    best_answer = if Array(ctx[:today_visits]).empty?
      "No cruise ships are in port today, so The Baths should be uncrowded all day. Normal park hours are 8am-4pm."
    elsif best && best != "early morning (before 10am) or late afternoon (after 3pm)"
      "Today's best window is #{best}. On cruise days, arriving before 10am or after 3pm typically avoids the peak."
    else
      "On ship days like today, crowds are heavy throughout midday. Your best bet is early morning (before 10am) or late afternoon (after 3pm)."
    end

    [
      { question: "What is the best time to visit The Baths?",
        answer: best_answer },
      { question: "How crowded is The Baths when cruise ships are in port?",
        answer: today_crowd_sentence(ctx.merge(location_name: "The Baths")) + " Crowds typically peak between 10am and 2pm on ship days, when excursion groups arrive from both Virgin Gorda ships and Road Town (Tortola) ferry excursions." },
      { question: "Can cruise ship passengers visit The Baths?",
        answer: "Yes — The Baths is the #1 excursion destination for cruise ships calling at Virgin Gorda, and a popular ferry excursion from Road Town, Tortola. Park entrance is $3 per person." },
      { question: "How do I get to The Baths?",
        answer: "From Virgin Gorda: 10-minute taxi from Spanish Town ($5-7 per person). From Tortola: 30-minute ferry from Road Town, then short taxi — typically sold as a cruise excursion." },
      { question: "What should I bring to The Baths?",
        answer: "Water shoes (you'll climb through boulders), swimsuit, towel, drinking water, sunscreen, waterproof bag for phone. The trail between the beach and Devil's Bay takes 25-40 minutes each way." }
    ]
  end

  def faqs_cane_garden_bay(ctx, _ships)
    ctx_with_name = ctx.merge(location_name: "Cane Garden Bay")
    [
      { question: "Is Cane Garden Bay crowded today?",
        answer: today_crowd_sentence(ctx_with_name) },
      { question: "How do I get from Road Town to Cane Garden Bay?",
        answer: "Cane Garden Bay is a 20-minute taxi ride over the hill from the Road Town cruise terminal. Fares are regulated — typically $8-10 per person each way." },
      { question: "What is the best time to visit Cane Garden Bay?",
        answer: "On cruise days, crowds peak between 10am and 2pm. Arrive before 10am or after 3pm, or visit on a day with no ships at Road Town." },
      { question: "Are there restaurants and bars at Cane Garden Bay?",
        answer: "Yes — Cane Garden Bay has several beach bars and restaurants directly on the sand, including Myett's and Quito's Gazebo. Most open by mid-morning on cruise days." }
    ]
  end

  def faqs_white_bay(ctx, _ships)
    ctx_with_name = ctx.merge(location_name: "White Bay")
    [
      { question: "Is White Bay crowded today?",
        answer: today_crowd_sentence(ctx_with_name) },
      { question: "How do I get to White Bay on Jost Van Dyke?",
        answer: "White Bay is on Jost Van Dyke's south coast. From Tortola, take a water taxi from Road Town or the West End ferry. Cruise ships that anchor at Jost Van Dyke tender passengers directly to the beach." },
      { question: "What is the Soggy Dollar Bar?",
        answer: "The Soggy Dollar Bar at White Bay is the birthplace of the Painkiller cocktail. It's directly on the beach — guests traditionally swim ashore, paying in 'soggy dollars.'" },
      { question: "When do cruise ships come to Jost Van Dyke?",
        answer: "Smaller cruise ships (typically under 1,000 passengers) occasionally anchor off Jost Van Dyke and tender to White Bay or Great Harbour. Check the 7-day schedule above for specific dates." }
    ]
  end

  def faqs_magens_bay(ctx, _ships)
    ctx_with_name = ctx.merge(location_name: "Magens Bay")
    [
      { question: "Is Magens Bay crowded when cruise ships are in port?",
        answer: today_crowd_sentence(ctx_with_name) + " Magens Bay is one of the top cruise excursion destinations on St. Thomas — crowds peak between 10am and 2pm on ship days." },
      { question: "What is the best time to visit Magens Bay?",
        answer: "On cruise days, arrive before 10am or after 3pm to avoid the peak. On days with no ships in Charlotte Amalie, Magens is quiet all day." },
      { question: "How much does Magens Bay cost?",
        answer: "$5 per person entrance fee. Taxi from Havensight or Crown Bay is typically $10-13 per person each way (regulated open-air safari taxis)." },
      { question: "How do I get to Magens Bay from the cruise port?",
        answer: "20-minute taxi ride from either Havensight or Crown Bay cruise terminal. Open-air safari taxis run set routes; confirm the fare with the driver before departing." }
    ]
  end

  def faqs_coki_beach(ctx, _ships)
    ctx_with_name = ctx.merge(location_name: "Sapphire and Coki Beaches")
    [
      { question: "Are Sapphire and Coki Beaches crowded today?",
        answer: today_crowd_sentence(ctx_with_name) },
      { question: "What is there to do at Coki Beach?",
        answer: "Coki Beach is known for excellent snorkeling directly from shore — you'll see colorful fish just feet from the sand. Coral World Ocean Park is adjacent to the beach with marine exhibits and a semi-submarine." },
      { question: "How do I get to Coki Beach from the cruise port?",
        answer: "25-minute taxi ride east from Havensight cruise terminal, or about 35 minutes from Crown Bay. Safari taxis run regular routes to Coral World." },
      { question: "What's the difference between Sapphire and Coki Beach?",
        answer: "Both are on St. Thomas's east end. Sapphire Beach sits just west of Coki and tends to be quieter. Coki has better snorkeling but fills up faster because of Coral World traffic." }
    ]
  end

  def faqs_national_park_beaches(ctx, _ships)
    ctx_with_name = ctx.merge(location_name: "National Park Beaches")
    [
      { question: "How do I visit St. John's National Park Beaches from a cruise ship?",
        answer: "Take the Red Hook ferry from St. Thomas (45 minutes total from the cruise terminal) or book a cruise excursion boat directly to Trunk Bay or Cinnamon Bay." },
      { question: "Is Trunk Bay crowded today?",
        answer: today_crowd_sentence(ctx_with_name) + " Trunk Bay is the most visited beach in the national park and the most popular excursion from St. Thomas cruise ships." },
      { question: "How much does Trunk Bay cost?",
        answer: "$5 per person entrance fee (Virgin Islands National Park). Ferry and taxi fares are additional. The park is open daily, typically 8am to 4pm." },
      { question: "What National Park Beaches are on St. John?",
        answer: "Trunk Bay, Cinnamon Bay, Maho Bay, Hawksnest Beach, and Francis Bay are the most visited. Trunk Bay has the underwater snorkel trail and is the most photographed." }
    ]
  end

  def faqs_rainbow_beach(ctx, _ships)
    ctx_with_name = ctx.merge(location_name: "Rainbow Beach")
    [
      { question: "Is Rainbow Beach crowded today?",
        answer: today_crowd_sentence(ctx_with_name) + " Rainbow Beach is walkable from the Frederiksted cruise pier, so it fills up fast on ship days." },
      { question: "How do I get to Rainbow Beach from the cruise ship?",
        answer: "Rainbow Beach is steps from the Ann E. Abramson Pier in Frederiksted — walkable in under 5 minutes. No taxi needed." },
      { question: "What is there to do at Rainbow Beach?",
        answer: "Swimming, snorkeling along the pier pilings (tropical fish love the shade), beach bar with food and drinks, beach chair and umbrella rental. It's a classic walk-off beach day for cruise passengers." }
    ]
  end

  def faqs_buck_island(ctx, _ships)
    ctx_with_name = ctx.merge(location_name: "Buck Island")
    [
      { question: "How do cruise passengers visit Buck Island?",
        answer: "Via excursion boat from Frederiksted or Christiansted. Trips typically take 45 minutes each way, with 2-3 hours snorkeling the underwater reef trail. Book through the cruise line or an NPS-authorized concessionaire." },
      { question: "What is Buck Island Reef National Monument?",
        answer: "Buck Island is a protected islet off St. Croix's northeast coast with a coral reef ecosystem. It has the only underwater snorkel trail in the US National Park System." },
      { question: "Is Buck Island crowded today?",
        answer: today_crowd_sentence(ctx_with_name) + " Excursion boats typically arrive about an hour after the cruise ship docks at Frederiksted." }
    ]
  end
end
