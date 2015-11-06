.data
		winMsg:		.asciiz "You Win! Your Points is: \n"
		loseMsg:	.asciiz "You Lose! Your Points is: \n"
		points:		.word    0
		bulletCor:	.word  	-2,-2,-2,-2
		snakeCor:	.word   -1,-1, 0, 0,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-1,-1,
					      -2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,	
		

.text
		li $s0,    0	#points	
		li $s1,   25    #lag time for bullet
		li $s2,  220	#lag time for snake
_setOri:
		checkForWin:
				addi $s2, $s2, -20				
				bnez $s2, BuVvsSnV
				la   $a0, winMsg
				Msg:				
				          li   $v0,	  4
					  syscall
					  move $a0, 	$s0
					  li   $v0,       1
					  syscall
	              			  j   _exit
		BuVvsSnV:	
				bne  $s2, 100,  	  upperBound			 
				addi $s1, $s1, 		 -15
		upperBound:
				li   $s3,  62	
		numOfMR:
				li   $s4,  10
				beq  $s2, 200,  numOfBullets
				li   $s4,   5	
		numOfBullets:
				move $s5, $zero
		addOfBulletCor:
				la   $s6, bulletCor
		addOfSnake:
				la   $s7, snakeCor								
		oriJet:	
				li   $t4,  31
				li   $t5,  63
		lagIndex:
				li   $t6,   0
				li   $t7,   0			
		setMR:
				beqz $s4,      _control
				jal _random
				move $s3, $a0
				jal _random
				addi $t1, $a0,  1
				move $s3, $a0	
				jal _random
				move $a1, $a0
				move $a0, $t1
				jal _getLED
				beq  $v0, 3,    setMR
				li   $a2, 3
				jal _setLED		
				addi $s4, $s4, -1
				j    setMR	
				 										
_control:	
		#li   $a0,  1	#If you think it is too fast, then execute these three lines.
		#li   $v0, 32
		#syscall
		
		addi $t6, $t6, 1
		addi $t7, $t7, 1
		
		move $a0, $t4
		move $a1, $t5
		jal _setOnJet
		
		jal _getKeyPress
		beq  $v0, 0x42,  _exit
		beq  $v0, 0xE0,  bullet
		beq  $v0, 0xE2,  left
		beq  $v0, 0XE3,  right
		
		checkForBu:
				slt      $t0,  $t6, $s1
				beqz     $t0, _setOnBullet		
		checkForSnake:
				slt      $t0,  $t7, $s2
				beqz     $t0, _setOnSnake
		j _control
				
		bullet:
			beq  $s5,     2,   noMoreBullet	
			sll  $t0,   $s5,   2
			add  $t0,   $t0, $s6
			sw   $a0, 0($t0)	
			li   $t1,    61
			sw   $t1, 8($t0)
			addi $s5,   $s5,   1
			noMoreBullet:
			              j   _control
			
		left:
			addi $t8,   $a0,  -1
			beqz $t8,  _control
		
			addi $a0,   $a0,  -1
			jal _getLED
			bnez $v0,  _control
		
			addi $a0,   $a0,  -1
			addi $a1,   $a1,   1
			jal _getLED
			bnez $v0,  _control
		
			move $a0,   $t4
			move $a1,   $t5
			jal _setOffJet
		
			addi $t4,   $t4,  -1
			j   _control
	
		right:
			addi $t8,   $a0,   1
			beq  $t8,    63, _control
		
			addi $a0,   $a0,   1
			jal _getLED
			bnez $v0,  _control
		
			addi $a0,   $a0,   1
			addi $a1,   $a1,   1
			jal _getLED
			bnez $v0,  _control
		
			move $a0,   $t4
			move $a1,   $t5
			jal _setOffJet
		
			addi $t4,   $t4,   1
			j   _control					

