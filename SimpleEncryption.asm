

		#####################################################################################
		#										 #
		#			ENCS4370: COMPUTER ARCHITECTURE         	         	 #
		#			       Course Project 1 :				 #
		#                    Text Message Encryption and Decryption                      	 #
		#										 #
		#				                        			 	 #
		#	Student Name: Nqaa Ladadwa	        ID: 1180629		sec:3 	 #			      
		#	Student Name: Nemat Mimi 		ID:1181766 		sec:3 	 #			      
		#                                                                                	 #
		#										 #
		#####################################################################################	

.data 


#_________________________________________________Messages_____________________________________________________________________
menu: .asciiz "\nPlease select from the following options.\n(1) Encryption \n(2) Decryption\n(3) Exit\n\n"
menu1: .asciiz "\n(Welcome To Our Project)\n "
keyValue: .asciiz "\nThe shift value is: "
msg: .asciiz "\nPlease input the name of the plain text file\n"
msg2: .asciiz "\nPlease input the name of the cipher text file\n"
ContentOfInputFile: .asciiz "\nThe Content of the input file: "
removenonalpha: .asciiz "\nThe Result of removing non alphabetic: "
removeSpace: .asciiz "\nThe Result of removing spaces and non alphabetic characters: "
messageToBeEncrypted: .asciiz "\nThe Message To Be Encrypted is: "
messageToBeDecreypted: .asciiz "\nThe Message To Be Decrypted is: "
encryptedResult: .asciiz "\nThe Message After Encryption is: "
decreyptedResult: .asciiz "\nThe Message After Decryption is: "
FinalResult: .asciiz "\nThe Final Result was printed in the ciphertext File!\n "
FinalResult2: .asciiz "\nThe Final Result was printed in the plaintext File!\n "
LowerCase:  .asciiz "\nThe text in Lower Case: "

#_______________________________________________Buffers_____________________________________________________________________

Input_Plain_Name: .space 100		#Name of Input Plaintext file before removing '\n'
PlainFile: .space 1024			#Name of Input Plaintext file after removing '\n'
Input_Cipher_Name: .space 100		#Name of Output Ciphertext file before removing '\n'
CipherFile: .space 1024			#Name of Output Ciphertext file after removing '\n'
Input_plain_Name1: .space 1024		#Name of Output Plaintext file before removing '\n'
PlainFile2: .space 1024			#Name of Output Plaintext file after removing '\n'
Input_Cipher_Name1: .space 100		#Name of Input Ciphertext file before removing '\n'
CipherFile2: .space 1024			#Name of Input Ciphertext file after removing '\n'
MainInput_After_Processing: .space 1024 	#Array for saving characters of the message after getting encrypted
MainInput_before_enc: .space 1024		#Array for saving characters of the message before getting encrypted
MainInput2_After_Processing: .space 1024	#Array for saving characters of the message after getting decrypted
MainInput2_before_dec: .space 1024	#Array for saving characters of the message before getting decrypted
MainInput: .space 1024			#The content of the input plaintext file 
MainInput2: .space 1024			#The content of the input ciphertext file 
result_without_space: .space 1024		#The content of the input plaintext file after removing spaces
result_without_space2:.space 1024		#The content of the input ciphertext file after removing spaces
result_after_dec: .space 1024		#Result of decryption
result_after_enc: .space 1024 		#Result of encryption

#____________________________________________Registers______________________________________________________
#Registers used:
               # $v0: 
                     #contain "13" for openning the file
                     #contain "14" for read from file
                     #contain "16" for closing the file
                     #It contain the file descriptor
                     
               # $a1:
                     #contains "0" which is a flags to read mode
                     #contains "store" which is the address of buffer from which to write
                     
               # $a0:
                     #contains "PlainFile" which contains the input file name 
                     #contains "MainInput" which is the address of buffer from which to write
                     #contains the file descriptor (we move the file descriptor from $s0 to $a0 to save it from changing
                     #,we make this in reading and closing the file)
               
               # $s0: store the file descriptor
               
               # $a2: contains the hardcoded buffer length which is "1024"
               
#________________________________________Start Programming_________________________________________________________

