class = dofile('getsmscode.lua')

local api = class:new('genmarcogrensai@gmail.com', '1a36718cd246b2ee7afc1f6d087e6c41') --username = email, token can be found on the homepage @ getsmscode.com
print('My balance is: '..api:get_balance()) --echo balance

--get a chinese (+86) number for Telegram
number = api:get_number(10, 'cn')
print('Requested phone number is +'..number)
--loop until an sms received
print('Waiting code...')
sms = api:get_sms(number, 10, 'cn')
while not sms do
    api:sleep(5)
    sms = api:get_sms(number, 10, 'cn')
end
--print the received sms
print('Got sms: '..tostring(sms))

--get a brazil (+55) number for Telegram
number = api:get_number(10, 'br')
print('Requested phone number is +'..tostring(number))
--loop until an sms received
print('Waiting code...')
sms = api:get_sms(number, 10, 'br')
while not sms do
    api:sleep(5)
    sms = api:get_sms(number, 10, 'br')
end
--print the received sms
print('Got sms: '..tostring(sms))
