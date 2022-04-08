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
			"NEVER GIVE A COW\nFREE MILK",
			"FOR BETTER OR FOR WORSE\nI'LL ALWAYS HAVE ANOTHER COFFEE",
			"I'M A BIG PROPONENT FOR HAVING FUN",
		]

buff = 10
maxline=0

print("\n"+'"'.rjust(buff+1),end='')
for i,line in enumerate(sample(quotes,1)[0].split("\n")):
	if i > 0:
		print("\n"+" ".rjust(buff+1),end='')
	print(f'{line}',end='')
	if len(line) > maxline:
		maxline = len(line)
print('"\n\033[3m'+"-CONFUCIUS".rjust(maxline+2+buff)+"\033[0m\n")
