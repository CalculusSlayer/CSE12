#############################################################################
# Created by: Imtiaz, Nayeel
#             naimtiaz
#             7 December 2020
#
# Assignment: Lab 5: Graphics
#             CSE 12, Computer Systems and Assembly
#             UC Santa Cruz, Fall 2020
#
# Description: This program prints a graphical image to the bitmap display.
#
# Notes:       This program is intended to be run from a MARS IDE.
##############################################################################


#Fall 2020 CSE12 Lab5 Template File

## Macro that stores the value in %reg on the stack 
##  and moves the stack pointer.
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#  loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

# Macro that takes as input coordinates in the format
# (0x00XX00YY) and returns 0x000000XX in %x and 
# returns 0x000000YY in %y
.macro getCoordinates(%input %x %y)
       srl %x %input 16    # shift %input 16 bits to the right and put in %x
       sll %y %input 16    # shift %input 16 bits to left
       srl %y %y 16        # shift output of previous line 16 bits to the 
                           # right and put it in %y
.end_macro

# Macro that takes Coordinates in (%x,%y) where
# %x = 0x000000XX and %y= 0x000000YY and
# returns %output = (0x00XX00YY)
.macro formatCoordinates(%output %x %y)
       sll %output %x 16          # shift %output 16 bits to the left
       add %output %output %y     # add %y by result of previous line
.end_macro 


.data
originAddress: .word 0xFFFF0000

.text
j done
    
done: nop
	li $v0 10 
	syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
#Clear_bitmap: Given a color, will fill the bitmap display with that color.
#   Inputs:
#    $a0 = Color in format (0x00RRGGBB) 
#   Outputs:
#    No register outputs
#    Side-Effects: 
#    Colors the Bitmap display all the same color
#*****************************************************

#                               Clear_bitmap Pseudocode
# t0 = originAddress
# a0 = color
#
# for i in range(16384):
#       store a0 into (t0)
#       t0 += 4
# break
# *********************************************************************************
                               # Clear_bitmap MIPS Function
clear_bitmap: nop
              lw $t0 originAddress      # load the origin into $t0 register
              li $t1 0                  # loop counter for clearLoop

clearLoop:
           beq $t1 16384 doneClearLoop    # branch if $t1 equals 128^2 
           sw $a0 ($t0)                   # store color in current address
           addi $t0 $t0 4                 # increment current address by 4
           addi $t1 $t1 1                 # add 1 to clearLoop counter
           j clearLoop                    # jump to top of clear Loop
           
doneClearLoop:
 	      jr $ra         # exit function

#*****************************************************
# draw_pixel:
#  Given a coordinate in $a0, sets corresponding value
#  in memory to the color given by $a1	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#    $a1 = color of pixel in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#*****************************************************
#                   draw_pixel Pseudocode
# x = x coordinate
# y = y coordinate
# a = combined coordinates in form of 0x00XX00YY
# originAddress = 0xFFFF0000

# a = x, y [unpack tuple]
# result_offset = (128 * y + x) * 4
# pixel = originAddress + result_offset
# store color into pixel
# break

# *******************************************************
                       # draw_pixel MIPS Function
draw_pixel: nop
            getCoordinates($a0 $t0 $t1)   # get coordinates to point given in $a0
            mul $t2 $t1 128               # multiply $t1(y-coordinate) by 128
            add $t2 $t2 $t0               # add x-coordinate to $t2
            mul $t2 $t2 4                 # multiply by 4 b/c each word is 4 bytes
            lw $t9 originAddress          # load origin Address into $t9
            add $t2 $t2 $t9               # add $t2 and $t9
            sw $a1 ($t2)                  # store value of $a1 into ($t2)
	   
	    jr $ra                        # exit function
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#   Outputs:
#    Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
#                   get_pixel Pseudocode
# x = x coordinate
# y = y coordinate
# a = combined coordinates in form of 0x00XX00YY
# originAddress = 0xFFFF0000

# a = x, y  [unpack tuple]
# result_offset = (128 * y + x) * 4
# pixel = originAddress + result_offset
# load color from pixel
# break
#**********************************************************

                                   # get_pixel MIPS Function
get_pixel: nop
           getCoordinates($a0 $t0 $t1)    # get coordinates to point given in $a0
           mul $t2 $t1 128                # multiply 128 and $t1 and put into $t2
           add $t2 $t2 $t0                # add $t0 and $t2 together
           mul $t2 $t2 4                  # multiply $t2 by 4
           lw $t3 originAddress           # load originAdress into $t3
           add $t2 $t2 $t3                # add $t2 and $t3 together
           lw $v0 ($t2)                   # load ($t0) into $v0
           
           jr $ra                         # exit function

#*****************************************************
#draw_rect: Draws a rectangle on the bitmap display.
#	Inputs:
#		$a0 = coordinates of top left pixel in format (0x00XX00YY)
#		$a1 = width and height of rectangle in format (0x00WW00HH)
#		$a2 = color in format (0x00RRGGBB) 
#	Outputs:
#		No register outputs
#*****************************************************
                              # draw_rect Pseudocode
# x = x coordinate
# y = y coordinate
# a = combined coordinates in form of 0x00XX00YY
# b = combined coordinates in form of 0x00XX00YY (for finding change)
# originAddress = 0xFFFF0000

