# void fgetln (cstring s) - get a line of text from a file
#		(\n included, null terminated)
# parameters
# 	a0: fd (file descriptor)
# 	a1: s

	.globl	fgetln
fgetln:	move	$t0, $a1		# save a1
	li	$a2, 1			# 1 byte at a time
do1:	li	$v0, 14
	syscall
	lb 	$t1, ($a1)
	addiu 	$a1, $a1, 1
	bne 	$t1, '\n', do1
	sb 	$zero, ($a1)		# null byte
	move	$a1, $t0		# restore a1
	jr	$ra

# open - open file for reading
#
# parameter:
# 	a0: file name
# return:
# 	v0: fd (file descriptor)

	.globl	open
open:	li	$a1, 0
	li	$a2, 0
	li	$v0, 13
	syscall
	jr	$ra

# close - close file
# 	a0: fd

	.globl	close
close:
	li 	$v0, 16
	syscall
	jr	$ra
