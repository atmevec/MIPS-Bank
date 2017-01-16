############## BankOfMIPS.asm #################
# Alexander Mevec                             #
# BankOfMIPS.asm                              #
# Description                                 #
#     Program prompts for bank name           #
#     Program prompts for input with menu     #
#     Program branches to appropriate action: #
#        DispTot- displays the total funds    #
#        AddFund- adds funds to the account   #
#        NewAcc- deletes account/starts over  #
#        WithFund- withdraws funds from acc   #
#        Exit- exits the bank program         #
#     Program branches back to the menu       #
#                                             #
#                                             #
# Allows a user to open an account, deposit   #
# funds, withdraw funds, checks for           #
# overdrafting and applies a fee/freeze on    #
# withdrawing, allows printing of a report,   #
# restarting fresh with a new account, and    #
# exiting the program.                        #
#                                             #
#                                             #
# Program Logic                               #
# 1.  display a message from data area        #
# 2.  store input                             #
# 3.  display menu from data area             #
# 4.  store input and branch to option        #
# 5.  ANY OF THE BELOW:                       #
#      DispTot) display the name and balance  #
#      AddFund) add funds to the balance      #
#      NewAcc) start from the beginning       #
#      WithFund) remove funds from balance    #
#      Exit) jump to eop                      #
# 6.  return to menu                          #
#                                             #
# Registers -                                 #
# t0 = total amount                           #
# t1 = overdrafted or not                     #
# t2 = menu choice                            #
# t3 = temp deposited or withdrawn value      #
###############################################

        .text
        .globl __start
__start:
	
	la $a0,welcome #display the welcome message
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	li $t0,0         # Initialize total to 0

	li $t1,1         # Initialize overdrafted to false

	jal clear        # Add space for the next output

        la $a0,p1        # Display the message in p1
        li $v0,4         # v0 = 4 indicates display a string
        syscall          # Call to system

	la $a0,name      # load message space into a0
	li $a1,20        # load the size of the string available in a0
	li $v0,8         # v0 = 8, indicates read a string
	syscall          # Call to system

	jal clear        # Add space for the next output

menu:	la $a0,menu1     # Display the menu
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	la $a0,menu2     # Display the menu
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	la $a0,menu3     # Display the menu
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	la $a0,menu4     # Display the menu
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	la $a0,menu5     # Display the menu
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	li $v0,5         # v0 = 5 indicates read an int
	syscall          # Call to system

	move $t2,$v0     # Move v0 to t2

	beq $t2,5,EOP    # If t2 = 5 go to EOP

	jal clear        # Add space for the next output

	beq $t2,4,__start # If t2 = 4 go to new

	beq $t2,3,output # If t2 = 3 go to output

	beq $t2,2,withdraw # If t2 = 2 go to withdraw

	beq $t2,1,deposit # If t2 = 1 go to deposit

output: la $a0,header    # Display the message in header
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	la $a0,name      # Display the message in name
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	la $a0,p2        # Display the message in p2
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	la $a0,standing  # Display the message in standing
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	beq $t1,1,safe

	beqz $t1,unsafe

safe:	la $a0,safeP     # Display the message in safeP
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	la $a0,total     # Display the message in total
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	move $a0,$t0     # Display the total in t0
	li $v0,1         # v0 = 1 indicates display an int
	syscall          # Call to system

	jal clear        # Add space for the next output

	j menu           # Jump back to the menu

unsafe: la $a0,unsafeP   # Display the message in unsafeP
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	la $a0,total     # Display the message in total
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	move $a0,$t0     # Display the total in t1
	li $v0,1         # v0 = 1 indicates display an int
	syscall          # Call to system

	jal clear        # Add space for the next output

	j menu           # Jump back to the menu

withdraw:
	jal clear        # Add space for the next output

	beqz $t1,overdrafted # If overdrafted then alert them

	la $a0,withdr    # Display the message in withdr
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	li $v0,5         # v0 = 5 indicates read an int
	syscall          # Call to system

	bltz $v0,oopsW   # If v0 < 0 tell them they can't do that 

	sub $t0,$t0,$v0  # Withdraw the funds

	move $t3,$v0     # Save the withdrawn amount

	la $a0,successw  # Display the message in successw
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	move $a0,$t3     # Display the withdrawn amount
	li $v0,1         # v0 = 1 indicates display an int
	syscall          # Call to system

	jal clear        # Add space for the next output

	bltz $t0,overCalc # If overdrafted then set the overdraft values

	j menu           # Jump back to the menu

deposit:
	la $a0,dep       # Display the message in dep
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	li $v0,5         # v0 = 5 indicates read an int
	syscall          # Call to system

	bltz $v0,oopsD   # If v0 < 0 tell them they can't do that 

	add $t0,$v0,$t0  # Deposit the money

	move $t3,$v0     # Save the deposited amount

	la $a0,successd  # Display the message in successd
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	move $a0,$t3     # Display the deposited amount
	li $v0,1         # v0 = 1 indicates display an int
	syscall          # Call to system

	jal clear        # Add space for the next output

	bgez $t0,gstand  # If they have a positive balance set their standing to good

	j menu           # Jump back to the menu


gstand: li $t1,1         # Set the overdrafted register to false

	j menu

oopsD:  la $a0,faild     # Display the message in faild
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	j deposit        # Jump back to deposit

oopsW:  la $a0,failw     # Display the message in failw
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	j withdraw       # Jump back to deposit

overdrafted:
	la $a0,overdraft # Display the message in overdraft
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	move $a0,$t0     # Display the total in t0
	li $v0,1         # v0 = 4 indicates display a string
	syscall          # Call to system

	la $a0,over1     # Display the message in over1
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	jal clear        # Add space for the next output

	j menu           # Jump back to the menu