.text
.globl main	
main:

#_______________________________________Printing the Menu____________________________________________________
printmenu:
    	la      $a0, menu1
    	li      $v0, 4
    	syscall                 # Welcome Message
    	la      $a0, menu
    	li      $v0, 4
    	syscall                 # print the menu
    	li      $v0, 5
    	syscall                 # get the choice
    	# $v0 contains input integer (User's choice)
    	li      $t0, 1
    	beq     $v0, $t0, callEncryption
    	li      $t0, 2
    	beq     $v0, $t0, callDecryption
    	li      $t0, 3
    	beq     $v0, $t0, mainExit
     	j       printmenu

#_______________________________________Encryption Process Steps____________________________________________________

#	1- Ask the user to enter the name of the plaintext file.
#	2- Read the content of the plaintext file and save it in a buffer. 
#	3- Remove None-Alphabet characters of the content saved in the buffer.
#	4- Convert all the characters to lower case.
#	5- Calculate the shift value (Max. length of the words)
#	6- Remove all spaces between words.
#	7- Iterate over each character in the message.
#	8- Shift each character by the calculated shift value. 
#       For example, if the key is 3 and the character is 'a', the encrypted character would be 'd'.
#	9- Ask the user to enter the name of the ciphertext file.
#	10- Print the encrypted text in the console and in the ciphertext file.

#_______________________________________Start Encryption Process ____________________________________________________

callEncryption:

	# Ask the user to enter the name of the plain text file
	askForFile: 
	la      $a0, msg			# "\nPlease input the name of the plain text file\n"
	li      $v0, 4
	syscall  
	# Take plaintext file as input from the user
	li $v0, 8  
	la $a0, Input_Plain_Name       
	li $a1, 100      
	syscall
	move $s0, $a0   			# move the file name to s0
    	 
    	# Preparing some temporary registers to be used in reading the file's name and content 
	li $v0, 4
	li $t0, 0
	li $v0, 0
	la $a0, Input_Plain_Name
	li $t2, 0
	li $t3, 0
	
	# Reading the file's name and removing '\n' from it, then saving it in another buffer
	Read_Plain_Loop:
	lb  $t1, Input_Plain_Name($t0)		# Load byte from 't0'th position in buffer into $t1
	beq $t1, 0, ReadPlain			# If the content of 't1'th position is null(zero) -> start reading the file's content
	beq $t1, '\n', not_lower		  	# If the content of 't1'th position is '\n' -> remove '\n' 
	sb $t1,PlainFile($t3)			# Store it back to 't0'th position in buffer if the first element is nither zero nor '\n'
	addi $t3, $t3, 1				#To check the rest elements of the array of the file's name
	addi $t0, $t0, 1
	j Read_Plain_Loop
	# if not lower, then increment $t0 and continue
	not_lower:
	addi $t0, $t0, 1
	j Read_Plain_Loop
    
#______________________________________Preparing the file for reading________________________________________   

	# Open file for reading
	ReadPlain:
	li   $v0, 13				# system call for open file
	la $a0, PlainFile			# load byte space into address
	li   $a1, 0				# flag for reading
	li   $a2, 0				# mode is ignored
	syscall					# execute open file process 
	
	move $s0, $v0          			# save the file descriptor  

	# Reading from file just opened
	li   $v0, 14            			# system call for reading from file
	move $a0, $s0           			# file descriptor 
	la   $a1, MainInput     			# address of MainInput from which to read
	li   $a2,  1024         			# hardcoded MainInput length
	syscall                 			# execute read file process
	j exit					# execute branch 'exit' after reading the file
	
	# Printing the content of the file and calculating the shift value
	exit: 
 	la      $a0,ContentOfInputFile 		# printing the the content of input file messag
	li      $v0, 4
	syscall   
 	la      $a0, MainInput			# Preparing the buffer for removing non-alphabet characters process
 	li      $a1, 1024
 	syscall

