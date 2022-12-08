#!/usr/bin/env python3

'''

To-Do's

- 	make a persistent random list that is iterated through sequentially,
	when the end of the list is reached, rebuild the list

-	display a warning if the script is greatly out of date

'''

from random import sample,shuffle
import sys

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
			f"OH MY {bold}GOODNESS{clear}",
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
			"NOT F*CK YO MAMA\n\nF*CK YO-YO MA!",
			"I FORGOT ABOUT THE PASSAGE OF TIME",
			"EVERYTHING IS JUST A BIG WEIRD LIGAND",
			"IT NEEDS TO TASTE GOOD, AND KILL YOU",
			"MY ABILITY TO SEE FUNKINESS REQUIRES EXPERIENCE",
			"HISTIDINE IS A PROBLEM",
			"I HATE THE FACT THAT THEY SPENT SO MUCH TIME ON THESE QUOTES,\nINSTEAD OF IMPROVING THEIR SIMULATION SOFTWARE",
			"BUTTER MUSS SEIN",
			"I DON’T NEED A CONTROL BECAUSE I DON’T HAVE ANY RESULTS",
			"LET THE ANIMAL EAT FIBRE,\nAND THEN EAT THE ANIMAL",
			"THAT’S NOT A SHOT MATE!!",
			"FUCK AROUND AND FIND OUT",
			f"♫♬♪{bold}OH MON BEBE{clear}♫♬♪",
			"WHY DID TOM CHEATHAM KILL US LAST NIGHT?",
			"NOSE-HOOVER? SO LIKE A COCAINE ADDICT?",
			"YOU CAN SLEEP ON A BANANA",
			"AMBER AND I BROKE UP",
			"WE WENT TOO FAR",
			"THEY GOT JIGGLY PHYSICS?",
			"DO YOU WANT TO SEE MY STUFF JIGGLING?",
			"WE DON’T SEE COLOURS HERE,\nWE JUST SEE BALLS",
			"IN MY OPINION THIS IS EXACTLY\nWHAT IS WRONG WITH SCIENCE",
			"I DIDN’T REALISE YOU WERE A NONCE",
			"I HEARD YOU LIKE FINISHING EARLY",
			"JOIN THE QUANTUM BIOLOGY DISCORD SERVER! #GAMERSRISEUP",
			"WE SHOULD GET SOMETHING VENOMOUS LIKE A PLATYPUS",
			"THERE IS TOO MUCH ON YOUTUBE ABOUT PLATYPUS CUSTARD",
			"I DON'T BELIEVE IN GRANDCHILDREN",
			"WINNING IS NEVER AN OPTION, ONLY REVENGE",
			"FEDERICO’S ALLEYWAY BOUQUET",
			"SENT FROM MY GALAXY",
			"  _______\n /  12   \\ \n|    |    |\n|9   |   3|\n|     \\   |\n|         |\n \\___6___/\n\nGOOD HEAVENS, LOOK AT THE TIME!",
			"Har🌳-Frick ✝️ ",
			"BRANEURISM\n\nSymptoms:\tlight-headed, delirium,\n\t\tdyslexic, autism,\n\t\t\t\tchicken sounds,\n\t\t\t\tflowcharts\n",
            f"       LISTEN TO PHAT BRAHMS\n        |                   \\\n        V                    \\\n    EAT KATSU                 \\     IS IT FRIDAY? ----> WAIT\n        |                      \\        | Yes  ^   No     |\n        V                       \\       V      L-----------\n    SPIN MESMERISING SPIN ORB   |   IS HILLSIDE OPEN? ---> KATSU\n        |                       |       |           \n        V                       ^       V            \n    {bold}BRANEURYSM{clear}                  |   IS YOUNG'S OPEN ---> KATSU\n      /     \\                   |       |       \n     /YES    \\                  |       V\n    L         NO------->--------|   IS MAX IN THE OFFICE?\nKATSU COMA                      |       | Yes       \\ No\n                                ----<----            \\\n                                                    END THE DAY\n",
            "I WOULDN’T PAY £100 FOR A WET DREAM,\nFOR £100 I CAN GET A WET REALITY",
            "I KNOW YOUR FUTURE…\n\nBUT I’LL TELL YOU AFTER I GO TO THE LOO",
            "YOU ARE HEADING FOR A SMACK",
			F"{bold}F*CK!!! WHY ARE THESE GUYS SUCH *$#@'S?!{clear}\n\n...\n\nI NEED ANOTHER COFFEE, I'M NOT ON EDGE ENOUGH.",
			"RESULTS ARE A SOCIAL CONSTRUCT",
			"AUTISOMANCY",
			"IS A HANGING MAN STANDING ON\nA BOX THAT HE IS HOLDING\nBENEATH HIS FEET A\nPERPETUAL MOTION MACHINE?",
			"HAVE YOU READ KARL MARX'S LATEST TWEET?",
			"WE NEED MORE GAY SCIENCE",
			"IF WE OVERCOME THIS I WILL JERK FROM NOW UNTIL THE NEXT YEAR",
			"DO LOOK A THIEVING STUFFED DOUGHNUT IN THE ASS",
			"YOU'RE NOT HUMAN UNTIL YOU'VE BEEN CITED",
			f"TRUE {bold}AND{clear} FALSE",
			"EINSTEIN? LARGELY A B*TCH",
			"I’M SCARED TO GO TO TEXAS, PEOPLE JUST SHOOTING ME",
			"YOU’RE WRONG WITH THAT, YOU’RE ABSOLUTELY WRONG WITH THAT",
			"WE SHOULD GET AN OFFICE DILDO",
			"AIDS SALIVA IS A-OK\nSO YOU CAN GIVE THAT WHISTLE A SUCK",
			"NO ONE EVER SAID NOT TO EAT YELLOW RICE",
			"WALRUSES RAPING PENGUINS FOR REASONS THAT ARE NOT YET CLEAR",
			"THEY NEVER SAID DON'T EAT YELLOW RICE",
			"RUINING PEOPLE'S CAREERS BY KEEPING THEM IN THE SAME PLACE\nJUST BECAUSE I DID",
			"WHEN I FIRST STARTED LECTURING\nI DID A LOT OF BUM WIGGLING",
			"I DON'T UNDERSTAND HAVING VALUES",
			"PISS",
			"THAT'S THE ONLY REASON I'M NOT\nEATING YOUR FACE OFF RIGHT NOW",
			"DOUBLE-TEAMED BY GERIATRICS",
			"LIMPINGCHAN",
			"LET'S HAVE A QUICK CHAT?\nI NEED TO VENT SOME ANGER!",
			"THE FRENCHMAN BURNS EASILY",
			"WHY IS THE BROWN ALWAYS CAUSING PROBLEMS",
			"QUANTUM NATIONALISM",
			"THERE IS NO SUCH THING AS TIME",
			"IS OUR BANANA CORRECT?",
			"WOULD YOU RATHER:\n\nWALLACE HAMMERING FOR AN HOUR\n\nOR\n\nA BRIEF AL-QAEDA MOMENT?",
			"THE CONSPIRACY GROWS",
			"YOU'RE LOOKING GUILTIER BY THE SECOND",
			"I HAD TO MAKE SOMETHING, BUT I ONLY DESTROY",
			"QUANTUM CRY FOR HELP",
			"QB SOS",
			"UNFORUNATELY THE JAVA VERSION ON EUREKA IS TOO OLD TO RUN MINECRAFT",
			"NOBODY CARES, ESPECIALLY ME",
			"GEOGRAPHICALLY-CHALLENGED",
			"I GUESS THAT'S ONE GOOD THING ABOUT FASCISTS",
			"TESTICLES HAVE SO MUCH POTENTIAL",
			"WHENEVER IN DOUBT, GIVE LOUIE A SHOUT",
			"IF IN MOGADISHU, TELL LOUIE 'I MISS YOU'",
			"IF YOU'RE IN A PICKLE,\nGIVE LOUIE A TICKLE",
			"DOORS - UNLIKE PEOPLE - CAN BE UNFUCKED",
			"ARE YOU GOING TO GO TO HIS OFFICE, LIFT HIS ARMS UP\nAND GET YOUR FINGERS IN THERE?",
			"I CANNOT RIPEN MY OWN BANANA",
			"I DO BELIEVE!",
			"GREAT MINDS THINK THE SAME JUNK",
			"""HI EVERYONE.\nHOW DO YOU KEEP WORKING WITH A COLLABORATOR IF\nYOUR LAST MEETING ENDED WITH YOU SAYING\n\n"SPARE ME THIS USELESS AND AGGRESSIVE RHETORIC,\n'CAUSE I DON'T NEED IT, OR CARE ABOUT IT"?""",
			"LUCKILY SCIENCE AND DFT CALCULATIONS,\nDO NOT CARE ABOUT YOUR IMPRESSION OF THEM",
		]