overCalc:
	li $t1,0         # Set the overdrafted register to true

	sub $t0,$t0,35   # Subtract the overdrafting fee

	j menu           # Jump back to the menu

clear:	la $a0,p2        # Display the message in p2
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	la $a0,p2        # Display the message in p2
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	la $a0,p2        # Display the message in p2
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	la $a0,p2        # Display the message in p2
	li $v0,4         # v0 = 4 indicates display a string
	syscall          # Call to system

	jr $ra

EOP:	li $v0,10        # End Of Program
        syscall          # Call to system

            .data
name:       .space       20
welcome:    .asciiz      "              Welcome To The Bank Of MIPS!"
menu1:      .asciiz      "1) Add Funds\n"
menu2:      .asciiz      "2) Withdraw funds\n"
menu3:      .asciiz      "3) Account Details\n"
menu4:      .asciiz      "4) Close Account\n"
menu5:      .asciiz      "5) Exit\n\nSelect an option: "
header:     .asciiz      "                      Bank Of MIPS\n                    Account Summary\n\nAccount Holder: "
standing:   .asciiz      "Account Standing: "
safeP:      .asciiz      "GOOD STANDING\n\n"
unsafeP:    .asciiz      "OVERDRAFTED\n\n"
total:      .asciiz      "Total Funds: $"
overdraft:  .asciiz      "                    OFFICIAL NOTICE\nYour account is in poor standing. Your current balance\nis "
over1:      .asciiz      " dollars.\nPlease deposit funds to bring your balance back above\n$0 before withdrawing."
faild:      .asciiz      "You may not deposit a negative amount!\n\n"
failw:      .asciiz      "You may not withdraw a negative amount!\n\n"
successw:   .asciiz      "Successfully withdrew: $"
successd:   .asciiz      "Successfully deposited: $"
dep:        .asciiz      "Enter an amount to deposit: "
withdr:     .asciiz      "Enter an amount to withdraw: "
p1:         .asciiz      "Enter your name: "
p2:         .asciiz      "\n"


##################### OUTPUT #####################
#               Welcome To The Bank Of MIPS!
# 
# 
# 
# Enter your name: Alex
# 
# 
# 
# 
# 1) Add Funds
# 2) Withdraw funds
# 3) Account Details
# 4) Close Account
# 5) Exit
# 
# Select an option: 1
# 
# 
# 
# 
# Enter an amount to deposit: -10
# You may not deposit a negative amount!
# 
# Enter an amount to deposit: 10
# Successfully deposited: $10
# 
# 
# 
# 1) Add Funds
# 2) Withdraw funds
# 3) Account Details
# 4) Close Account
# 5) Exit
# 
# Select an option: 2
# 
# 
# 
# 
# 
# 
# 
# 
# Enter an amount to withdraw: -10
# You may not withdraw a negative amount!
#
#
#
#
#
# Enter an amount to withdraw: 10
# Successfully withdrew: $10
#
#
#
# 1) Add Funds
# 2) Withdraw funds
# 3) Account Details
# 4) Close Account
# 5) Exit
#
# Select an option: 2
#
#
#
#
#
#
#
#
# Enter an amount to withdraw: 10
# Successfully withdrew: $10
#
#
#
# 1) Add Funds
# 2) Withdraw funds
# 3) Account Details
# 4) Close Account
# 5) Exit
#
# Select an option: 2
#
#
#
#
#
#
#
#
#                     OFFICIAL NOTICE
# Your account is in poor standing. Your current balance
# is -45 dollars.
# Please deposit funds to bring your balance back above
# $0 before withdrawing.
#
#
#
# 1) Add Funds
# 2) Withdraw funds
# 3) Account Details
# 4) Close Account
# 5) Exit
#
# Select an option: 3
#
#
#
#
#                       Bank Of MIPS
#                     Account Summary
#
# Account Holder: Alex
#
# Account Standing: OVERDRAFTED
#
# Total Funds: $-45
#
#
#
# 1) Add Funds
# 2) Withdraw funds
# 3) Account Details
# 4) Close Account
# 5) Exit
#
# Select an option: 1
#
#
#
#
# Enter an amount to deposit: 45
# Successfully deposited: $45
#
#
#
# 1) Add Funds
# 2) Withdraw funds
# 3) Account Details
# 4) Close Account
# 5) Exit
#
# Select an option: 3
#
#
#
#
#                       Bank Of MIPS
#                     Account Summary
#
# Account Holder: Alex
#
# Account Standing: GOOD STANDING
#
# Total Funds: $0
#
#
#
# 1) Add Funds
# 2) Withdraw funds
# 3) Account Details
# 4) Close Account
# 5) Exit
#
# Select an option: 4
#
#
#
#
#               Welcome To The Bank Of MIPS!
#
#
#
# Enter your name: Nathan
#
#
#
#
# 1) Add Funds
# 2) Withdraw funds
# 3) Account Details
# 4) Close Account
# 5) Exit
# 
# Select an option: 1
#
#
#
#
# Enter an amount to deposit: 10
# Successfully deposited: $10
#
#
#
# 1) Add Funds
# 2) Withdraw funds
# 3) Account Details
# 4) Close Account
# 5) Exit
#
# Select an option: 3
#
#
#
#
#                       Bank Of MIPS
#                     Account Summary
#
# Account Holder: Nathan
#
# Account Standing: GOOD STANDING
#
# Total Funds: $10
#
#
#
# 1) Add Funds
# 2) Withdraw funds
# 3) Account Details
# 4) Close Account
# 5) Exit
#
# Select an option: 5
##################################################