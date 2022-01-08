##################################################################################################
# Created by: Imtiaz, Nayeel
#             naimtiaz
#             26 November 2020
#             
# Assignment: Lab 4: Searching Hex
#             CSE 12, Computer Systems and Assembly Language
#             UC Santa Cruz, Fall 2020
#
# Description: This program takes up to 8 hexadecimal arguments, converts them to integers,
#              and prints out the max value.
#
# Notes:       This program is meant to be run by a MARS IDE.
###################################################################################################

###################################### PSEUDOCODE #################################################

# a0 = number of arguments
# a1 = current address of word
# a2 = current address of byte
# print( "Program Arguments: " )
# print( new line )

# integerLoop = 0
# for i in range(a0):
#     load word from address a1 into variable a2
#     while true:
#         load byte from address a2 into variable a3
#         if a3 != null character:
#             print a3
#             push a3 to stack
#             a2 += 1 (Adding 1 to address a2)
#     else:
#          break
#
#     popLoop counter = 0
#
#     while true:
#         pop a3 from stack
#         if a3 = "x":
#             break
#         else:
#             if a3 is 0-9:
#                 subtract a3 by 48
#             elif a3 is A-F:
#                 subtract a3 by 55
#
#             if loop counter = 2:
#                 multiply a3 by 256
#             elif loop counter = 1:
#                 multiply a3 by 16
#             elif loop counter = 0:
#                 multiply a3 by 1
#  
#             current_sum = current_sum + a3     
#             popLoop counter += 1      
#     
#      place current_sum in the address of a1
#      current_sum = 0

#      go to next word by adding address a1 by 4
#      integerLoop += 1
#      print space if integerLoop < a0
# 
# print new line 2x
# print( "Integer values:" )
# print new line
# go back to original a1 address
# secondLoop = 0
# for i in range(a0):
#     print(value stored inside of a1) [using special function]
#     if secondLoop < a0:
#         print(space)
#     
#     go to next word by adding 4 to address a1
#     secondLoop += 1
# 
# print new line 2x
# print( "Maximum Value" )
# print new line
# go back to original a1 address
# max = value inside of a1
# for i in range(a0 - 1):
#     if a1 >= max:
#         max = a1
#     go to next address by adding 4 to address a1
#
# print max (using special function)
# print new line

# special function to print integer (takes an integer and prints it using ascii characters)
# [ if integer >= 1000, floor divide integer by 1000.
#   elif integer >= 100, floor divide integer by 100
#   elif integer >= 10, floor divide integer by 10
#   elif integer >= 0, floor divide integer by 1
#   add integer by 48
#   print integer as ascii character
#   subtract integer by 48
#   integer = integer - resultOfFloorDivision * 1000/100/10/1 (depends on which branch)
#   repeat for other values in the original integer until all digits are printed
#   ignore leading 0's. For example print "100", not "0100". ]

############################################# MIPS ASEEMBLY CODE ########################################################################
# REGISTER USAGE
# $s5: integer loaded from memory/ argument for susCall function
# $s6: result of floor division
# $t0: number of arguments
# $t1: address of first argument
# $s1: integer loop counter
# $t2: register that holds a word
# $t3: register that holds a byte
# $s2: pop Loop counter
# $t4: holds the current sum
# $s3: Loop counter for Part B loop
# $s4: Loop counter for max Loop
# $t5: holds the current max value
# $t6: holds the next integer value

# These macros are all used for the function that replaces
# syscall 1. The function's name is "susCall".

.macro zero            # zero macro.
       li $v0 11       # prepare to print a character
       li $a0 48       # load a zero character into argument
       syscall         # print a zero
       .end_macro

.macro ones             # ones macro.
       move $s6 $s5     # make value equal to integer
       addi $s6 $s6 48  # add 48 to the value
       li $v0 11        # prepare to print a character
       move $a0 $s6     # move the value into argument register
       syscall          # print a value betweens 0 - 9 inclusive. this is a ones digit
       .end_macro

