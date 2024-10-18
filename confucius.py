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
			"I AM DEAD",
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
