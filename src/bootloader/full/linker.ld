ENTRY(entry)
OUTPUT_FORMAT("binary")

phyAddr = 0x00000500;

SECTIONS
{
    . = phyAddr;

    .entry  : { __entry_start = .;   *(.entry)  }
    .text   : { __text_start = .;    *(.text)   }
    .data   : { __data_start = .;    *(.data)   }
    .rodata : { __rodata_start = .;  *(.rodata) }
    .bss    : { __bss_start = .;     *(.bss)    }

    __end = .;
}