.macro tens              # tens macro
       div $s6 $s5 10    # does floor division. integer is floor divided by 10.
                         # register $s6 (value) is set to result of floor division.
       addi $s6 $s6 48   # add 48 to the value
       li $v0 11         # prepare to print a character
       move $a0 $s6      # make copy of value register to argument register
       syscall           # print a value from 0 - 9. this is a tens digit.
       subi $s6 $s6 48   # subtract 48 from the value
       mul $s6 $s6 10    # multiply value by 10
       sub $s5 $s5 $s6   # subtract integer by the value multiplied by 10 
                         # (multiplication already done in previous step)
       .end_macro

.macro hundreds          # hundreds macro
       div $s6 $s5 100   # does floor division. integer is floor divided by 100.
                         # register $s6 (value) is set to result of floor division.
       addi $s6 $s6 48   # add 48 to the value
       li $v0 11         # prepare to print a character
       move $a0 $s6      # make copy of value register to argument register
       syscall           # print a value from 0 - 9. this is a hundreds digit.
       subi $s6 $s6 48   # subtract 48 from the value
       mul $s6 $s6 100   # multiply value by 100
       sub $s5 $s5 $s6   # subtract integer by the value multiplied by 100
                         # (multiplication already done in previous step)
       .end_macro

.macro thousands
       div $s6 $s5 1000  # does floor division. integer is floor divided by 1000.
                         # register $s6 (value) is set to result of floor division.
       addi $s6 $s6 48   # add 48 to the value
       li $v0 11         # prepare to print a character
       move $a0 $s6      # make copy of value register to argument register
       syscall           # print a value from 0 - 9. this is a hundreds digit.
       subi $s6 $s6 48   # subtract 48 from the value
       mul $s6 $s6 1000  # multiply value by 1000
       sub $s5 $s5 $s6   # subtract integer by the value multiplied by 100
                         # (multiplication already done in previous step)
       .end_macro
       
# list of macros is over.      
       
.text
move $t0 $a0       # t0 is number of arguments given
move $t1 $a1       # t1 location of list of pointers. 
                   # these are saved in other registers b/c they'll be needed later
             
li $v0 4           # preparing to print a string
la $a0 string1     # load address of string into $a0.
syscall            # print string1

################################## Part 1 (Printing program arguments and hex to decimal conversions) #######################################

li $s1 0	# integer loop counter ($s1)

integerLoop:
            beq $t0 $s1 endInteger  # branch if number of arguments equals loop counter
            lw $t2 0($a1)	     # load word into register $t2    

byteLoop:
         lb $t3 0($t2)              # load byte into register $t3
         beq $t3 $zero endByteLoop  # branch if byte loaded is a null character 
         li $v0 11                  # prepare to print a character
         move $a0 $t3               # move contents of register $t3 to argument register
         syscall                    # print character that was in $t3 register

         subi $sp $sp 1             # make space for byte in stack
         sb $t3 0($sp)              # push byte
         addi $t2 $t2 1             # add 1 to move to the next byte
         j byteLoop                 # go back up to beginning of byteLoop

endByteLoop:
            li $s2 0                # loop counter for popLoop

popLoop:
        lb $t3 0($sp)               # pop byte
        addi $sp $sp 1              # remove byte space from stack
        beq $t3 120 here            # if byte is an 'x', then get out of the loop 

        blt $t3 60 numberCon        # branch if character is 0-9
        subi $t3 $t3 55             # subtraction for A - F
        j skipA                     # skip 0-9 conversion since character was already converted

numberCon:
          subi $t3 $t3 48           # subtraction for 0 - 9

skipA:
      blt $s2 2 uno                 # branch if popLoop is below 2
      sll $t3 $t3 8                 # multiply value in register $t3 by 256
      j cero                        # jump to cero label

uno:
    blt $s2 1 cero                  # branch if popLoop is below 1
    sll $t3 $t3 4                   # multiply value in register $t3 by 16

cero:
     add $t4 $t4 $t3                # add value in $t3 to current total ($t4)
     addi $s2 $s2 1                 # increment popLoop counter by one
     j popLoop                      # go back to top of popLoop
     
here:
     sw $t4 0($a1)                  # store the calculated total in address of current word
     li $t4 0                       # reset the current total to 0
     addi $a1 $a1 4                 # go to the next argument by adding 4 to $a1
     addi $s1 $s1 1		     # increment integer loop counter by 1

      beq $s1 $t0 skipSpace         # skip space if on the last program argument
      li $v0 11                     # prepare to print a character
      li $a0 32                     # load space into argument register
      syscall                       # prints a space

skipSpace:
          j integerLoop             # jump back up to top of integerLoop
          
endInteger:
           li $v0 4                 # prepare to print a string
           la $a0 string2           # load string2 into $a0 register
           syscall                  # print string2

####################################### Part 2 (Printing converted hex strings in decimal form) ###################################

move $a1 $t1           # move contents of $t1 back to $a1. 
li $s3 0               # $s3 is loop counter for part B loop
beqz $t0 finishPartB   # branch to finishPartB if no arguments

partBLoop:
          beq $t0 $s3 finishPartB        # branch if number of arguments equals partBLoop counter
          lw $s5 0($a1)                  # load integer stored in memory into $s5 register
          jal susCall                    # jump to susCall function. 
                                         # This is to avoid using syscall 1.

          addi $s3 $s3 1            # increment partBLoop counter by 1
          addi $a1 $a1 4            # go to the next word where next integer is stored

          beq $s3 $t0 skipSpace2    # skip space if on the last integer to print
          li $v0 11                 # prepare to print a character
          li $a0 32                 # load space into $a0 register
          syscall		     # prints a space

skipSpace2:
           j partBLoop              # go back to beginning of partBLoop
           
finishPartB:
            li $v0 4                # prepare to print a string
            la $a0 string3          # load string 3 into $a0 register
            syscall                 # print string 3

######################################### Part 3 (print the max value) ##########################################################3

move $a1 $t1    # move original address of first word back to $a1
beqz $t0 theEnd # don't print any max value if 0 arguments

li $s4 1      # loop counter for maxLoop
lw $t5 0($a1) # t5 will hold the maximum value. automatically store first integer in t5

maxLoop:
        beq $s4 $t0 printMax         # branch when maxLoop ocunter equals the number of arguments
        addi $a1 $a1 4               # go to the next integer
        lw $t6 0($a1)                # load the next integer into register $t6
        bgt $t5 $t6 replaceNot       # branch if value in $t5 is greater than value in $t6
        move $t5 $t6                 # move value of $t6 into $t5

replaceNot:
           addi $s4 $s4 1            # add 1 to maxLoop counter
           j maxLoop                 # jump to top of maxLoop

printMax:
         move $s5 $t5    # make copy of register $t5 to $s5
         jal susCall     # jump to function that replaces syscall 1

theEnd:
       li $v0 11      # prepare to print ascii character
       li $a0 10      # load new line character into $a0
       syscall        # print new line

       li $v0 10      # prepare to end the program
       syscall        # end the program

############################################ This Function over here replaces Syscall 1. ########################################

susCall:                             
        blt $s5 1000 hundredZone         # branch to hundredZone if $s5 is less than 1000
        thousands                        # execute thousands macro
        blt $s5 100 else1                # branch if $s5 is less than 100
        hundreds                         # execute hundreds macro
        j destination1                   # jump to destination1

else1:
      zero                                    # execute zero macro

destination1:
             blt $s5 10 else2                 # branch is $s5 is less than 10
             tens                             # execute tens macro
             j destination2                   # jump to destination2

else2:
      zero                                    # execute zero macro

destination2:
             ones                             # execute ones macro
             j endSusCall                     # jump to endSusCall

hundredZone:
            blt $s5 100 tenZone             # branch to tenZone if $s5 less than 100
            hundreds                        # execute hundreds macro
            blt $s5 10 else3                # branch if $s5 is less than 10
            tens                            # execute tens macro
            j endOfHundredZone              # jump to endOfHundredZone

else3:
      zero                            # execute zero macro

endOfHundredZone:
                 ones                 # execute ones macro
                 j endSusCall         # jump to endSusCall

tenZone:
        blt $s5 10 oneZone            # branch if $s5 is less than 10
        tens                          # execute tens macro
        ones                          # esecute ones macro
        j endSusCall                  # jump to endSusCall

oneZone:
        ones                          # execute ones macro

endSusCall:
           jr $ra    # jump back to return address

######################################## end of susCall function.#####################################################

.data
string1: .asciiz "Program arguments:\n"      # print first string
string2: .asciiz "\n\nInteger values:\n"     # print second string
string3: .asciiz "\n\nMaximum value:\n"      # print third string