#________________________________Preparing the file for removing non-alphabet characters process_______________________________   
  
  	# Find key (shift value)
        la   $s0,  MainInput			# Load the plain text read from file 
        addi $t0, $0, 0				# Counter of the stored characters after checking 	
        addi $a3, $0, 0				# Counter to count characters
        addi $s6, $0, 0				# store Max length 
        
        # Loop for each character of the plain text: 
	Loop_Over_Characters:
	lb   $s2, 0($s0)                		# Load a character
	addi $s0, $s0, 1                		# Move to next character
	addi $a3, $a3, 1                		# Add 1 to characters counter
	beq  $s2, 0, Go_Start_Enc         	# When no more characters, jump to start encryption   
	beq  $s2, 32, Check_Word_Length0		# When there is a space, jump to check the word
	beq  $s2, 10, Check_Word_Length0		# When there is a new line, jump to check the word
        
      # Check if the character is alphabet 
  	slti $t3, $s2, 65       			# Check if the character is less than 'A'  
	bge $t3, 1, Skip_Nonalpha_Char        	# If it is, skip it

	sle $t3, $s2, 90       			# Check if the character is less than 'Z' 
	bge $t3, 1, Store_Alpha_char    		# If it is, store it  
                      
	slti $t3, $s2, 97       			# Check if the character is less than 'a' 
	bge $t3, 1, Skip_Nonalpha_Char        	# If it is, skip it
         
	slti $t3, $s2, 122       		# Check if the character is less than 'z'
	bge $t3, 1, Store_Alpha_char   		# If it is, store it 
           
	sgt $t3, $s2, 122       			# Check if the character is greater than 'z'
	bge $t3, 1, Skip_Nonalpha_Char     	# If it is, skip it 
       
        # Storing alphabet characters
	Store_Alpha_char:
	j Store_Character            		# Store character if it is alphabet  
	j Loop_Over_Characters                 	# Keep doing the loop until the text ends
                
	# Skip none-alphabet characters           
        Skip_Nonalpha_Char :      
	subi $a3, $a3, 1               		# Substract characters counter
	j Loop_Over_Characters			# Jump to read the next character            
         
        # Check the length of each word
        Check_Word_Length0:  
	sgt $t4, $s6, $a3             		# Set $t4 to 1 if prevLength > currentLength, 0 otherwise
	add $t7, $0, $a3				# Save counter value in $t7
	addi $a3, $0, 0				# Set counter $a3 to zero
	beq $t4, 1, Loop_Over_Characters		# Branch to complete if prevLength > currentLength
	addi $s6, $t7, 0				# Otherwise if prevLength < currentLength, store the new maxLength in $s6 
	j Loop_Over_Characters     
 	
 	# Storing characters and converting them to lowercase by adding 32
        Store_Character: 
	li   $t5, 97                 		# Store 97 in $t5
	sge  $t6, $s2, $t5           		# Set $t6 to 1 if $s2 >= $t5, 0 otherwise
	beq  $t6, 1, Continue_Storing_Characters	# Continue storing (character is already lowercase)
	addi $s2, $s2, 32            		# Add 32 to $s2 to convert the character to lowercase
	
	# Continue storing characters
	Continue_Storing_Characters:
	sb   $s2, MainInput_After_Processing($t0)	# Store the character in "MainInput_After_Processing" array
	addi $t0, $t0, 1				# Add to to counter $t0 "counter of stored characters"
	move $a0, $s2
	j Loop_Over_Characters
          
        # Encrypt the modified text   
	Go_Start_Enc:
	# Print removeSpaece message
	subi $s6, $s6, 1           		# Remove space 
	li $v0, 4
	la $a0, removeSpace			# "\nThe Result of removing spaces: "
	syscall
	
	# Print message after removing spaces
	li $v0, 4
	la $a0, MainInput_After_Processing	
	syscall
	
	# Print shift message
	li $v0, 4
	la $a0, keyValue				#  "\nThe shift value is: "
	syscall 
          
	# Print shift value 
	li $v0, 1
	move $a0, $s6				# The shift value
	syscall
  	
	# Initialize the result message to be encrypted
	li $t0, 0 				# result string length
	la $t1, result_after_enc 		# result string buffer

	# Iterate over each character in the message
	la $t2,  MainInput_After_Processing 	# message after removing non-alphabet characters and converting to lowercase
	
	# Start Encrypting each character	
	enc_loop:
	beq $t0, $a1, reach_last_encchar 		# if $t0 == $a1, we have processed all characters

	# Shift the character by the shift value
	lb $t3, 0($t2) 				# load the character
	
