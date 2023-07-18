import urllib.request
import json
import datetime
import random
import string
import time
import os
import sys
os.system("title WARP-PLUS-CLOUDFLARE By ALIILAPRO")
os.system('cls' if os.name == 'nt' else 'clear')
tool_title = ""
tool_title += "############################################"
tool_title += "\n[#] WARP-PLUS-CLOUDFLARE"
tool_title += "\n############################################"
tool_title += "\n[-] Original Script By: aliilapro.github.io"
tool_title += "\n[-] Version: 4.0.0"
tool_title += "\n--------------------------------------------"
print (tool_title)
referrer = ""
if len(sys.argv) > 1:
	referrer = sys.argv[1]
else:
	referrer = input("[#] Enter the WARP ID: ")

os.system('cls' if os.name == 'nt' else 'clear')
print(tool_title)
print(f"[#] Working with WARP ID: {referrer}")

def genString(stringLength):
	try:
		letters = string.ascii_letters + string.digits
		return ''.join(random.choice(letters) for i in range(stringLength))
	except Exception as error:
		print(error)
def digitString(stringLength):
	try:
		digit = string.digits
		return ''.join((random.choice(digit) for i in range(stringLength)))    
	except Exception as error:
		print(error)
url = f'https://api.cloudflareclient.com/v0a{digitString(3)}/reg'
def run():
	try:
		install_id = genString(22)
		body = {"key": "{}=".format(genString(43)),
				"install_id": install_id,
				"fcm_token": "{}:APA91b{}".format(install_id, genString(134)),
				"referrer": referrer,
				"warp_enabled": False,
				"tos": datetime.datetime.now().isoformat()[:-3] + "+02:00",
				"type": "Android",
				"locale": "es_ES"}
		data = json.dumps(body).encode('utf8')
		headers = {'Content-Type': 'application/json; charset=UTF-8',
					'Host': 'api.cloudflareclient.com',
					'Connection': 'Keep-Alive',
					'Accept-Encoding': 'gzip',
					'User-Agent': 'okhttp/3.12.1'
					}
		req         = urllib.request.Request(url, data, headers)
		response    = urllib.request.urlopen(req)
		status_code = response.getcode()	
		return status_code
	except Exception as error:
		print(error)	

g = 0
b = 0
while True:
	os.system('cls' if os.name == 'nt' else 'clear')
	print(tool_title)
	print(f"[#] WORK ON ID: {referrer}")
	animation = ["[■□□□□□□□□□] 10%","[■■□□□□□□□□] 20%", "[■■■□□□□□□□] 30%", "[■■■■□□□□□□] 40%", "[■■■■■□□□□□] 50%", "[■■■■■■□□□□] 60%", "[■■■■■■■□□□] 70%", "[■■■■■■■■□□] 80%", "[■■■■■■■■■□] 90%", "[■■■■■■■■■■] 100%"] 
	for i in range(len(animation)):
		time.sleep(0.2)
		sys.stdout.write("\r[-] Preparing... " + animation[i % len(animation)])
		sys.stdout.flush()

	result = run()

	os.system('cls' if os.name == 'nt' else 'clear')
	print(tool_title)
	print(f"[#] WORK ON ID: {referrer}")

	result_message = ""
	timeSleep = 2
	if result == 200:
		g = g + 1
		result_message = "[:)] " + str(g) + " GB has been successfully added to your account."
		timeSleep = 18
	else:
		b = b + 1
		result_message = "[:(] Error when connecting to server."
    
	result_message += "\n[-] Total: "+str(g)+" Good "+str(b)+" Bad"
	result_message += "\n[*] After "+str(timeSleep)+" seconds, a new request will be sent."
	print(result_message)
	time.sleep(timeSleep)