# a = x_initial, y_initial
# b = change_in_x, change, change_in_y

# a1 = a2
# for i in range(change_in_y):
#     push(x_initial)
#     for j in range(change_in_x):
#          push(return_address)
#          draw_pixel(a, a1)
#          pop(return(address)
#          a = x, y [unpack tuple]
#          x += 1
#          combine x and y into one variable
#     a = x, y
#     y += 1
#     pop(x_initial)
#     combine x_initial and y into one variable
#
# break
#*********************************************************

#                    # draw_rect MIPS Function
draw_rect: nop
           getCoordinates($a0 $t0 $t1)     # get coordinates of first pixel
           getCoordinates($a1 $t3 $t4)     # find out change of x and change of y

           move $a1 $a2     # move contents of register $a2 to $a1
           li $t5 0         # loop counter for y loop
           li $t6 0         # loop counter for x loop

yLoop:
       beq $t5 $t4 endYLoop      # branch to endYLoop if $t5 equals to $t4
       push($t0)                 # push $t0 to stack
       
xLoop:
       beq $t6 $t3 endXLoop           # branch to endXLoop if $t6 equals $t3
       push($ra)                      # push $ra to stack
       jal draw_pixel                 # jump to draw_pixel function
       pop($ra)                       # pop $ra from stack
       getCoordinates($a0 $t1 $t2)    # get coordinates of $a0
       addi $t1 $t1 1                 # increment x-coordinate by 1
       formatCoordinates($a0 $t1 $t2) # combine x and y coordinates into one hex value
       addi $t6 $t6 1                 # add 1 to xLoop counter
       j xLoop                        # jump to top of xLoop

endXLoop:
          getCoordinates($a0 $t1 $t2)     # get coordinates of $a0
          addi $t2 $t2 1                  # add 1 to $t2
          pop($t0)                        # pop $t0 from the stack
          formatCoordinates($a0 $t0 $t2)  # combine x and y coordinates into one hex value
          addi $t5 $t5 1                  # increment yLoop counter
          li $t6 0                        # reset xLoop counter
          j yLoop                         # jump to top of yLoop

endYLoop:
 	  jr $ra     # exit function

#***********************************************
# draw_diamond:
#  Draw diamond of given height peaking at given point.
#  Note: Assume given height is odd.
#-----------------------------------------------------
# draw_diamond(height, base_point_x, base_point_y)
# 	for (dy = 0; dy <= h; dy++)
# 		y = base_point_y + dy
#
# 		if dy <= h/2
# 			x_min = base_point_x - dy
# 			x_max = base_point_x + dy
# 		else
# 			x_min = base_point_x - floor(h/2) + (dy - ceil(h/2)) = base_point_x - h + dy
# 			x_max = base_point_x + floor(h/2) - (dy - ceil(h/2)) = base_point_x + h - dy
#
#   	for (x=x_min; x<=x_max; x++) 
# 			draw_diamond_pixels(x, y)
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of top point of diamond in format (0x00XX00YY)
#    $a1 = height of the diamond (must be odd integer)
#    $a2 = color in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#***************************************************
draw_diamond: nop
              getCoordinates($a0 $t7 $t8)  # t7 is x0 and t8 is y0
              move $t6 $a1                 # t6 is height         
              move $a1 $a2                 # move color argument to $a1
              li $t5 0                     # loop counter for dy loop (t5 = dy)

dyLoop:
        bgt $t5 $t6 end27          # branch if $t5 is greater than $t6
        add $t2 $t8 $t5            # t2 needs to go in stack

        move $t0 $t5               # move contents of $t5 to $t0
        mul $t0 $t0 2              # t0 is now "2dy"

        bgt $t0 $t6 elseDiamond    # branch to elseDiamond if $t0 is greater than $t6
        sub $t0 $t7 $t5            # t0 holds x_min temporarily
        add $t4 $t7 $t5            # t4 holds x_min during nested loop
        j realStuff                # jump to realStuff

elseDiamond:
             sub $t0 $t7 $t6          # subtract $t7 by $t6
             add $t0 $t0 $t5          # add $t0 and $t5

             add $t4 $t7 $t6          # add $t7 and $t6
             sub $t4 $t4 $t5          # subtract $t4 by $t5

realStuff:
           move $t3 $t0   # t3 is x and loop counter for finalLoop

finalLoop:
           bgt $t3 $t4 hotDogs              # branch if $t3 is greater than $t4
           formatCoordinates($a0 $t3 $t2)   # format coordinates
           push($ra)                        # push $ra to stack
           push($t2)                        # push $t2 to stack
           jal draw_pixel                   # jump to draw_pixel function
           pop($t2)                         # pop $t2 from stack
           pop($ra)                         # pop $ra from stack
           getCoordinates($a0 $t3 $t2)      # retrieve x and y coordinates
           addi $t3 $t3 1                   # add 1 to finalLoop counter
           j finalLoop                      # jump to top of finalLoop

hotDogs:
         addi $t5 $t5 1             # add 1 to dyLoop counter
         j dyLoop                   # jump to top of dyLoop

end27:
       jr $ra                       # exit function
	