# ______________________________________________IMPORTANT NOTE_______________________________________________
#|													|
#| It should be mentioned here that some cases need to be handled.						|
#| Such as if the current letter is 'z', and it is shifted by 1 it will give a wrong result if this case 	|
#| wasn't handled to give the right result which is 'a'.							|	
#__________________________________________________________________________________________________________	|						
		
	li $t7, 26			# Initialize an inital value=26 to compare the indecies to it  
	subi $t3, $t3, 97		# 97 is the ascii value for letter 'a'
	add $t3, $t3, $a0		# shift the character by the entered shift value
	bge $t3, $t7, sub_26		# If the ascii value of the letter is more than 26, subtract 26
	 
	enc:
	add $t3, $t3, 97
	sb $t3, 0($t1) 			# Store the encrypted character in the result string
	# Increment the result string length and the message and result string pointers
	addi $t0, $t0, 1			# increment result string length
	addi $t1, $t1, 1			# increment result string pointer
	addi $t2, $t2, 1			# increment message pointer
	j enc_loop

	sub_26:
	subiu $t3, $t3, 26
	j enc

	# Print the encrypted message in the console and the ciphertext file if it reaches the final character
	reach_last_encchar:

	# Find key (shift value)
        la   $s0,  result_after_enc	# Load the plain text read from file 
        addi $t0, $0, 0                  # Counter of the stored characters after checking 	
        addi $a3, $0, 0                  # Counter to count characters
	addi $s6, $0, 0                  # store Max length 
        
        # Loop for each character of the plain text: 
	Loop_Over_Characters2:
	lb   $s2, 0($s0)                # Load a character
	addi $s0, $s0, 1                # Move to next character
	addi $a3, $a3, 1                # Add 1 to characters counter
	beq  $s2, 0, Go_Print_Cleanresult        # When no more characters, jump to exit to start encryption   
	beq  $s2, 32, Check_Word_Length1         # When there is a space, jump to check the word
	beq  $s2, 10, Check_Word_Length1         # When there is a new line, jump to check the word
        
        # Check if the character is alphabet 

	slti $t3, $s2, 65		# Check if the character is less than 'A'  
	bge $t3, 1, Skip_Nonalpha_Char1	# If it is, skip it

	sle $t3, $s2, 90		# Check if the character is less than 'Z' 
	bge $t3, 1, Store_Alpha_char1	# If it is, store it  
                      
	slti $t3, $s2, 97		# Check if the character is less than 'a' 
	bge $t3, 1, Skip_Nonalpha_Char1	# If it is, skip it
         
	slti $t3, $s2, 122		# Check if the character is less than 'z'
	bge $t3, 1, Store_Alpha_char1	# If it is, store it 
           
	sgt $t3, $s2, 122		# Check if the character is greater than 'z'
	bge $t3, 1, Skip_Nonalpha_Char1	# If it is, skip it  
       
	Store_Alpha_char1:
	j Store_Character1		# Store character that is alphabet  
	j Loop_Over_Characters2		# Keep doing the loop until the text is end
                
	# Skip           
	Skip_Nonalpha_Char1:      
	subi $a3, $a3, 1			# Substract characters counter
	j Loop_Over_Characters2		# Jump to loop to read the next character            
         
	Check_Word_Length1:  
	sgt $t4, $s6, $a3		# Set $t4 to 1 if prevLength > currentLength, 0 otherwise
	add $t7, $0, $a3			# Save counter value in $t7
	addi $a3, $0, 0			# Set counter $a3 to zero
	beq $t4, 1, Loop_Over_Characters2	# Branch to complete if prevLength > currentLength
	addi $s6, $t7, 0			# Otherwise if prevLength < currentLength, store the new maxLength in $s6 
	j Loop_Over_Characters2       

	Store_Character1:   
	li   $t5, 97					# Store 97 in $t5
	sge  $t6, $s2, $t5           			# Set $t6 to 1 if $s2 >= $t5, 0 otherwise
	beq  $t6, 1, Continue_Storing_Characters1   	# Continue storing (character is already lowercase)
	addi $s2, $s2, 32            			# Add 32 to $s2 to convert the character to lowercase
	
	Continue_Storing_Characters1:
	sb   $s2, MainInput2_After_Processing($t0)      	# Store the character in "MainInput2_After_Processing" array
	addi $t0, $t0, 1             			# Add to to counter $t0 "counter of stored characters" 
	move $a0, $s2 
	j Loop_Over_Characters2
          
        # Encrypt the modified text   
	Go_Print_Cleanresult:   
	subi $s6, $s6, 1           # Remove space 
    	la      $a0, encryptedResult
  	li      $v0, 4
  	syscall
  	  
	li $v0, 4
	la $a0, MainInput2_After_Processing
	syscall

