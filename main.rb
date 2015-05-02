
require_relative 'auth.private'
require 'wunderground'
require 'sendgrid-ruby'


# Make the Wunderground client
w_api = Wunderground.new(WUNDERGROUND_KEY)
# Make the call
data = w_api.forecast_for('44106')['forecast']['simpleforecast']['forecastday'][0..1]
immediate = "Now:\nhigh: "+ data[0]['high']['fahrenheit'] + ' low: '+data[0]['low']['fahrenheit'] + ' and generally: '+data[0]['conditions'].downcase
later = "Several Hours:\nhigh: "+ data[1]['high']['fahrenheit'] + ' low: '+data[1]['low']['fahrenheit'] + ' and generally: '+data[1]['conditions'].downcase
puts immediate
puts later



# Make the SendGrid client
client = SendGrid::Client.new(api_user: SENDGRID_USERNAME, api_key: SENDGRID_PASSWORD)

# Make the SendGrid email
mail = SendGrid::Mail.new do |m|
  m.to = 'USER@EMAIL.com' #your email here
  m.from = 'weather@tacocat.land'
  m.subject = 'Today\'s Weather Digest'
  m.text = immediate+"\n\n"+later
end

# Send the email and report the status.
puts client.send(mail)['message']
# {"message":"success"}