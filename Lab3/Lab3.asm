#######################################################################################################
# Created by: Imtiaz, Nayeel
#             naimtiaz
#             9 November 2020
#
# Assignment: Lab3 Introduction to MIPS
#             CSE 12 Computer Systems and Assembly Language
#             UC Santa Cruz, Fall 2020
# 
# Description: This lab takes user input and prints triangle with a height of whatever user inputted.
# 
# Notes: This program requires MARS IDE to run.
#######################################################################################################       

						# Psuedo code in Python
# prompt = "Enter the height of the pattern (must be greater than 0):\t"     ### prompt stored in a variable ###
# response = int(input(prompt))                                              ### program's first time asking user for input ###
# while True:
    # if response <= 0:   				        ### will keep asking for a valid input if not initially given a correct one ###         
        # print("Invalid Entry!")  				### error message ###
        # response = int(input(prompt))
    # else:
        # break                                               ### exit loop once valid response has been inputted ###

#  ### Set up of important variables ###
# tabs = response - 1
# number = 1
# num_stars = 1

# for i in range(1, response + 1):
    # print("\t"*tabs, end="")                        ### tabs printed at beginning of the row ###
    # print(number, end="")   			       ### first number printed in the row ###
    # number += 1
    # if i == 1:
        # print()
        # tabs -= 1
        # continue    				      ### first row doesn't have any asterisks, so go to next iteration ###
    # print("\t*" * num_stars, end="")
    # print("\t", end="")
    # print(number, end='')                          ### this is the second number that's printed in the row ###
    # print()
    # number += 1
    # num_stars += 2                                 ### number of stars increase by 2 after each row. ###
    # tabs -= 1                                      ### number of initial tabs changes based on what row program is on ###
#######################################################################################################################################

						# MIPS Assembly code
# REGISTER USAGE
# $s4: saves user's input
# $s0: number of tabs to print at beginning of each line
# $s1: number that is printed
# $s2: number of stars to print
# $t1: number of times biggestLoop iterated
# $t2: number of times tabLoop1 iterated in the line (counter restarts at the next level)
# $t3: number of times starTab loop interated in the line (counter restarts at the next level)

.text
PromptLoop:
	   li $v0 4          # prepares to print a string
           la $a0 prompt     # Loads prompt string into register $a0
           syscall           # prints the prompt

           li $v0 5          # prepares to ask user an integer to input
           syscall           # asks the user to input an integer and that value gets stored in $v0

           move $s4 $v0     # make a copy of what's in $v0 register and move the copy somewhere other than the syscall register
                            # s4 will save the user's original input (number of rows of triangle)
           
           bgt $s4 $zero exitInput           # only exit prompt loop if input is integer greater than 0
           li $v0 4                          # prepare to print a string
           la $a0 error_message	              # load the error message into $a0
           syscall                           # print the error message
           j PromptLoop                      # go to the top of the prompt loop

exitInput: 
          addi $s0 $s4 -1       # s0 is where number of tabs will be saved. Subtractings user's input by 1 to get number of tabs.
          li $s1 1	         # s1 is where number to be printed will be stored. expected to be incremented by 1 periodically
          li $s2 1	         # s2 is where numbers of stars will be tracked. will increase by 2 every row.
          li $t1 0	         # t1 saves number of times the big loop was done

biggestLoop:
            beq $t1 $s4 endOfBigLoop         # only exit the biggest loop if number of iterations equals the user's valid response
            li $t2 0	                      # t2 saves number of times tabLoop1 was done

tabLoop1:
         beq $t2 $s0 endTabLoop1 	# print tab space until $t2 and $s0 are equal
         li $v0 11                     # prepares to print an ascii character            
         li $a0 9                      # loads a horizontal tab space into argument register
         syscall                       # prints the tab space
         addi $t2 $t2 1	                # add 1 to tabLoop1 counter ($t2)
         j tabLoop1                    # go to top of tabLoop1

endTabLoop1:
            li $v0 1	        # preparing to print an integer
            move $a0 $s1	# made copy of current number to an argument register
            syscall		# printed an integer
            addi $s1 $s1 1	# increment current number by 1

            bne $t1 $zero continueTheLoop	# will only execute next few lines if in the first iteration
            li $v0 11	                       # preparing to print ascii character
            li $a0 10	                       # 10 is new line in ascii
            syscall                           # print a new line

            add $s0 $s0 -1	    # subtract number of tabs by 1
            addi $t1 $t1 1	    # add 1 to big loop counter
            j biggestLoop          # go to the beginning of the big loop.

continueTheLoop:
                li $t3 0           # t3 register saves number of times starTab loop iterated
                                   # this register is loaded to zero at each new row
                                   
starTabLoop:
            beq $t3 $s2 endOfStarTab	      # starTab loop will keep going until $t3 reaches the number stored in $s2
            li $v0 4			      # prepare to print string
            la $a0 starTab		      # load string with one tab and one star into argument register
            syscall                          # prints starTab string
            addi $t3 $t3 1	              # increment starTab loop counter by 1
            j starTabLoop                    # go to top of starTab loop

endOfStarTab:
             li $v0 11	         # preparing to print character
             li $a0 9	         # 9 in the ascii table is tab
             syscall		 # prints the tab character

             li $v0 1	         # preparing to print an integer
             move $a0 $s1	 # made copy of number we're on to argument register
             syscall		 # print the integer

             li $v0 11	         # preparing to print ascii character
             li $a0 10	         # loads new line character into argument register
             syscall 	         # prints new line

             addi $s1 $s1 1      # increments number we are on by 1
             addi $s2 $s2 2      # increments number of stars by 2
             addi $s0 $s0 -1     # subtracts number of tabs by 1

             addi $t1 $t1 1	  # increment biggest loop counter by 1
             j biggestLoop	  # go to the top of biggest loop

endOfBigLoop:
             li $v0 10	        # preparing to terminate the program
             syscall		# ends the program smoothly

.data
prompt:  .asciiz "Enter the height of the pattern (must be greater than 0):\t"	# prompt message is stored here
error_message:	.asciiz "Invalid Entry!\n"						# Invalid message stored here
starTab: .asciiz "\t*"									# string of a tab and a star stored here