#__________________________________Asking user to enter the output file in Encryption________________________
	
	#Ask the user to enter the name of the cipher text file
	askForFile1: 
	la      $a0, msg2			# "\nPlease input the name of the cipher text file\n" 
	li      $v0, 4
	syscall  
	
	#Take ciphertext file as input from the user
	li $v0, 8  
   	la $a0, Input_Cipher_Name      		# Save the ciphertext file name in 'Input_Cipher_Name' Buffer
    	li $a1, 100     
        	syscall
    	move $s0, $a0   
    	 
    	li $v0, 4
    	li $t0, 0
    	li $v0, 0
    	la $a0, Input_Cipher_Name
    	
    	#Loop to remove '\n' from the ciphertext file name
    	li $t2, 0
    	li $t3, 0
    	
    	Write_Cipher_Loop:
    	lb  $t1, Input_Cipher_Name($t0)    	# Load byte from 't0'th position in buffer into $t1
    	beq $t1, 0, WriteCipher      		# If the content of 't1'th position is null(zero) -> start writing in the file
    	beq $t1, '\n', not_lower1  		# If the content of 't1'th position is '\n' -> remove '\n'
    	sb $t1, CipherFile($t3)  		# Store it back to 't0'th position in buffer if the first element is nither zero nor '\n'
    	addi $t3, $t3, 1				# To check the rest elements of the array of the file's name
    	addi $t0, $t0, 1
     	j Write_Cipher_Loop
    	#if not lower, then increment $t0 and continue
    	not_lower1:
     	addi $t0, $t0, 1
    	j Write_Cipher_Loop
    
    	# Open the output file (ciphertext file) to write in it
    	WriteCipher:
	li   $v0, 13            			# system call for open file
	la $a0, CipherFile  			# load byte space into address
	li   $a1, 1             			# flag for writing
	li   $a2, 0          			# mode is ignored
	syscall                 			# open the file 
	move $s0, $v0           			# save the file descriptor  

	# Writing in the file just opened
	li   $v0, 15            			# system call for reading from file
	move $a0, $s0           			# file descriptor 
	la   $a1, MainInput2_After_Processing  	# address of MainInput2_After_Processing from which to read
	li   $a2,  1024         			# hardcoded MainInput2_After_Processing length
	syscall                 			# write in the file
	j exit1
	
	exit1:
	#Printing the the content of input file message 
 	la      $a0,FinalResult 			# "\nThe Final Result was printed in the ciphertext File!\n "
        	li      $v0, 4
        	syscall   
        	j printmenu
 
#_______________________________________End of Encryption Process____________________________________________________

