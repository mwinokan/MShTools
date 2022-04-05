#!/usr/bin/env python3

from random import sample

quotes = [
			"DO IT TOMORROW",
			"DO DFT TOMORROW",
			"HOW 'BOUT NAH",
			"STYLE OVER SUBSTANCE",
			"I'M NOT CHINESE",
			"TO DRIVE A TANK\nSIMPLY USE DRUIDRY\nTO TRANSFORM INTO\nA TANK DRIVER",
			"IF THE GAUSSIAN FAILS TWICE\nCONSECUTIVELY, GIVE UP",
			"THE FEWER HOURS YOU WORK ON A FIXED SALARY\nTHE HIGHER YOUR HOURLY PAY",
			"COMP. CHEM IS TEMPORARY.\nCONFUCIUS IS FOREVER",
			"BETTER TO ASK FOR FORGIVENESS THAN PERMISSION",
			"DO YOU THINK I WANT TO BE HERE?",
			"READ THE FUCKING MANUAL",
		]

quote = sample(quotes,1)

buff = 10

maxline=0

print('"'.rjust(buff+1),end='')
for i,line in enumerate(quote[0].split("\n")):
	if i > 0:
		print("\n"+" ".rjust(buff+1),end='')
	print(f'{line}',end='')
	if len(line) > maxline:
		maxline = len(line)
print('"',end='\n')

print("-CONFUCIUS".rjust(maxline+2+buff))
print('',end='\n')
