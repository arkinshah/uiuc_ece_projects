#include "filesys.h"

static int32_t index_dir = 0; /* The number of times dir_read is called */
static boot_block_t *boot; /* Pointer to the filesystem */
static dentry_t *directory_entry[MAX_DIRECTORIES]; /* Directory entry array */
static inode_t *inode_entry;

/* 
 * reset_index_dir
 *   DESCRIPTION: resets index so that files can be read from the start
 *   INPUTS: none
 *   OUTPUTS: Sets index_dir of directory) to 0
 *   RETURN VALUE: (void)
 *   SIDE EFFECTS: None
 */
void reset_index_dir(){

	if(index_dir >= boot->num_dir_entries) index_dir = 0;
}

// void set_index_dir(int32_t val){

// 	index_dir = val;
// }

/* Local functin to get size of file from inode */
//static uint32_t get_file_size(int32_t inode);

/* 
 * file_system_init
 *   DESCRIPTION: Initialises file system
 *   INPUTS: none
 *   OUTPUTS: Sets variables for further use
 *   RETURN VALUE: 0
 *   SIDE EFFECTS: None
 */
int32_t file_system_init(){

	/* Get the starting address of the bootblock */
	boot = (boot_block_t *)bootblk_start;
/*
	boot->num_dir_entries = *((uint32_t *)(bootblk_start + NUM_DIR_ENTRIES_OFFSET));
	boot->num_inodes = *((uint32_t *)(bootblk_start + NUM_INODES_OFFSET));
	boot->num_data_blocks = *((uint32_t *)(bootblk_start + NUM_DATA_BLOCKS_OFFSET));
*/
	// fetch num of directories
	int num_directories = boot->num_dir_entries;
	int i;

	// iterate through directories to get addresses of directories
	for(i=0; i<num_directories; i++){
		directory_entry[i] = (dentry_t *)(bootblk_start + (i + 1) * DIR_ENTRIES_OFFSET);
	}

	// fetch inodes address
	inode_entry = (inode_t *)(bootblk_start + DATA_BLK_SIZE);
	return 0;
}

/* 
 * file_read
 *   DESCRIPTION: Reads data from file
 *   INPUTS:	fd:			location
 * 				buf:		buffer to fill
 * 				nbytes:		size of bytes to be accessed
 * 				filename:	filename
 * 				offset:		offeset to access
 * 			 
 *   OUTPUTS: Writes file into buffer
 *   RETURN VALUE: 0 if success, -1 if failure
 *   SIDE EFFECTS: None
 */
int32_t file_read(int32_t fd, void *buf, int32_t nbytes){
    //TODO: uses read_data()
	//modify this code to for fd (CP3) (modified) in future checkpoints (3,4 maybe)
	//calling read_data from random bs inode number and offset

	// sanity check for bad args
	if(buf == NULL) {return -1;}
	if(fd < 0 || fd >= MAX_NUM_FILES){return -1;}

	// get the start address of the running process in PCB
	// PCB rgows up from 8MB in kernel memory
	//pcb_t* pcb_start = EIGHTMB - ((num_task_running+1) * EIGHTKB);

	// get pointer to file descriptor in PCB for that given process
	//file_desc_t *file_descriptor_index = &(cur_pcb->fdt[fd]);

	uint32_t offset = cur_pcb->fdt[fd].file_pos;
	uint32_t inode_number = cur_pcb->fdt[fd].inode;
	// fetch num of directories
	// int num_directories = boot->num_dir_entries;
	// int i;
	int32_t bytes_read = -1;

	bytes_read = read_data(inode_number, offset, buf, nbytes);

	// search for the name of the file and read
	// for(i=0; i<num_directories; i++){
	// 	if(!strncmp((const int8_t*)(directory_entry[i]->filename), (const int8_t*)filename, NAME_SIZE)){
	// 		//using offset 0 currently, might change later
	// 		bytes_read = read_data(directory_entry[i]->inode, offset, buf, nbytes);
	// 		break;
	// 	}
	// }
	if(bytes_read != -1){
		/*Update file_pos in this case8*/

		//check with TA what to do if offset increases becomes greater than the file size
		(cur_pcb->fdt[fd]).file_pos += bytes_read;
	}

	return bytes_read;
}

/* 
 * file_write
 *   DESCRIPTION: Writes into file
 *   INPUTS: 	fd:			file location
 * 				buf:		buffer to write
 * 				nbytes:		size of bytes to be written
 *   OUTPUTS: Writes into file
 *   RETURN VALUE: -1, always fails
 *   SIDE EFFECTS: None, always fails
 */
int32_t file_write(int32_t fd, const void *buf, int32_t nbytes){
    return -1;
}

/* 
 * file_open
 *   DESCRIPTION: Opens file
 *   INPUTS: 	filename
 *   OUTPUTS: Opens file
 *   RETURN VALUE: 0, always succeeds
 *   SIDE EFFECTS: None
 */
int32_t file_open(const uint8_t *filename){
    return 0;
}

/* 
 * file_close
 *   DESCRIPTION: Closes file
 *   INPUTS: 	fd : file location
 *   OUTPUTS: Closes File
 *   RETURN VALUE: 0, always succeeds
 *   SIDE EFFECTS: None
 */
int32_t file_close(int32_t fd){
    return 0;
}

/* 
 * read_dentry_by_name
 *   DESCRIPTION: Reads a dentry into the structure passed as parameter if a file with given filename exists.
 *   INPUTS: fname: Name of the file
			 dentry: Directory entry structure
 *   OUTPUTS: none
 *   RETURN VALUE: 0 on success and -1 on failure.
 *   SIDE EFFECTS: None
 */
int32_t read_dentry_by_name(const uint8_t* fname, dentry_t* dentry){
    //TODO
	
	if(fname == NULL){return -1;}

	/* Local variable */
	int32_t cur_addr;
	//uint8_t cur_name[NAME_SIZE];
	
	uint32_t flen = strlen((const int8_t*)fname);

	//printf("File Length: %d \n", flen);
	if(flen > NAME_SIZE){return -1;}
	
	//puts((int8_t*)fname);
	//printf("\n");
	
	uint32_t i = 0;
	int32_t equal = 1;
	
	// iterate through all inodes and fetch data
	for(i = 0; i < boot->num_inodes; i++){
		
		cur_addr = bootblk_start + BOOT_BLK_STATS_SIZE + i*(DENTRY_SIZE);
		/*if(*((uint32_tp cur*)cur_addr) != 0){
			printf("The name of current file is\n");
			puts((int8_t*)cur_addr);
			printf("\n");
		}*/

		/* Check for strings that are similar */
		if(stringlength((const int8_t*)cur_addr, (const int8_t*)fname) == -1) continue;
		
		if(flen <= NAME_SIZE){
			/* Compare strings */
			equal = strncmp((const int8_t*)fname, (const int8_t*)cur_addr, flen);
			
		}else{
			/* Compare strings */
			equal = strncmp((const int8_t*)fname, (const int8_t*)cur_addr, NAME_SIZE);

		}
		
		/* copy data into dentry if match is found */
		if(equal == 0){
			
			strncpy((int8_t*)dentry->filename, (const int8_t*)fname, NAME_SIZE);
			
			cur_addr = cur_addr + NAME_SIZE; /* NOT SURE ABOUT THIS */
			
			dentry->filetype = *((uint32_t*)cur_addr);
			dentry->inode = *((uint32_t*)cur_addr + 1);
			
			/* Return success */
			return 0;
		}
	}
	
	return -1;
}

/* 
 * read_dentry_by_index
 *   DESCRIPTION: Reads a dentry into the structure passed as parameter if a file with given filename exists.
 *   INPUTS: index: index of the file
			 dentry: Directory entry structure
 *   OUTPUTS: none
 *   RETURN VALUE: 0 on success and -1 on failure.
 *   SIDE EFFECTS: Data is copied into dentry
 */
int32_t read_dentry_by_index(uint32_t index, dentry_t* dentry){
    //TODO

    //fetch initial addresses and values
    uint32_t *base_add = (uint32_t *)bootblk_start;
    uint32_t num_dir = *base_add;
    int i;

    // sanity check for bad arg
    if(index < 0 || index >= num_dir){
        return -1;
    }

    // fetch dentry file location
    uint32_t *file_loc = (uint32_t *)(bootblk_start + DENTRY_SIZE + (index*DENTRY_SIZE));

    // traverse and copy file name from dentry in memory to dentry in argument
    for(i = 0; i < NAME_SIZE; i++){
        dentry->filename[i] = *((uint8_t*)file_loc + i);
    }

    // Null terminate for string because idk if our version has a null terminate
    // dentry->filename[NAME_SIZE] = '\0';

    // update and copy other fields as well
    dentry->filetype = *((uint8_t *)file_loc + NAME_SIZE);
    dentry->inode = *((uint8_t *)file_loc + NAME_SIZE + NUM_INODES_OFFSET);

    return 0;
}

/* 
 * read_data
 *   DESCRIPTION: Reads a given number of bytes from a file into a buffer passed into as an parameter.
 *   INPUTS: inode: The inode number
			 offset: Offset into the file
			 buf: The buffer to fill update
			 length: Number of bytes to be read
 *   OUTPUTS: none
 *   RETURN VALUE: Number of bytes read into buffer
 *   SIDE EFFECTS: None
 */
int32_t read_data(uint32_t inode, uint32_t offset, uint8_t * buf, uint32_t length){

	if(buf == NULL) return -1;

	uint32_t count = 0;

	/* ASSUMPTION: The inode number is not absolute */
	if (inode >= boot->num_inodes) return -1; /* Return failure if inode number is invalid */
	
	// set intial values
	int32_t pos = offset % DATA_BLK_SIZE;
	int32_t data_block_idx = offset/DATA_BLK_SIZE;
	int32_t inode_addr = bootblk_start + (inode + 1)*DATA_BLK_SIZE;
	int32_t data_block_num = 0;
	int32_t data_block_addr = 0;
	int32_t cur_addr = 0;
	int8_t cur_data = 0;
	
	int32_t file_size = *((int32_t*)inode_addr);
	
	for(count = 0; count < length; count++){
		
		/* Stop reading if end of file reached */
		if(pos + DATA_BLK_SIZE*data_block_idx >= file_size) break;
	
		/* Read from next block if block is finished */
		if(pos >= DATA_BLK_SIZE){
			
			pos = 0;
			data_block_idx++;
		}
		
		/* Stop reading if file is done */
		if(data_block_idx >= NUM_DATA_BLK_IN_INODE) break;
		
		/* Get the block number to read from */
		data_block_addr = inode_addr + (DATA_BLOCK_OFFSET)*data_block_idx + DATA_BLOCK_OFFSET;
		data_block_num = *((int32_t*)data_block_addr);
		
		/* Fail if the block number is invalid */
		if(data_block_num > boot->num_data_blocks) return -1; /* Fail if data block number is invalid */
		
		/* Get the address of the block */
		cur_addr = bootblk_start + (1+boot->num_inodes)*DATA_BLK_SIZE + data_block_num*DATA_BLK_SIZE + pos;
		/* Get a byte of data from the block */
		cur_data = *((int8_t*)cur_addr);
		
		/* Update buffer */
		buf[count] = (uint8_t)cur_data;
		
		/* Update counter and position */
		pos++;
	}
	
	if(count < length){ //broke somewhere in between
		buf[count] = '\0';
	}
	return count;
}

// static int index_dir = 0;
// Daksh = copied this static int above
// CHECK if we need to implement the static int (and possibly increment it), I think we should just take the index argument
// but my friend did it the other way so i might be wrong

/* Daksh - Appendix B: Pg 19: (read pararaph): reads should read from successive directory entry
		   until last is reached" , therefore have to use static int to keep track of where we are
*/

/* 
 * dir_read
 *   DESCRIPTION: Reads a directory if it exists
 *   INPUTS: buf: name of file
 *   OUTPUTS: none
 *   RETURN VALUE: 0 on success and -1 on failure.
 */
int32_t dir_read(int32_t fd, void *buf, int32_t nbytes){
    //TODO
	int32_t ret_val = -1;

	if(!buf){return -1;}

	int i;
	dentry_t dentry;
	/* Constantly return 0 if reachedn end of subsequent directories */
	if(index_dir >= boot->num_dir_entries) return 0;

	/*Keep the 33rd byte always NULL for verylongfiles*/
	for(i = 0; i < NAME_SIZE; i++){
		((uint8_t*)buf)[i] = '\0';
	}

	if(!read_dentry_by_index(index_dir,&dentry)){
		for(i = 0; i < NAME_SIZE; i++){
			((uint8_t*)buf)[i] = dentry.filename[i];
			if(dentry.filename[i] == '\0'){
				//as much as fits the name (Null terminated)
				break;
			}
		}
		
		index_dir++;
		ret_val = strlen((int8_t*)dentry.filename);
		if(ret_val > NAME_SIZE){ret_val = NAME_SIZE;}
		return ret_val;
	}

	/*Should reach here only if index is -ve (is wrong) */
	index_dir++;
	return -1;
}

/* 
 * dir_write
 *   DESCRIPTION: Writes into directory
 *   INPUTS: none
 *   OUTPUTS: Always fails
 *   RETURN VALUE: 0 on success and -1 on failure.
 *   SIDE EFFECTS: None
 */
int32_t dir_write(int32_t fd, const void *buf, int32_t nbytes){
    return -1;
}

/* 
 * dir_open
 *   DESCRIPTION: Opens Directory
 *   INPUTS: filename
 *   OUTPUTS: Opens directory
 *   RETURN VALUE: 0 on success and -1 on failure.
 *   SIDE EFFECTS: None
 */
int32_t dir_open(const uint8_t *filename){
    //TODO
	// can and connot use read_data_by_name

	dentry_t dentry;
	if(!read_dentry_by_name(filename, &dentry)) return 0;
	/* if name file does not exist or no descriptors are free*/
	return -1;
}

/* 
 * dir_close
 *   DESCRIPTION: Closes Directory
 *   INPUTS: none
 *   OUTPUTS: Always succeeds
 *   RETURN VALUE: 0 on success and -1 on failure.
 *   SIDE EFFECTS: None
 */
int32_t dir_close(int32_t fd){
    return 0;
}

/* 
 * copy_program
 *   DESCRIPTION: Copies the image of program from filesys image to user space
 *   INPUTS: d: The direcory entry for the image file
 *   OUTPUTS: None
 *   RETURN VALUE: 0 on success, -1 on failure
 *   SIDE EFFECTS: Edits memory
 */
int32_t copy_program(dentry_t d){

		/* Get file size */
		//uint32_t s = get_file_size(d.inode);
		uint32_t offset = 0;
		int32_t cnt = 0;
		uint8_t* user_program_pos = (uint8_t*)USER_SPACE_IMG_LOAD;
		/* Read the file into a buffer */
		uint8_t buf[HALF_KB];
		//if(size != read_data(d.inode, 0, buf, size)) return -1;

		while(0 != (cnt = read_data(d.inode, offset, buf, HALF_KB))){

			memcpy(user_program_pos, buf, cnt);
			offset += cnt;
			user_program_pos += cnt;
		}

		/* Copy that buffer  into user memory */
		//memcpy((uint8_t*)USER_SPACE_IMG_LOAD, buf, size);

		return 0;
}

/* 
 * get_file_size
 *   DESCRIPTION: Gets the file size given the file inode index
 *   INPUTS: inode: The inode index of the file
 *   OUTPUTS: None
 *   RETURN VALUE: Size of the file
 *   SIDE EFFECTS: None
 */
// uint32_t get_file_size(int32_t inode){

// 	return *(uint32_t *)(bootblk_start + (inode + 1)*DATA_BLK_SIZE);
// }

/* 
 * stringlength
 *   DESCRIPTION: Compares strings
 *   INPUTS: string_one, string_two: The two strings to compare
 *   OUTPUTS: None
 *   RETURN VALUE: 0 for same strings, -1 for different strings
 *   SIDE EFFECTS: None
 */
uint32_t stringlength(const int8_t *string_one, const int8_t *string_two){

	uint32_t i = 0;

	while(string_one[i] == string_two[i]){

		/* Return 1 if either string ends before the other */
		if(string_one[i] == '\0' && string_two[i] != '\0'){return -1;}
		if(string_two[i] == '\0' && string_one[i] != '\0'){return -1;}

		/* Return 0 if strings are same */
		if(string_one[i] == '\0' && string_two[i] == '\0'){return 0;}

		i++;

		/* If string is longer than name size, return 0 */
		if(i == NAME_SIZE){
			return 0;
		}
	}
	
	return -1;
}
