gem 'sendgrid-ruby'

require_relative 'auth.private'

w_api = Wunderground.new(WUNDERGROUND_KEY)



# Make the client
client = SendGrid::Client.new(api_user: SENDGRID_USERNAME, api_key: SENDGRID_PASSWORD)

# Make the email
mail = SendGrid::Mail.new do |m|
  m.to = 'aidan.campbell@gmail.com'
  m.from = 'taco@cat.limo'
  m.subject = 'Hello world!'
  m.text = 'I heard you like pineapple.'
end

# Send the email and report the status.
puts client.send(mail)
# {"message":"success"}