_setOnBullet:
			li   $t8,     0
		        move $t9,   $s5
		
		loopBu:
			beq  $t8,   $t9,   gotoCheckSnake		
			sll  $t6,   $t8,   2       
			add  $t6,   $t6, $s6      
			
			lw   $a0, 0($t6)
			lw   $a1, 8($t6)
														
			offTheLast:	
			            addi $a1,   $a1,     1
				    li   $a2,     0
				    jal _setLED
				    beqz $a1, goBulletOut
			onTheCur:	
				    addi $a1,   $a1,    -1	
				    jal _getLED
				    beq  $v0,     1,     hitsSnake
			            beq  $v0,     3,     hitsMR
				    li   $a2,     2		
				    jal _setLED
			saveCor:			
				    addi $a1,   $a1,    -1	
				    sw   $a1, 8($t6)
				    j    nextBu
			hitsMR:	
				    addi $s0,   $s0,     1
				    li   $a2,     0
				    jal _setLED
				    jal _bulletOut
				    j    nextBu		
			hitsSnake:
				    li   $t0,     8
				    findX:
					   add  $t1,   $t0,   $s7
					   lw   $t2, 0($t1)
					   beq  $t2,   $a0,   ensureY
					   nextP:
						      addi    $t0,     $t0,   	8  
						      j       findX
					   ensureY:
						      lw      $t2,   4($t1)
						      bne     $t2,     $a1,     nextP
						      killP:
						                  li   $t0,        -1
								  sw   $t0,     0($t1)
								  sw   $t0,     4($t1)
						      turnToMR:
								  li   $a2,         3
								  jal _setLED
						      addPoints:
						      		  jal _bulletOut
								  addi $s0,       $s0,   5
								  addi $s4,       $s4,   1
								  beq  $s4,        10,  _playAgain	  	  																		
			nextBu:	
					addi $t8,  $t8,  1
					j    loopBu
			goBulletOut:
					jal _bulletOut
					j    nextBu
			gotoCheckSnake:
					li   $t6,    0
					j    checkForSnake				
			
_setOnSnake: 
		li $t6, 8
		multipleS:
			      findHead:	
			      		beq     $t6,    88,   printSnake
					add     $t7,   $s7, $t6				
  					lw      $t0, 4($t7)
  					bne     $t0,    -1,   headFound
  					addi    $t6,   $t6,   8
  					j       findHead	
  			     		headFound:
  			     	                    move    $t8,   $t7
			      findTail:
  					addi    $t6,   $t6,   8
  					add     $t7,   $s7, $t6
      					lw      $t0, 0($t7)
        				beq     $t0,    -1,   tailFound
       					j       findTail
      					tailFound:
  	   						addi    $t9,   $t7,  -8			 		
				 reset:
					lw   	$t0, 0($t9)
					sw   	$t0,88($t8)
					lw   	$t0, 4($t9)
					sw   	$t0,92($t8)
			
					lw   	$a0, 0($t8)
					lw   	$a1, 4($t8)			
					oddOrEven:	
							andi $t0, $a1, 1
							beqz $t0, even	
					      
					      		odd:
								beqz $a0, oddCut
								oddCheckMR:
										addi $a0,     $a0, -1
										jal _getLED
										beq  $v0, 3, oddMrCut		
										j oddRowNoChange
								oddMrCut:
										addi $a0,     $a0, 1	
								oddCut:
										addi $a1,     $a1, 1
								oddRowNoChange:	
										sw   $a0,   0($t9)
										sw   $a1,   4($t9)		
										j interChange			

					    		even:
								beq  $a0,  63, evenCut
								evenCheckMR:
										addi $a0,     $a0,  1
										jal _getLED
										beq  $v0,       3, evenMrCut							
										j evenRowNoChange
								evenMrCut:
										addi $a0,     $a0, -1	
								evenCut:
										addi $a1,     $a1,  1
								evenRowNoChange:		
										sw   $a0,   0($t9)								
										sw   $a1,   4($t9)
					
							interChange:
									lw   $t3, -8($t9)
									beq  $t3, -1, checkMultiple
								
									lw   $t0,  0($t9)
									lw   $t1, -8($t9)
									sw   $t0, -8($t9)
									sw   $t1,  0($t9)
										
									lw   $t0,  4($t9)
									lw   $t1, -4($t9)
									sw   $t0, -4($t9)
									sw   $t1,  4($t9) 		
															
									addi $t9,    $t9, -8
									j interChange
		checkMultiple:
					beq  $t6,  88, printSnake
					addi $t6, $t6, 8
					j    multipleS	
					
		printSnake:
				li   $t6,   8
				offThePrev:
						beq  $t6,     88, backToControl
						add  $t7,    $s7, $t6
						lw   $t0,  0($t7)
						beq  $t0,     -1, tryNext
						lw   $a0, 88($t7)
						slti $t0,    $a0, 0
						bnez $t0,    onSnake
						lw   $a1, 92($t7)						
						li   $a2,         0
						jal _setLED
						j    onSnake
						tryNext:
								addi $t6, $t6, 8
								j    offThePrev
				onSnake:
						lw   $a0,  0($t7)
						beq  $a0,     -1, checkNextS
						beq  $a0,     -2, nextSP
						lw   $a1,  4($t7)
						li   $a2,      1
						jal _setLED
						beq  $a1,     60, _loseMsg
						nextSP:
							addi $t6,    $t6,   8
							beq  $t6,     88,   backToControl
							add  $t7,    $s7, $t6
							j    offThePrev
				checkNextS:
						beq  $t6,     88, backToControl
						j    nextSP		
						
				backToControl:
						li   $t6, 0
						li   $t7, 0
						j   _control
								