def main():

	if len(sys.argv) > 1:
		if sys.argv[1] == '-l':
			import time
			indices = [i for i in range(len(quotes))]
			shuffle(indices)
			for index in indices:
				try:
					show_quote(index)
					time.sleep(3)
				except KeyboardInterrupt:
					print("\nGoodbye!")
					break
		elif sys.argv[1] == '-h':
			print(f"\n{inverse}{bold} CONFUCIUS {clear}{inverse} Office Wisdom (TM) {clear}\n")
			print(f"{bold}confucius.py{blue}{clear}          print a quote")
			print(f"{bold}confucius.py{blue} -h{clear}       show this screen")
			print(f"{bold}confucius.py{blue} <NUM>{clear}    show specific quote")
			print(f"{bold}confucius.py{blue} -l{clear}       loop forever")
			print(f"{bold}confucius.py{blue} <STRING>{clear} search for quotes\n")
		else:
			try:
				index = int(sys.argv[1])
				show_quote(index)
			except ValueError:
				if len(sys.argv) > 2:
					search = ' '.join(sys.argv[1:])
				else:
					search = str(sys.argv[1])
				import re
				indices = [i+1 for i,q in enumerate(quotes) if re.search(search,q, re.IGNORECASE)]
				for i in indices:
					show_quote(index=i)
	else:
		show_quote()

def show_quote(index=None):

	buff = 10
	maxline=0

	print("\n"+'"'.rjust(buff+1),end='')

	if index is not None:
		try:
			quote = quotes[index-1]
			# index = index-1
			index = quotes.index(quote)
		except IndexError:
			index = len(quotes)
			quote = quotes[index-1]
			index = quotes.index(quote)
	else:
		quote = sample(quotes,1)[0]
		index = quotes.index(quote)

	lines = quote.split("\n")

	for i,line in enumerate(lines):
		if i > 0:
			print("\n"+" ".rjust(buff+1),end='')
		if line.startswith("###SPICY###"):
			for character in line[11:]:
				print(f'{sample(spicy_formats,1)[0]}{character}{clear}',end='')
		else:
			print(f'{line}',end='')
		if len(line) > maxline:
			maxline = len(line)
	
	if len(lines) == 1 and maxline < 15:
		print('"\033[3m'+f"  -CONFUCIUS #{index+1}\033[0m\n")
	else:
		print('"\n\033[3m'+f"-CONFUCIUS #{index+1}".rjust(maxline+2+buff)+"\033[0m\n")

if __name__ == '__main__':
	main()
