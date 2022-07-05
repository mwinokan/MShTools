#!/usr/bin/env python3

from random import sample

bold="\033[1m"
clear="\033[0m"
inverse="\033[7m"
underline="\033[4m"
blue="\033[34m"
white="\033[37m"

spicy_formats=[bold+blue,underline,bold]

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
			"I HATE IT HERE",
			"I DIDN'T SIGN UP FOR THIS",
			"I DON'T UNDERSTAND WHY PEOPLE\nWOULD CHOOSE TO BE A BIOLOGIST",
			"I HATE PAST ME",
			"SOUNDS LIKE A FUTURE ME PROBLEM",
			"I STRUGGLE TO FIND PEACE",
			"I HEREBY CLASSIFY THIS AS A ROYAL BALL ACHE",
			"I'M ALL OUT OF PASSION",
			"WHAT IS A DECIMAL PLACE BETWEEN FRIENDS?",
			"###SPICY###OF COURSE",
			f"\u001b[37;44;1m 🇬🇷  OF COURSE {clear}",
			"ΩΦ KΩΥΡΣΕ",
			"FRENCH? SO YOU'RE EASY TO SATISFY",
			"YOU DON'T WANT TO FINISH TOO EARLY",
			"BOLD AND UNPROVEN",
			"WHERE IS MY GIRAFFE??",
			"THIS IS A HIPPOPOTAMUS",
			"MONOGAMOUS ENTANGLEMENT",
			"INVEST IN A STRAP-ON",
			"###SPICY###FRIZZ OFF",
			"I'M FRIZZED OFF",
			"I'M GONNA GO TO THAT BUS STATION TOMORROW\nAND KICK MIKE'S ASS",
			"STRUGGLING FROM SUCCESS",
			"I'D SHOW YOU MINE;\nBUT I DON'T THINK YOU'D LIKE IT",
			"I'M SEVERAL RAKI'S DEEP",
			"DON'T ASK ME QUESTIONS THAT COULD HAVE CONSEQUENCES",
			"ENORMOUS DRAGON OF FAECES,\nDANCING INSIDE ME",
			"I HAD A CRISIS OF FAITH IN MY RESEARCH,\nBUT THEN I REALISED THAT IT'S FINE",
			"IT DEPENDS",
			"KIND OF A PROOF",
			"THE DEAD CAT CAN BE A RESOURCE",
			"WITH A TALK LIKE THAT YOU CAN EXPECT TO MEET A PERSON\nWHO TOTALLY DISAGREES WITH EVERYTHING YOU SAID.\nYOU WILL FIND THAT PERSON IN ME",
			"MIDNIGHT MEAT",
			"EXISTENCE IS CANCER",
			"IT'S A PITY THEY FOUND A CURE FOR LEPROSY",
			"###SPICY###MEOW",
			"DON’T KNOW\nDON’T CARE",
			"INTERESTING TRANSFER DOWN THESE RODS",
			# "DISSEMINATE THROUGHOUT THE UK",
			"DUMPING MY PUMP ON",
			"KINDA TOXIC, BUT DON’T WORRY ABOUT THAT",
			"WHACKING GREAT ABSORBER",
			"I KNOW YOU’RE THEORISTS, AND THIS IS VERY MUDDY",
			"I HAVE A PROPENSITY FOR THE DENSITY",
			"OH MY {bold}GOODNESS{clear}",
			"YOU ARE UNDERMINING MY AUTHORITY",
			"TO BE WEAK, IS ACTUALLY AN ADVANTAGE ",
			"SPEEDY BOARDING",
			"THE PHILOSOPHICAL SIGNIFICANCE OF POO",
			"THE CAFFEINE IS A MATTER OF LIFE AND DEATH ",
			"IT’S ALMOST CERTAINLY WRONG, BUT FUN",
			"THAT WOULD HAVE BEEN WISE,\nHOWEVER,\nI AM NOT A WISE MAN",
			"THAT MAKES YOU THINK SOFT",
			"I WOULD ARGUE THAT BARE LEGS IS BETTER",
			"ANYTHING IS MICROSCOPIC IF IT’S FAR AWAY ENOUGH",
			"AN ERROR OCCURRED,\nHOW IS THAT EVEN SCIENTIFICALLY POSSIBLE",
			"YOU HEAR THAT?\nTHAT’S A TARDIGRADE",
			"I SEEM TO HAVE LOST CONTROL [OF MY MOUSE]",
			"THERE’S NO ANSWER,\nBY THE WAY",
			"BECAUSE OF SOME PHYSICS ",
			"PSEUDO-WEAK",
			"THESE BALLS ARE JUST REGULAR SHINY",
			"THE LAST COUP KIND OF FIZZLED OUT",
			"I THINK IT’S STRAIGHT SO IT MUST BE ERADICATED",
			"KOBE BEEF IS ALSO FAMOUSLY DEAD COW",
			"I’VE ALSO DECIDED I AM NOT A MORAL PERSON",
			"IT WAS ONLY AN EMPTY THREAT",
			"THREATS ARE A PART OF WORKING LIFE",
			"WELL THE THREAT WORKED!",
			"AN EMPTY THREAT IS STILL A THREAT",
			"WHAT DO YOU THINK I’M SOME SORT OF PEPSI CRACK WHORE?",
			"LOW IMPACT FACTOR?\nI WANT LOW IMPACT ON MY LIFE!",
		]

buff = 10
maxline=0

print("\n"+'"'.rjust(buff+1),end='')

for i,line in enumerate(sample(quotes,1)[0].split("\n")):
	if i > 0:
		print("\n"+" ".rjust(buff+1),end='')
	if line.startswith("###SPICY###"):
		for character in line[11:]:
			print(f'{sample(spicy_formats,1)[0]}{character}{clear}',end='')
	else:
		print(f'{line}',end='')
	if len(line) > maxline:
		maxline = len(line)
print('"\n\033[3m'+"-CONFUCIUS".rjust(maxline+2+buff)+"\033[0m\n")
