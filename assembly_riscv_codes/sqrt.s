.set STDIN, 0
.set STDOUT, 1
.set SYS_READ, 63
.set SYS_WRITE, 64
.set SYS_EXIT, 93
.set OUT_MESSAGE_LEN, 11
.set INPUT_MESSAGE_LEN, 21
.set BUFFER_LEN, 256

.section .rodata
input_message:  .ascii "Digite o valor de x:\n"
output_message: .ascii "Resultado:\n"

.section .bss
buffer: .skip BUFFER_LEN

.section .text
.globl _start

_start:
    # .insn r 0x0B, 1, 0, a0, a1, a2
    # Write input prompt
    li a7, SYS_WRITE
    li a0, STDOUT
    la a1, input_message
    li a2, INPUT_MESSAGE_LEN
    ecall

    # Read the input value
    li a7, SYS_READ
    li a0, STDIN
    la a1, buffer
    li a2, BUFFER_LEN
    ecall

    # Remove \n from the read line
    addi a0, a0, -1

    # Parse read bytes to integer
    li t0, 0  # Result
    li t1, 0  # Iterator
string_to_integer_for_start:
    bge t1, a0, string_to_integer_for_end
    add t2, t1, a1
    lb  t2, 0(t2)
    slli t3, t0, 3
    slli t4, t0, 1
    addi t0, t2, -'0'
    add  t0, t0, t3
    add  t0, t0, t4
    addi t1, t1, 1
    j    string_to_integer_for_start
string_to_integer_for_end:

    # Calculate square root
    li t1, 1 # result
    li t2, 2 # d
    li t3, 4 # s
sqrt_while_start:
    bgt  t3, t0, sqrt_while_end
    addi t1, t1, 1
    addi t2, t2, 2
    addi t3, t3, 1
    add  t3, t3, t2
    j sqrt_while_start
sqrt_while_end:

    # Convert the integer back to a string
    li t0, 0 # iterator until string end
    li t2, 10 # constant 10
integer_to_string_while_start:
    blez t1, integer_to_string_while_end
    bgeu t0, a2, integer_to_string_while_end
    rem  t3, t1, t2
    addi t3, t3, '0'
    add  t4, t0, a1
    sb   t3, 0(t4)
    div  t1, t1, t2
    addi t0, t0, 1
    j integer_to_string_while_start
integer_to_string_while_end:

    # Reverse the string to get the correct output
    li   t1, 0      # first
    addi t6, t0, -1 # last
reverse_string_start:
    bge t1, t6, reverse_string_end
    add t2, t1, a1
    add t3, t6, a1
    lb t4, 0(t2)
    lb t5, 0(t3)
    sb t4, 0(t3)
    sb t5, 0(t2)
    addi t1, t1, 1
    addi t6, t6, -1
    j reverse_string_start
reverse_string_end:

    # Write result prompt
    li a7, SYS_WRITE
    li a0, STDOUT
    la a1, output_message
    li a2, OUT_MESSAGE_LEN
    ecall

    # Add a newline into the converted string
    la   a1, buffer
    # FIX: This could overflow the string size if the number is too big.
    add  t1, t0, a1
    li   a2, '\n'
    sb   a2, 0(t1)
    addi t0, t0, 1
    # Write the result
    li a7, SYS_WRITE
    li a0, STDOUT
    mv a2, t0
    ecall

    # Exit
    li a7, SYS_EXIT
    li a0, 0
    ecall
