Given /^the following slides:$/ do |slides|
  slides.hashes.each do |s|
    channel = nil
    if s["channel"]
      channel = Channel.find_by_name(s["channel"])
      s.delete("channel")
      s["channel_id"] = channel.id
    end
    
    slide = Slide.new(s)
    slide.save!
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) slide$/ do |pos|
  visit slides_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

When /^I follow "([^\"]*)" link for the (\d+)(?:st|nd|rd|th) slide$/ do |link_name, pos|
  with_scope("#slide_#{pos}") do
    click_link link_name
  end
end

Then /^I should see the following slides:$/ do |expected_slides_table|
  expected_slides_table.diff!( tableish('ul#slides li table', 'td.title') )
end

Then /^Slide include following information:$/ do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end