_random:
		addi 	$s3, $s3, 62
		sra  	$s3, $s3, 1
	
		li	$v0, 30		
		syscall

		move	$t0, $a0	
		li	$a0, 1		
		move 	$a1, $t0
		li	$v0, 40		
		syscall

		li	$a0, 1		
		move	$a1, $s3	
		li	$v0, 42		
		syscall
	
		jr $ra
		
_setOnJet:
		move $t9, $ra
		li $a2, 2
		jal _setLED
		addi $a0, $a0, 1
		jal _setLED
		addi $a0, $a0, -2
		jal _setLED
		addi $a0, $a0, 1
		addi $a1, $a1, -1
		jal _setLED
		jr $t9	

_setOffJet:		
		move $t9, $ra 				 		 				 		 
		li   $a2,   0
		jal _setLED
		addi $a0, $a0,  1
		jal _setLED
		addi $a0, $a0, -2
		jal _setLED
		addi $a0, $a0,  1
		addi $a1, $a1, -1
		jal _setLED
		jr   $t9	
		
_playAgain:
		wholeSnakePoints:	
					addi $s0,       $s0,  100
		offThePossibleBu:
					bne  $s5,         1,  playAgainCut  
					li   $a2,         0
					lw   $a0,     0($s6)
					lw   $a1,     8($s6)
					addi $a1,       $a1,    1
					jal _setLED
		playAgainCut:
					move $a0, 	$t4
					move $a1, 	$t5
					jal _setOffJet
		preForSnaInit: 
					li   $t0,   	 -2
					sw   $zero,   8($s7)
					sw   $zero,  12($s7)
		
					li   $t1,    16
					reInitSnake:	
							beq  	$t1,    88, initCut
							beq  	$t1,   176,_setOri 
							add  	$t2,   $t1, $s7
							sw   	$t0, 0($t2)
							sw   	$t0, 4($t2)
							initCut:
								addi   $t1, $t1, 8
								j      reInitSnake 

_bulletOut:
		bnez $t8,  shortCut
		lw   $t1,  4($s6)
		sw   $t1,  0($s6)
		lw   $t1, 12($s6)
		sw   $t1,  8($s6)
		shortCut:				
			addi $s5, $s5,  -1
		jr   $ra
				
_loseMsg:
		la   $a0, loseMsg
		j    Msg

_exit:	
		li   $v0, 10
		syscall

_getLED:
	# byte offset into display = y * 16 bytes + (x / 4)
	sll  $t0,$a1,4      # y * 16 bytes
	srl  $t1,$a0,2      # x / 4
	add  $t0,$t0,$t1    # byte offset into display
	la   $t2,0xffff0008
	add  $t0,$t2,$t0    # address of byte with the LED
	# now, compute bit position in the byte and the mask for it
	andi $t1,$a0,0x3    # remainder is bit position in byte
	neg  $t1,$t1        # negate position for subtraction
	addi $t1,$t1,3      # bit positions in reverse order
    	sll  $t1,$t1,1      # led is 2 bits
	# load LED value, get the desired bit in the loaded byte
	lbu  $t2,0($t0)
	srlv $t2,$t2,$t1    # shift LED value to lsb position
	andi $v0,$t2,0x3    # mask off any remaining upper bits
	jr   $ra
	
_setLED:
	# byte offset into display = y * 16 bytes + (x / 4)
	sll	$t0,$a1,4      # y * 16 bytes
	srl	$t1,$a0,2      # x / 4
	add	$t0,$t0,$t1    # byte offset into display
	li	$t2,0xffff0008	# base address of LED display
	add	$t0,$t2,$t0    # address of byte with the LED
	# now, compute led position in the byte and the mask for it
	andi	$t1,$a0,0x3    # remainder is led position in byte
	neg	$t1,$t1        # negate position for subtraction
	addi	$t1,$t1,3      # bit positions in reverse order
	sll	$t1,$t1,1      # led is 2 bits
	# compute two masks: one to clear field, one to set new color
	li	$t2,3		
	sllv	$t2,$t2,$t1
	not	$t2,$t2        # bit mask for clearing current color
	sllv	$t1,$a2,$t1    # bit mask for setting color
	# get current LED value, set the new field, store it back to LED
	lbu	$t3,0($t0)     # read current LED value	
	and	$t3,$t3,$t2    # clear the field for the color
	or	$t3,$t3,$t1    # set color field
	sb	$t3,0($t0)     # update display
	jr	$ra

_getKeyPress:
	la	$t1, 0xffff0000			# status register
	li	$v0, 0				# default to no key pressed
	lw	$t0, 0($t1)			# load the status
	beq	$t0, $zero, _keypress_return	# no key pressed, return
	lw	$v0, 4($t1)			# read the key pressed
_keypress_return:
	jr $ra
	
