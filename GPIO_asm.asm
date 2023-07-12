#the core is RISCV32EC, only 16 registers(0-15) ,basic integer opcode only
# x0 = zero
# x1 = ra		Caller 
# x2 = sp		Callee
#x5-x7= t0,t1,t2
#x8 s0/fp Save register/frame pointer Callee
#x9 s1 Save register Callee
#x10-11= a0-1= Function parameters/return values Caller
#x12-15 a2-5 Function parameters Caller
#The Caller attribute in the above table means that the called procedure does not save the register value, and
#the Callee attribute means that the called procedure saves the register

# 2kb sram

include CH32V003_reg1.asm		# file with all address defines

fclk = 24000000   			# 24Mhz RCO internal 



main:

sp_init:
    	li sp, STACK			# load stack pointer with stack end address

	li x10,R32_RCC_APB2PCENR	# load address of APB2PCENR register to x10 ,for enabling GPIO A,D,C peripherals
	lw x11,0(x10)			# load contents from peripheral register R32_RCC_APB2PCENR pointed by x10
	li x7,((1<<2)|(1<<4)|(1<<5))	# 1<<IOPA_EN,1<<IOPC_EN,1<<IOPD_EN
	or x11,x11,x7			# or values 
	sw x11,0(10)			# store modified enable values in R32_RCC_APB2PCENR

	li x10,R32_GPIOD_CFGLR		# load pointer x10 with address of R32_GPIOD_CFGLR , GPIO configuration register
	lw x11,0(x10)			# load contents from register pointed by x10
	li x7,~(0xf<<16)		# we need to setup PD4 (led pin of board). clear PD4 config bits with mask 0xfff0ffff or ~(F<<16)
	and x11,x11,x7			# clear pd4 mode and cnf bits for selected pin D4
	li x7,(0x3<<16)			# 00: Universal push-pull output mode.|11: Output mode, maximum speed 50MHz = 0011 (0x3 shifted to bit 16 of reg)
	or x11,x11,x7			# OR value to register
	sw x11,0(x10)			# store in R32_GPIOD_CFGLR

PD4_ON:
	li x10,R32_GPIOD_BSHR		# R32_GPIOD_BSHR register sets and resets GPIOD pins, load address into pointer x10
	lw x11,0(x10)			# load contents to x11
	li x7,(1<<4)			# set pd4 by shifting 1 to bit position 4
	or x11,x11,x7			# OR with x11
	sw x11,0(x10)			# store x11 to R32_GPIOD_BSHR


	call delay			# delay subroutine

PD4_OFF:
	li x10,R32_GPIOD_BSHR		# R32_GPIOD_BSHR register sets and resets GPIOD pins, load address into pointer x10
	lw x11,0(x10)			# load contents to x11
	li x7,1<<20			# reset pd4 by shifting 1 into bit position 20 of R32_GPIOD_BSHR
	or x11,x11,x7			# OR with x11
	sw x11,0(x10)			# store x11 to R32_GPIOD_BSHR

	call delay			# delay subroutine

	j PD4_ON			# jump to label PD4_ON and loop







delay:									# delay routine
	li x6,20000000							# load an arbitarary value 20000000 to t1 register		
dloop:
	addi x6,x6,-1							# subtract 1 from t1
	bne x6,zero,dloop						# if t1 not equal to 0 branch to label loop
	ret	
