require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
                              address: zipcode,
                              levels: 'country',
                              roles: ['legislatorUpperBody', 'legislatorLowerBody']).officials
 rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end

end

def clean_phonenumber(phonenumber)
  phonenumber.gsub!(/\D*/,"")
  if phonenumber.length == 10
    phonenumber
  elsif phonenumber.length == 11 && phonenumber[0] === "1"
    phonenumber[1..-1]
  else
    "Phonenumber not correct"
  end

end

puts "EventManager initialized."

#template_letter = File.read "form_letter.erb"
#erb_template = ERB.new template_letter

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

hours = []
days = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  #legislators = legislators_by_zipcode(zipcode)

  #form_letter = erb_template.result(binding)

  #save_thank_you_letters(id,form_letter)

  phonenumber = clean_phonenumber(row[:homephone])
  date = DateTime.strptime(row[:regdate], '%m/%d/%y %H:%M')
  hours << date.hour
  days <<  date.wday


  puts name, phonenumber

end

hash_hour = hours.inject({}) do |hsh, hour|
  hsh[hour] ||= 0
  hsh[hour] += 1
  hsh
end

hash_day = days.inject({}) do |hsh, day|
  hsh[day] ||= 0
  hsh[day] += 1
  hsh
end



puts 'Registration hours'
puts hash_hour.sort.to_h

puts 'Registration days'
puts hash_day.sort.to_h
