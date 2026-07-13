ENTRY(_start)
OUTPUT_FORMAT("binary")

SECTIONS
{
    /* Stage 2 is loaded at 0x0000:0x0500 by boot5.asm */
    . = 0x0500;

    .text : {
        *(.text)
        *(.text.*)
    }

    .data : {
        *(.data)
        *(.data.*)
        *(.rodata)    /* CRITICAL: Include read-only constants like strings here */
        *(.rodata.*)
    }

    .bss : {
        __bss_start = .;    /* Creates the missing symbol at the start of BSS */
        *(.bss)
        *(.bss.*)
        *(COMMON)           /* Catches uninitialised global variables */
        __bss_end = .;      /* Creates a symbol at the end of BSS */
    }
}
