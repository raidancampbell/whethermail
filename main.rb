
require_relative 'auth.private'
require 'wunderground'
require 'sendgrid-ruby'


# Make the Wunderground client
w_api = Wunderground.new(WUNDERGROUND_KEY)
# Make the call
data = w_api.forecast_for('44106')['forecast']['simpleforecast']['forecastday']


high_temp = data[0..1].collect {|x| x['high']['fahrenheit']}
low =  data[0..1].collect {|x| x['low']['fahrenheit']}
conditions = data[0..1].collect {|x| x['conditions'].downcase}

immediate = "Now:\nhigh: "+ high_temp[0] + ' low: '+low[0] + ' and generally: '+conditions[0]
later = "Several Hours:\nhigh: "+ high_temp[1] + ' low: '+low[1] + ' and generally: '+conditions[1]

puts immediate
puts
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
puts client.send(mail)
# {"message":"success"}