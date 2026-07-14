section .low_mem

; MACRO: Enter 16-bit Real Mode
%macro x86_EnterRealMode 0
    [bits 32]
    jmp word 18h:.pmode16         ; Jump to 16-bit Protected Mode descriptor

.pmode16:
    [bits 16]
    mov eax, cr0
    and al, ~1                    ; Clear PE (Protection Enable) bit
    mov cr0, eax

    ; Far jump to clear prefetch queue and set Real Mode CS (0x0000)
    ; Assumes section is linked at 0x8000 or absolute lower memory
    jmp 0x0000:.rmode

.rmode:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    sti                           ; Enable real-mode interrupts
%endmacro


; Enter 32-bit Protected Mode
%macro x86_EnterProtectedMode 0
    [bits 16]
    cli                           ; Disable real-mode interrupts

    mov eax, cr0
    or al, 1                      ; Set PE bit
    mov cr0, eax

    jmp dword 08h:.pmode          ; Far jump into 32-bit PM (CS = 0x08)

.pmode:
    [bits 32]
    mov ax, 0x10                  ; Update data segments (DS/SS = 0x10)
    mov ds, ax
    mov ss, ax
%endmacro


; Convert Linear Address to Segment:Offset
; The ruelz
;    1 - linear address input register/memory (e.g., [ebp + 28])
;    2 - target segment register output (e.g., es)
;    3 - target 32-bit register for calculation (e.g., eax)
;    4 - target lower 16-bit half of #3 (e.g., ax)
%macro LinearToSegOffset 4
    mov %3, %1                    ; Load full 32-bit linear address
    shr %3, 4                     ; Shift right by 4 bits to get the segment base
    mov %2, %4                    ; Safely move the 16-bit segment value into the Segment Register (e.g., es)
    
    mov %3, %1                    ; Reload the original 32-bit linear address
    and %3, 0x000F                ; Mask all but the last 4 bits. %4 (ax) now holds the exact 16-bit offset (0-15)
%endmacro


global x86_outb
x86_outb:
    [bits 32]
    mov dx, [esp + 4]
    mov al, [esp + 8]
    out dx, al
    ret

global x86_inb
x86_inb:
    [bits 32]
    mov dx, [esp + 4]
    xor eax, eax
    in al, dx
    ret


global x86_Disk_GetDriveParams
x86_Disk_GetDriveParams:
    [bits 32]
    push ebp             
    mov ebp, esp         

    x86_EnterRealMode
    [bits 16]

    push es
    push bx
    push esi
    push di

    ; Using ebp explicitly overrides 16-bit restriction safely
    mov dl, [ebp + 8]    
    mov ah, 08h
    xor di, di           
    mov es, di
    stc
    int 13h

    mov eax, 1
    sbb eax, 0            ; Return 1 on success, 0 on failure

    ; Store drive type
    LinearToSegOffset [ebp + 12], es, esi, si
    mov [es:si], bl

    ; Calculate and store cylinders
    mov bl, ch          
    mov bh, cl          
    shr bh, 6
    inc bx
    LinearToSegOffset [ebp + 16], es, esi, si
    mov [es:si], bx

    ; Calculate and store sectors
    xor ch, ch          
    and cl, 3Fh
    LinearToSegOffset [ebp + 20], es, esi, si
    mov [es:si], cx

    ; Calculate and store heads
    mov cl, dh          
    inc cx
    LinearToSegOffset [ebp + 24], es, esi, si
    mov [es:si], cx

    pop di
    pop esi
    pop bx
    pop es

    push eax
    x86_EnterProtectedMode
    [bits 32]
    pop eax

    mov esp, ebp
    pop ebp
    ret


global x86_Disk_Reset
x86_Disk_Reset:
    [bits 32]
    push ebp             
    mov ebp, esp          

    x86_EnterRealMode
    [bits 16]

    mov ah, 0
    mov dl, [ebp + 8]    
    stc
    int 13h

    mov eax, 1
    sbb eax, 0              

    push eax
    x86_EnterProtectedMode
    [bits 32]
    pop eax

    mov esp, ebp
    pop ebp
    ret


global x86_Disk_Read
x86_Disk_Read:
    [bits 32]
    push ebp             
    mov ebp, esp          

    x86_EnterRealMode
    [bits 16]

    push ebx
    push es

    mov dl, [ebp + 8]      ; Drive ID

    mov ch, [ebp + 12]     ; Cylinder low bits
    mov cl, [ebp + 13]     ; Cylinder high bits
    shl cl, 6
    
    mov al, [ebp + 16]     ; Sector number
    and al, 3Fh
    or cl, al

    mov dh, [ebp + 20]     ; Head number
    mov al, [ebp + 24]     ; Sector count

    ; Convert C destination pointer to Real Mode Seg:Offset
    LinearToSegOffset [ebp + 28], es, ebx, bx

    mov ah, 02h
    stc
    int 13h

    mov eax, 1
    sbb eax, 0             

    pop es
    pop ebx

    push eax
    x86_EnterProtectedMode
    [bits 32]
    pop eax

    mov esp, ebp
    pop ebp
    ret
