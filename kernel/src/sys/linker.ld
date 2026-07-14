ENTRY(start)
OUTPUT_FORMAT("binary")
phys = 0x00100000;

SECTIONS
{   
    . = 0x00008000;
    .low_mem            : { __low_mem_start = .;    *(.low_mem) }
    __low_mem_end = .;



    . = phys;

    .entry              : { __entry_start = .;      *(.entry)   }
    .text               : { __text_start = .;       *(.text*)   }
    .data               : { __data_start = .;       *(.data*)   }
    .rodata             : { __rodata_start = .;     *(.rodata*) }
    .bss                : { __bss_start = .;        *(.bss*)    }
    
    __end = .;

    /DISCARD/ :
    {
        *(.comment)
        *(.eh_frame)
        *(.note*)
    }
}