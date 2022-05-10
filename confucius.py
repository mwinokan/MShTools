#!/usr/bin/env python3

from random import sample

bold="\033[1m"
clear="\033[0m"

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
			"I WOULDN'T BET MY LIFE ON IT",
			"DEATH DOES NOT PROTECT YOU FROM CRITICISM",
			"SOMETIMES YOU HAVE TO SPEND MONEY TO MAKE MONEY.\n\nSOMETIMES YOU HAVE TO SPEND MONEY TO LOSE MONEY.\n\nONE THING IS FOR CERTAIN, YOU HAVE TO SPEND MONEY.",
			"PREMATURE JOB FAILURE IS NOTHING TO BE ASHAMED OF",
			"LOUIE TOLD ME WHAT TO DO\nAND I DID MY BEST TO FUCK IT UP",
			"IT IS IMPOSSIBLE TO REVERSE\nTHE CREATION OF A CAKE",
			"CAKE CAN BE CREATED AND DESTROYED",
			"I CAN HEAR BUT I CAN'T LISTEN",
			"I'M BETTER THAN THE MANUAL",
			"BEFORE TRYING, CONSULT ME",
			"CODE FIRST, THINK LATER",
			"WHEN IN DOUBT, CROSS PRODUCT",
			f"CHEMIS{bold}DO{clear} OR CHEMIS{bold}DON'T{clear}\nTHERE IS NO CHEMIS{bold}TRY{clear}",
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
