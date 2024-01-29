#
#	Name:	Loke, Noah
#	Description:
#		This program implements a linked list to store strings from a periodic table file 'enames.dat'.
#		The program will then convert the linked list into an array.
#		Then it will sort the array in alphabetical order and print it.
#
	.data
ptfname:	.asciiz	"C:/Users/admin/Documents/CS/enames.dat"
title:	.asciiz	"Elements v0.2 by N. Loke\n\n"
elements:	.asciiz	" elements\n\n"

head:	.word	0
input:	.space	64

fileDesc:	.word	0
numElem:	.word	0
array:	.word	0
 
	.text
main:	la	$a0, title		# print "Elements v0.2 by N. Loke\n\n"
	li	$v0, 4
	syscall

	la	$a0, ptfname	# open file
	jal	open
	sw	$v0, fileDesc	# Save file descriptor
	lw	$s0, numElem	# load/set element counter to 0

readFile:	lw	$a0, fileDesc	# Load file descriptor
	la	$a1, input		# Load buffer address
	jal	fgetln		# Read a line into buffer

	la	$a0, input

	lb	$t0, input		# Load the first byte of buffer
	beq	$t0, '\n', endOfFile	# If newline, then the end of the file is reached

	jal	strdup
	move	$a0, $v0		# move dup string address to $a0

	lw	$a1, head		# Load current head as the next node
	jal	getnode		# Create a new node and link it
	sw	$v0, head		# Update head with the new node address

	add	$s0, 1		# increment element counter
	b	readFile

endOfFile:	lw	$a0, fileDesc	# Load file descriptor
	jal	close

	sw	$s0, numElem	# print total element count
	move	$a0, $s0
	li	$v0, 1
	syscall

	la	$a0, elements	# print " elements\n\n"
	li	$v0, 4
	syscall

	lw	$a0, head		# Load the head of the list into $a0
	lw	$a1, numElem	# Load the number of elements
	jal	toarray		# Call toarray, returns address of the array in $v0

	sw	$v0, array

	lw	$a0, array		# Move base address of the array to $a0
	lw	$a1, numElem	# Load the number of elements
	jal	sort		# Call sort

	lw	$t0, array		# Move base address of the array to $t0

	lw	$t1, numElem	# Load the number of elements

	li	$t2, 0		# Index for the loop
print_loop:	beq	$t2, $t1, exit	# End loop if index equals number of elements

	lw	$a0, 0($t0)		# Load address of the current string
	li	$v0, 4
	syscall			# Print the string

	addiu	$t0, $t0, 4		# Move to the next element in the array
	addiu	$t2, $t2, 1		# Increment the index
	b	print_loop

exit:	li	$v0, 10		# exit
	syscall

toarray:	subu	$sp, $sp, 12
	sw	$ra, 8($sp)
	sw	$a1, 4($sp)		# Save size
	sw	$a0, 0($sp)		# Save head address

	sll	$a0, $a1, 2		# Size of array in bytes (each element is a word)
	jal	malloc
	move	$s0, $v0		# $s0 now points to the base of the array

	lw	$a1, 4($sp)		# Load size
	lw	$a2, 0($sp)		# Load head address

	move	$t0, $s0		# $t0 is the current position in the array

toarray_fill:	
	beqz	$a2, toarray_end	# End if reached end of list
	lw	$t2, 0($a2)		# Load string address from current node
	sw	$t2, 0($t0)		# Store string address in array
	addiu	$t0, $t0, 4		# Move to next element in array
	lw	$a2, 4($a2)		# Move to next node in list
	b	toarray_fill

toarray_end:	
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	move	$v0, $s0		# Return the base address of the array
	jr	$ra

strcmp:
	move	$t0, $a0
	move	$t1, $a1

