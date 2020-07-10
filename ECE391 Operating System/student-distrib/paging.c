#include "paging.h"

#define VIDMEM_INDEX 0xB8

/* Page table */
static pte_desc_t page_table[1024] __attribute__((aligned(FOURKB)));

/* Page descriptor table */
static pde_desc_t page_descriptor[1024] __attribute__((aligned(FOURKB)));

/* Video Map table */
static pte_desc_t vidmap_table[1024] __attribute__((aligned(FOURKB)));

/* 
 * ENABLE_PAGING
 *   DESCRIPTION: A macro to enable paging.
 *   INPUTS: page_directory: The address of the Page Directory Table.
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: Changes paging flags.
 */

// movl src, dest

#define ENABLE_PAGING(page_directory) 	\
do{ 									\
	asm volatile(" 						\
					movl %0, %%eax	    ;\
					movl %%eax, %%cr3	;\
					movl %%cr4, %%eax	;\
					orl $0x00000010, %%eax;\
					movl %%eax, %%cr4	;\
					movl %%cr0, %%eax	;\
					orl $0x80000001, %%eax;\
					movl %%eax, %%cr0	"\
				 :                      \
				 : "a" (page_directory) \
				 : "memory" 		\
		);								\
} while (0)

/* 
 * init_paging
 *   DESCRIPTION: Initialize paging. Creates Page table and Page directory. Divides memory into pages.
 *   INPUTS: none
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: Virtualizes memory. Modifies memory.
 */
void init_paging()
{
	/* Set all entries of the page table and page directory to 0. Also, set page table address bits for each PTE.
	 Also, for each PTE and PDE make the rw bit 1. */
    int i;
    for (i = 0; i < PAGE_LEN; i++)
    {
        page_descriptor[i].val = 0;
        page_descriptor[i].rw = 1;

        page_table[i].val = 0;
        page_table[i].pagebase_31_12 = i;
        page_table[i].rw = 1;

    }

	/* Make the page descriptor entry for the first 4 MB of memory */
    page_descriptor[0].present = 1;
    page_descriptor[0].pagebase_31_12 = (uint32_t)(page_table) >> (uint32_t)PHY_ADD;

	/* Make the page table entry for video memory */
    page_table[VIDMEM_INDEX].present = 1;
	page_table[VIDMEM_INDEX+1].present = 1;
	page_table[VIDMEM_INDEX+2].present = 1;
	page_table[VIDMEM_INDEX+3].present = 1;

    page_descriptor[1].present = 1;
	page_descriptor[1].page_size = 1; //since, 1 have to use 4MB addresses
    page_descriptor[1].pagebase_31_12 = (uint32_t)FOURMB >> PHY_ADD;
	//page_descriptor[1].reserved_21_12 = 0;

    //enable_paging((uint32_t) page_descriptor);
	ENABLE_PAGING((uint32_t)page_descriptor);

    // page_descriptor[0].pagebase_31_12 = &page_table[0]; bug log worthy

}

/* 
 * add_page_for_process
 *   DESCRIPTION: Makes a PDE for the user program image at address 0x8000000
 *   INPUTS: pid: The Process ID
 *   OUTPUTS: none
 *   RETURN VALUE: Returns 0x8000000
 *   SIDE EFFECTS: Writes to Page directory
 */
int32_t add_page_for_process(int32_t pid){

	page_descriptor[USER_PROGRAM_PDT_IDX].val = KERNAL_END_PAGING + pid*FOURMB;

	//page_descriptor[USER_PROGRAM_PDT_IDX].pagebase_31_12 = (int32_t)(FOURMB*(pid + 2)) >> PHY_ADD;
	page_descriptor[USER_PROGRAM_PDT_IDX].present = 1;
	page_descriptor[USER_PROGRAM_PDT_IDX].rw = 1;
	page_descriptor[USER_PROGRAM_PDT_IDX].user_super = 1;
	page_descriptor[USER_PROGRAM_PDT_IDX].page_size = 1;
	flush_tlb();	

	return USER_PROGRAM_VIR_ADDR;
}

/* 
 * vidmap_paging
 *   DESCRIPTION: Setting paging for vidmap
 *   INPUTS: None
 *   OUTPUTS: None
 *   RETURN VALUE: None
 *   SIDE EFFECTS: Changes PDT
 */
void vidmap_paging(int32_t terminal, int32_t make_active)
{
	/* Set all entries of the page table and page directory to 0. Also, set page table address bits for each PTE.
	 Also, for each PTE and PDE make the rw bit 1. */
    int i;
    for (i = 0; i < PAGE_LEN; i++)
    {
		vidmap_table[i].val = 0;
		vidmap_table[i].rw = 1;
		vidmap_table[i].user_super = 1;
		vidmap_table[i].pagebase_31_12 = i;

    }

	/* Make the page descriptor entry starting 8MB because 0-8 are taken */
	page_descriptor[MAGICSPOT].present = 1;
	page_descriptor[MAGICSPOT].pagebase_31_12 = (uint32_t)(vidmap_table) >> (uint32_t)PHY_ADD;
	page_descriptor[MAGICSPOT].user_super = 1;

	if(make_active == 1){
		vidmap_table[0].pagebase_31_12 = VIDMEM >> PHY_ADD;
		vidmap_table[0].present = 1;
	}else{
		vidmap_table[0].pagebase_31_12 = (VIDMEM + FOURKB*terminal) >> PHY_ADD;
		vidmap_table[0].present = 1;
	}

	vidmap_table[1].pagebase_31_12 = (VIDMEM + FOURKB*1) >> PHY_ADD;
	vidmap_table[1].present = 1;
	vidmap_table[2].pagebase_31_12 = (VIDMEM + FOURKB*2) >> PHY_ADD;
	vidmap_table[2].present = 1;
	vidmap_table[3].pagebase_31_12 = (VIDMEM + FOURKB*3) >> PHY_ADD;
	vidmap_table[3].present = 1;


	flush_tlb();

	// return _136MB;
		
}

/* 
 * flush_tlb
 *   DESCRIPTION: Flush 
 *   INPUTS: none
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: Virtualizes memory. Modifies memory.
 */
void flush_tlb(){
	asm volatile("					 \
				movl %cr3, %ebx;\
				movl %ebx, %cr3;"\
	);
}