#_______________________________________Start Decryption Process ____________________________________________________

	callDecryption:

	#Ask the user to enter the name of the cipher text file
	askForFile2: 
   	la      $a0, msg2
   	li      $v0, 4
   	syscall  
   	#Take ciphertext file as input from the user
   	li $v0, 8  
   	la $a0, Input_Cipher_Name1      
    	li $a1, 100     
        	syscall
    	move $s0, $a0   # save string to s0
    	 
    	li $v0, 4
    	li $t0, 0  
    	li $v0, 0
    	la $a0, Input_Cipher_Name1
    	#Loop to remove '\n' from the ciphertext file name
    	li $t2, 0
    	li $t3, 0
    	Read_Cipher_Loop:
    	lb  $t1, Input_Cipher_Name1($t0)    	# Load byte from 't0'th position in buffer into $t1
    	beq $t1, 0, ReadCipher    		# If the content of 't1'th position is null(zero) -> start reading the file's content
    	beq $t1, '\n', not_lower2  		# If the content of 't1'th position is '\n' -> remove '\n' 
    	sb $t1, PlainFile2($t3)  		# Store it back to 't0'th position in buffer if the first element is nither zero nor '\n'
    	addi $t3, $t3, 1				# To check the rest elements of the array of the file's name
    	addi $t0, $t0, 1
     	j Read_Cipher_Loop
    	#if not lower, then increment $t0 and continue
    	not_lower2:
     	addi $t0, $t0, 1
    	j Read_Cipher_Loop
    
    	# Open file for reading
	ReadCipher :				# Open file for reading
	li   $v0, 13            			# system call for open file
	la $a0,PlainFile2  			# load byte space into address
	li   $a1, 0             			# flag for reading
	li   $a2, 0           			# mode is ignored
	syscall                 			# open the file 
	move $s0, $v0           			# save the file descriptor  

	# Reading from file just opened
	li   $v0, 14            			# system call for reading from file
	move $a0, $s0           			# file descriptor 
	la   $a1, MainInput2     		# address of MainInput2 from which to read
	li   $a2,  1024         			# hardcoded MainInput2 length
	syscall                 			# read from file
	j exit2
	
	#Printing the the content of input file message 
	exit2:
 	la      $a0,ContentOfInputFile 
        li      $v0, 4
        syscall   
	#Preparing the buffer for removing non-alphabet characters process
 	la      $a0, MainInput2
 	li      $a1, 1024
 	syscall

	
#____________________________________Removing Spaces and none-alphabet characters____________________________________

	# Find key (shift value)
        la   $s0,  MainInput2		# Load the cipher text read from file 
        addi $t0, $0, 0                  	# Counter of the stored characters after checking 	
        addi $a3, $0, 0                  	# Counter to count characters
        addi $s6, $0, 0                  	# store Max length 
        
        # Loop for each character of the cipher text: 
       	Loop_Over_Characters3:
	lb   $s2, 0($s0)                # Load a character
        	addi $s0, $s0, 1                # Move to next character
        	addi $a3, $a3, 1                # Add 1 to characters counter
        	beq  $s2, 0, Go_start_Dec         	# When no more characters, jump to exit to start decryption   
        	beq  $s2, 32, Check_Word_Length2         	# When there is a space, jump to check the word
        	beq  $s2, 10, Check_Word_Length2         	# When there is a new line, jump to check the word
	j Store_Character2           		# Store character that is alphabet  
        	j Loop_Over_Characters3                 	# Keep doing the loop until the text is end
                
       	# Skip the none-alphabet characters           
       	Skip_Nonalpha_Char2:      
        	subi $a3, $a3, 1               		# Substract characters counter
        	j Loop_Over_Characters3                  	# Jump to loop to read the next character            
         
        Check_Word_Length2:  
       	sgt $t4, $s6, $a3             		# Set $t4 to 1 if prevLength > currentLength, 0 otherwise
       	add $t7, $0, $a3              		# Save counter value in $t7
        	addi $a3, $0, 0               		# Set counter $a3 to zero
        	beq $t4, 1, Skip_Nonalpha_Char2         	# Branch to complete if prevLength > currentLength
        	addi $s6, $t7, 0                		# Otherwise if prevLength < currentLength, store the new maxLength in $s6
       	j Loop_Over_Characters3      
        
       	Store_Character2:
       	li   $t5, 97                 		# Store 97 in $t5
       	sge  $t6, $s2, $t5           		# Set $t6 to 1 if $s2 >= $t5, 0 otherwise
       	beq  $t6, 1, Continue_Storing_Characters2	# Continue storing (character is already lowercase)
       	addi $s2, $s2, 32            		# Add 32 to $s2 to convert the character to lowercase
       	Continue_Storing_Characters2:
        	sb   $s2, MainInput_before_enc($t0)     	# Store the character in "MainInput_before_enc" array
        	addi $t0, $t0, 1             		# Add to to counter $t0 "counter of stored characters"
        	move $a0, $s2
       	j Loop_Over_Characters3
          
        # Decrypt the modified text   
       	Go_start_Dec:
       	subi $s6, $s6, 1           		# Remove space 
       	# Print shift message
        	li $v0, 4
        	la $a0, keyValue
        	syscall   
       	# Print shift value 
        	li $v0, 1
       	move $a0, $s6
       	syscall
#_______________________________________Start Decryption Process ____________________________________________________

	
	# Initialize the result string
	li $t0, 0 					# result string length
	la $t1, result_after_dec 			# result string buffer

	# Iterate over each character in the message
	la $t2,  MainInput_before_enc			# message buffer
	dec_loop:
	beq $t0, $a1, reach_last_decchar 			# if $t0 == $a1, we have processed all characters
	lb $t3, 0($t2) 					# load the character
	subi $t3, $t3, 97				# 97 is the ascii value for letter 'a'
	sub $t3, $t3, $a0 				# shift the character by the negative of the value
	bltz $t3, add_26					# If the ascii value of the letter is less than or equal to zero, add 26
	
	dec:
	add $t3, $t3, 97
	sb $t3, 0($t1) 					# Store the decrypted character in the result string
	# Increment the result string length and the message and result string pointers
	addi $t0, $t0, 1		 			# increment result string length
	addi $t1, $t1, 1 				# increment result string pointer
	addi $t2, $t2, 1 				# increment message pointer
	j dec_loop
	
	add_26:
	addiu $t3, $t3, 26
	j dec

	# Print the decrypted message in the console and the plaintext file if it reaches the final character
	reach_last_decchar:
	# Find key (shift value)
        la   $s0,  result_after_dec		 	# Load the cipher text read from file 
        addi $t0, $0, 0                  			# Counter of the stored characters after checking 	
        addi $a3, $0, 0                  			# Counter to count characters
        addi $s6, $0, 0                  			# store Max length 
        
        # Loop for each character of the cipher text: 
       	Loop_Over_Characters4:
       	lb   $s2, 0($s0)                			# Load a character
       	addi $s0, $s0, 1                			# Move to next character
        	addi $a3, $a3, 1                			# Add 1 to characters counter
        	beq  $s2, 0, Go_Print_Cleanresult1        	# When no more characters, jump to Go_Print_Cleanresult1   
        	beq  $s2, 32, Check_Word_Length3       	 	# When there is a space, jump to check the word
        	beq  $s2, 10, Check_Word_Length3         		# When there is a new line, jump to check the word
        
        # Check if the character is alphabet 
       	slti $t3, $s2, 65       				# Check if the character is less than 'A'  
        	bge $t3, 1, Skip_Nonalpha_Char3        		# If it is, skip it

       	sle $t3, $s2, 90      				# Check if the character is less than 'Z' 
        	bge $t3, 1, Store_Alpha_char2  			# If it is, store it  
                      
       	slti $t3, $s2, 97       				# Check if the character is less than 'a' 
       	bge $t3, 1, Skip_Nonalpha_Char3        		# If it is, skip it
         
       	slti $t3, $s2, 122       			# Check if the character is less than 'z'
        	bge $t3, 1, Store_Alpha_char2    			# If it is, store it 
           
       	sgt $t3, $s2, 122       				# Check if the character is greater than 'z'
        	bge $t3, 1, Skip_Nonalpha_Char3    		# If it is, skip it 
       
        	Store_Alpha_char2:
        	j Store_Character3            			# Store character that is alphabet      
       	j Loop_Over_Characters4                  		# Keep doing the loop until the text is end
                
       	# Skip the none-alphabet characters           
       	Skip_Nonalpha_Char3:      
       	subi $a3, $a3, 1               			# Substract characters counter
       	j Loop_Over_Characters4                         	# Jump to loop to read the next character            
         
        Check_Word_Length3:  
       	sgt $t4, $s6, $a3             			# Set $t4 to 1 if prevLength > currentLength, 0 otherwise
       	add $t7, $0, $a3              			# Save counter value in $t7
       	addi $a3, $0, 0               			# Set counter $a3 to zero
       	beq $t4, 1, Loop_Over_Characters4             	# Branch to complete if prevLength > currentLength
       	addi $s6, $t7, 0              	          	# Otherwise if prevLength < currentLength, store the new maxLength in $s6
       	j Loop_Over_Characters4     
       	 
        Store_Character3:    
      	li   $t5, 97                 			# Store 97 in $t5
       	sge  $t6, $s2, $t5           			# Set $t6 to 1 if $s2 >= $t5, 0 otherwise
       	beq  $t6, 1, Continue_Storing_Characters3        	# Continue storing (character is already lowercase)
       	addi $s2, $s2, 32            			# Add 32 to $s2 to convert the character to lowercase
       	
       	Continue_Storing_Characters3:
       	sb   $s2, MainInput2_before_dec($t0)         	# Store the character in " MainInput2_before_dec" array
        	addi $t0, $t0, 1             			# Add to to counter $t0 "counter of stored characters"
       	move $a0, $s2 
       	j Loop_Over_Characters4
          
      	# decrypt the modified text   
      	Go_Print_Cleanresult1:
        	subi $s6, $s6, 1           			# Remove space 
    	la      $a0, decreyptedResult
  	li      $v0, 4
  	syscall  
        	li $v0, 4
        	la $a0, MainInput2_before_dec
       	syscall
         
 #______________Ask the user to enter the name of the plaintext file to print the decrypted message in it___________________________________________________________________    	

	#Ask the user to enter the name of the plain text file
	askForFile3: 
   	la      $a0, msg
   	li      $v0, 4
   	syscall  
   	#Take plaintext file as input from the user
   	li $v0, 8  
   	la $a0, Input_plain_Name1     
   	li $a1, 100      
       	syscall
    	move $s0, $a0   
    	 
    	li $v0, 4
    	li $t0, 0
    	li $v0, 0
    	la $a0,  Input_plain_Name1
    	#Loop to remove '\n' from the file name
    	li $t2, 0
    	li $t3, 0
    	Write_Plain_Loop:
    	lb  $t1, Input_plain_Name1($t0)    		#Load byte from 't0'th position in buffer into $t1
    	beq $t1, 0, WritePlain   			# If the content of 't1'th position is null(zero) -> start reading the file's content
    	beq $t1, '\n', not_lower4  			# If the content of 't1'th position is '\n' -> remove '\n'
    	sb $t1, CipherFile2($t3)  			# Store it back to 't0'th position in buffer if the first element is nither zero nor '\n'
    	addi $t3, $t3, 1					# To check the rest elements of the array of the file's name
    	addi $t0, $t0, 1
     	j Write_Plain_Loop
    	#if not lower, then increment $t0 and continue
    	not_lower4:
     	addi $t0, $t0, 1
    	j Write_Plain_Loop
       
    	# Open plaintext file to write in it
    	WritePlain:
	li   $v0, 13            				# system call for open file
	la $a0, CipherFile2  				# load byte space into address
	li   $a1, 1             				# flag for writing
	li   $a2, 0           				# mode is ignored
	syscall                 				# open a file 
	move $s0, $v0           				# save the file descriptor  

	# Writin in the file just opened
	li   $v0, 15            				# system call for reading from file
	move $a0, $s0           				# file descriptor 
	la   $a1, MainInput2_before_dec   	 	# address of MainInput2_before_dec from which to read
	li   $a2,  1024         				# hardcoded MainInput2_before_dec length
	syscall                 				# write in the file
	j exit4
	
	#Printing the the content of input file message 
	exit4:
 	la      $a0,FinalResult2 			#  "\nThe Final Result was printed in the plaintext File!\n "
        	li      $v0, 4
        	syscall  
        j printmenu
#_________________________________________End the program ____________________________________________________
  	# Exit the menu  
	mainExit:
	move    $a0, $s0
	li      $v0, 10
	syscall                
 