strcmp_loop:
	lb	$t3, ($t0)		# Load byte from first string
	lb	$t4, ($t1)		# Load byte from second string
	beqz	$t3, strcmp_end	# If end of first string, we're done
	bne	$t3, $t4, strcmp_end	# If chars differ, return difference
	addiu	$t0, $t0, 1		# Move to next character in first string
	addiu	$t1, $t1, 1		# Move to next character in second string
	b	strcmp_loop		# Continue loop

strcmp_end:
	subu	$v0, $t3, $t4	# Return difference if end of second string
	jr	$ra

sort:	subu	$sp, $sp, 12
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$a1, 8($sp)
	li	$s0, 0		# startScan = 0

sort_outer_loop:	
	sub	$t0, $a1, 1
	bge	$s0, $t0, sort_end	# end sort if startScan >= (array.length-1)

	move	$s1, $s0		# minIndex = startScan

	sll	$t0, $s0, 2
	add	$a0, $a0, $t0
	lw	$s2, ($a0)		# minValue = array[startScan]
	lw	$a0, 4($sp)		# restore $a0

	addi	$s3, $s0, 1		# index = startScan + 1

sort_inner_loop:			# end inner loop if index >= array.length
	bge	$s3, $a1, sort_end_inner

	sll	$t0, $s3, 2
	add	$a0, $a0, $t0
	lw	$a0, ($a0)
	move	$a1, $s2

	jal	strcmp

	bge	$v0, $zero, sort_end_if
	move	$s2, $a0		# minValue = array[index]
	move	$s1, $s3		# minIndex = index

sort_end_if:	
	lw	$a0, 4($sp)
	lw	$a1, 8($sp)
	add	$s3, 1		# index++
	b	sort_inner_loop

sort_end_inner:	
	sll	$t0, $s0, 2		# array[startScan]
	add	$a0, $a0, $t0
	lw	$t0, ($a0)
	lw	$a0, 4($sp)

	sll	$t1, $s1, 2		# array[minIndex] = array[startScan]
	add	$a0, $a0, $t1
	sw	$t0, ($a0)
	lw	$a0, 4($sp)

	sll	$t0, $s0, 2
	add	$a0, $a0, $t0
	sw	$s2, ($a0)
	lw	$a0, 4($sp)

	add	$s0, 1		# startScan++
	b	sort_outer_loop

sort_end:	
	lw	$ra, 0($sp)
	lw	$a0, 4($sp)
	lw	$a1, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

getnode:	subu	$sp, $sp, 12
	sw	$ra, 8($sp)
	sw	$a0, 4($sp)
	sw	$a1, 0($sp)

	li	$a0, 8		# Size for new node (2 words)
	jal	malloc		# Allocate memory for new node
	move	$t0, $v0		# $t0 now points to the new node

	lw	$a0, 4($sp)		# Restore the data argument
	sw	$a0, 0($t0)		# Store the string address in the node
	lw	$a1, 0($sp)		# Restore the next node address
	sw	$a1, 4($t0)		# Store the address of the next node in the node

	move	$v0, $t0		# Return the address of the new node

	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

strdup:	subu	$sp, $sp, 8
	sw	$a0, 4($sp)
	sw	$ra, 0($sp)
	jal	strlen
	addi	$a0, $v0, 1
	jal	malloc
	move	$t0, $v0
	lw	$a0, 4($sp)

strdup_while:	
	lb	$t1, ($a0)
	sb	$t1, ($t0)
	beqz	$t1, strdup_endw
	addi	$t0, $t0, 1
	addi	$a0, $a0, 1
	b	strdup_while

strdup_endw:	
	lw	$a0, 4($sp)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 8
	jr	$ra

strlen:	move	$t0, $a0

strlen_while:	
	lb	$t1, ($t0)
	beqz	$t1, strlen_endw
	addi	$t0, $t0, 1
	b	strlen_while

strlen_endw:	
	subu	$v0, $t0, $a0
	jr	$ra

malloc:	subu	$sp, $sp, 4
	sw	$a0, 0($sp)
	addi	$a0, $a0, 3
	andi	$a0, $a0, 0xfffc
	li	$v0, 9
	syscall

	lw	$a0, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra