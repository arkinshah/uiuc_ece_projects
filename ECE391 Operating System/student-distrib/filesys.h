#ifndef _FILESYS_H
#define _FILESYS_H

#include "types.h"
#include "lib.h"
#include "system_call.h"
#include "pcb.h"

#define DENTRY_SIZE 64 /* dentry size */
#define NAME_SIZE 32 /* Max name size */
#define RESERVED_DENTRY_SIZE 24 /* Reserved space size in dentry */
#define MAX_DATA_BLOCK_SIZE 1023 /* Maximum number of data block location in inode */
#define RESERVED_BOOTBLOCK_BYTES 52
#define MAX_DIRECTORIES 63 /* Maximum number of directory entries */
#define MAX_NUM_INODES 63 /* Maximum number of possible inodes */
#define DATA_BLK_SIZE 4096 /* Size of each data block in bytes */
#define BLOCK_SIZE 1024 /* Number of memory addresses in each block */
#define MAX_NUM_DATA_BLOCKS 111111 /*VERY IMPORTANT: NOT YET SURE ABOUT THIS VALUE */
#define NUM_DATA_BLK_IN_INODE 1023 /* Maximum number of data block location in inode */
#define BOOT_BLK_STATS_SIZE 64 /* Size of boot block stats */
#define NUM_DIR_ENTRIES_OFFSET 0 /* Number of directories offset */
#define NUM_INODES_OFFSET 4 /* Number of inodes offset */
#define NUM_DATA_BLOCKS_OFFSET 8 /* Number of data blocks offset */
#define DIR_ENTRIES_OFFSET 64 /* Directory entries offset */
#define DATA_BLOCK_OFFSET 4 /* Data block offset */
#define USER_SPACE_IMG_LOAD 0x08048000 /* User space program address */
#define HALF_KB 512 /* Buffer size to copy program */

uint32_t bootblk_start;

typedef struct dentry{
    uint8_t filename[NAME_SIZE];                    //32B long
    uint32_t filetype;                              //4B  
    uint32_t inode;                                 //4B  
    uint8_t reserved[RESERVED_DENTRY_SIZE];         //24B  
}dentry_t;

typedef struct boot_block{
    uint32_t num_dir_entries;
    uint32_t num_inodes;
    uint32_t num_data_blocks;
    uint8_t reserved[RESERVED_BOOTBLOCK_BYTES];
    dentry_t dir_entries[MAX_DIRECTORIES];
}boot_block_t;

/* The inode structure */
typedef struct inode{
	int32_t length;
	int32_t data_block[MAX_DATA_BLOCK_SIZE];
}inode_t;

/* Reads directory entry by name */
extern int32_t read_dentry_by_name(const uint8_t* fname, dentry_t* dentry);
/* Reads directory entry by index */
extern int32_t read_dentry_by_index(uint32_t index, dentry_t * dentry);
/* Reads dfile data */
extern int32_t read_data(uint32_t inode, uint32_t offset, uint8_t * buf, uint32_t length);

/* The file read/write/opne/close functions */
int32_t file_read(int32_t fd, void *buf, int32_t nbytes);
int32_t file_write(int32_t fd, const void *buf, int32_t nbytes);
int32_t file_open(const uint8_t *filename);
int32_t file_close(int32_t fd);

/* Directory read/write/open/close functions */
int32_t dir_read(int32_t fd, void *buf, int32_t nbytes);
int32_t dir_write(int32_t fd, const void *buf, int32_t nbytes);
int32_t dir_open(const uint8_t *filename);
int32_t dir_close(int32_t fd); 

/* Copy data from file system to user space */
int32_t file_system_init();

/* Copy data from file system to user space */
int32_t copy_program(dentry_t d);

/* Resets static variable index_dir */
void reset_index_dir();

/* Compares strings */
uint32_t stringlength(const int8_t *string_one, const int8_t *string_two);

#endif
