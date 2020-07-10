#ifndef _PCB_H
#define _PCB_H

#include "x86_desc.h"
#include "terminal.h"
// #include "keyboard.h"
#include "types.h"

#define MAX_NUM_FILES 8 /* Maximum number of files in file descriptor table */
#define FILE_DESC_SIZE 16 /* Ffile descriptor entry size */
#define FILE_JUMP_TABLE_SIZE 16 /* File jump table size */
#define EIGHT_KB 8192 /* 8kB size in bytes */
#define KERNEL_END_PCB 0x800000 /* Kernal end address used by pcb */
#define ARG_SIZE	117	/* largest command is 9 + '\0' characters, testprint, so it's keyboard_buffer_sz - 10 */


/* Data structure for the file functions jump table */
typedef struct file_jump_table{

	int32_t (*read) (int32_t fd, void* buf, int32_t nbytes);
	int32_t (*write) (int32_t fd,const void* buf, int32_t nbytes);
	int32_t (*open) (const uint8_t* filename);
	int32_t (*close) (int32_t fd);

}file_jump_table;

/* Data structure for the file descriptor */
typedef struct file_desc_t{
	
	file_jump_table* file_jmp_table_ptr;
	uint32_t inode;
	int32_t file_pos;
	int32_t flags; /* 1 if in use, 0 otherwise */
	
}file_desc_t;

/* The Process Control Block data structure */
typedef struct pcb_t{
	/* File Descriptor Table data structures */
	file_jump_table file_jump_tables_arr[MAX_NUM_FILES];
	file_desc_t fdt[MAX_NUM_FILES];
	/* The  Process ID */
	int32_t pid;
	int32_t is_shell;
	int32_t esp;
	int32_t ebp;
	int32_t eip;
	/* State of the parent  */
	struct pcb_t* parent_pcb_ptr;
	int32_t parent_pid;
	int32_t parent_esp;
	int32_t parent_ebp;
	/* Arguments for process */
	uint8_t arguments[ARG_SIZE];
	
}pcb_t;

/* Function to load PCB for a given process */
int32_t load_pcb(pcb_t* parent_pcb, int32_t pid, int32_t is_shell);

pcb_t* get_pcb_from_pid(int32_t pid);

#endif
