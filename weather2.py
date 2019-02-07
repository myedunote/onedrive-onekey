# coding=UTF-8
import requests
import json
 

def get_info(url):
	web_data = requests.get(url)
	result = web_data.text
	fin = json.loads(result)
	city = (fin["results"][0]["currentCity"])   
	pm = (fin["results"][0]["pm25"])   
	temperature = (fin["results"][0]["weather_data"][0]["temperature"])   
	weather = (fin["results"][0]["weather_data"][0]["weather"])   
	wind = (fin["results"][0]["weather_data"][0]["wind"])   
	return "天气预报：：亲爱的用户，{0}今天天气为{1}, 温度{2}，风向{3}, PM2.5浓度{4}".format(city,weather,temperature,wind,pm)

from twilio.rest import Client
account_sid = "AC85e89cf6781f2c09d4826d628901ed32"
auth_token = "6ca33638fb2210bf5d11e063edd6468c" 

client = Client(account_sid, auth_token) 

def send_sms(to_number, from_number, text):	
        message = client.messages.create(	    
          to = to_number, 
	      from_ = from_number,
	      body = text
        )
        print(message.sid)

from crawl_info import get_info
from text_sdk import send_sms
 
to_number="+8616670340886"     
from_number="+18572147652"         
 
if __name__ == '__main__':
	url = 'http://api.map.baidu.com/telematics/v3/weather?location=22.958839,113.443825&output=json&ak=PtBGUdObTzb9oCA1GHagO3pSwv3fYO6X'
	text = get_info(url)
	send_sms(to_number,from_number,text) 
