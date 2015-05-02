
require_relative 'auth.private'
require 'wunderground'
require 'sendgrid-ruby'


def rain?(data)
  data[0..1].collect {|x| x['conditions'].downcase}
             .collect{|x| x.include?('rain') or x.include?('shower')}.reduce(:|) ? 'yes' : 'no' #dat data flow
end

def get_data(zipcode)
  # Make the Wunderground client
  w_api = Wunderground.new(WUNDERGROUND_KEY)
  # Make the call
  return w_api.forecast_for(zipcode)['forecast']['simpleforecast']['forecastday']
end

def send_email(destination, text)
  # Make the SendGrid client
  client = SendGrid::Client.new(api_user: SENDGRID_USERNAME, api_key: SENDGRID_PASSWORD)
  # Make the SendGrid email
  mail = SendGrid::Mail.new do |m|
    m.to = destination #your email here
    m.from = 'weather@tacocat.land'
    m.subject = 'Today\'s Weather Digest'
    m.text = text
  end
  # Send the email and report the status.
  client.send(mail)
end




data = get_data('44106')

high = data[0..1].collect {|x| x['high']['fahrenheit']}
low =  data[0..1].collect {|x| x['low']['fahrenheit']}
conditions = data[0..1].collect {|x| x['conditions'].downcase}

immediate = "Now:\nhigh: "+ high[0] + ' low: '+low[0] + ' and generally: '+conditions[0]
later = "Several Hours:\nhigh: "+ high[1] + ' low: '+low[1] + ' and generally: '+conditions[1]

#we want an umbrella if there's rain/showers now or soon
umbrella = rain?(data)

#we never want cargo shorts
cargo_shorts = 'no'

#we want shorts if the average temp across now and 'future' is above 60, and it's not raining.
average_temp = high.map{|x|x.to_i}.reduce(:+)+low.map{|x|x.to_i}.reduce(:+)
average_temp /= 4

shorts = ((average_temp > 60) and umbrella.include?('no'))
#we want pants if the average temp across now and 'future' is below 50
pants = (average_temp < 50)

bottom = ''
bottom = 'shorts' if shorts
bottom = 'pants' if pants

#we want jacket if the average temp across now and 'future' is below 40
jacket = (average_temp< 40) ? 'yes' : 'no'

text = "\ncargo shorts? #{cargo_shorts}"
text <<"\nbottom: #{bottom}" if pants or shorts # don't make a recommendation if we're in limbo
text <<"\njacket? #{jacket}"
text <<"\numbrella? #{umbrella}"
text <<"\n\n#{immediate}"
text <<"\n\n#{later}"
puts text

send_email('USER@EMAIL.com', text)