#ifndef _PAGING_H
#define _PAGING_H

#define PAGE_LEN 1024
#define PHY_ADD 12
#define FOUR_MB_ADDRESS 22
#define FOURKB 0x1000
#define FOURMB 0x400000
#define EIGHTMB 0x800000
#define VIDMEM 0xB8000
#define USER_PROGRAM_VIR_ADDR 0x8000000
#define USER_PROGRAM_PDT_IDX 0x20
#define KERNAL_END_PAGING 0x800000
#define MAGICSPOT 0x22
#define _136MB 0x8800000

#include "types.h"

/* Initialize Paging Here. Declaration here. Definition given in paging.c file */
extern void init_paging();

extern void flush_tlb();

/* Page Table Entry to map bits correctly. Goes into Paging. Code modified from existing code given in x86_desc.h */
typedef struct pte_desc_t {
	union {
	uint32_t val;
		struct {
		uint32_t present        : 1;
        uint32_t rw             : 1;
        uint32_t user_super     : 1;
        uint32_t write_through  : 1;
        uint32_t cache_disabled : 1;
        uint32_t accessed       : 1;
        uint32_t dirty          : 1;
        uint32_t pta            : 1;
        uint32_t global         : 1;
        uint32_t avail_9_11     : 3;
        uint32_t pagebase_31_12 : 20;
		} __attribute__ ((packed));
	};
} pte_desc_t;

/* Page Descriptor Table Entry to map bits correctly. Goes into Paging. Code modified from existing code given in x86_desc.h */
typedef struct pde_desc_t {
	union {
		uint32_t val;
		struct {
		uint32_t present        : 1;
        uint32_t rw             : 1;
        uint32_t user_super     : 1;
        uint32_t write_through  : 1;
        uint32_t cache_disabled : 1;
        uint32_t accessed       : 1;
        uint32_t reserved_0     : 1; // set to 0
        uint32_t page_size      : 1; // 0 means 4KB
        uint32_t global         : 1; // ignored
        uint32_t avail_9_11     : 3;
        uint32_t pagebase_31_12 : 20;
        // union {
        //     uint32_t pagebase_31_12 : 20;
        //     struct{
        //         uint32_t reserved_21_12: 10;   //if Page Table deos not exist (point to 4MiB pages)
        //         uint32_t pagebase_31_22: 10;
        //     } __attribute__ ((packed));
        // };
		} __attribute__ ((packed));
	};
} pde_desc_t;

/* Swap pages for user program */
int32_t add_page_for_process(int32_t pid);

/* Paging for vidmap */
void vidmap_paging(int32_t terminal, int32_t make_active);

/* Flush tlb */
void flush_tlb();

#endif
