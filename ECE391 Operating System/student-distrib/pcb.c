#include "pcb.h"

/* File Ops Table For Each of our Drivers */

static file_jump_table terminal_table_stdin = {terminal_read, error_function_stdin_write, terminal_open, terminal_close};
static file_jump_table terminal_table_stdout = {error_function_stdout_read, terminal_write, terminal_open, terminal_close};


/* 
 * load_pcb
 *   DESCRIPTION: Loads the Process Control Block into kernal
 *   INPUTS: pid: The Process ID
 *           first_instruction_addr: Address of the first instruction for execution
 *   OUTPUTS: none
 *   RETURN VALUE: Returns the address of the pcb block, or 0 on failure
 *   SIDE EFFECTS: Writes to kernal memory
 */
int32_t load_pcb(pcb_t* parent_pcb, int32_t pid, int32_t is_shell){

    /* Fail if no process exists */
    if(pid == -1) return 0;

    /*  */
    uint32_t i;
    pcb_t* cur_pcb = (pcb_t*)(KERNEL_END_PCB - EIGHT_KB*(pid+1)); /* Not sure about adding the 1 */
    int32_t addr = (int32_t)cur_pcb;
    file_desc_t *file_descriptor_idx = NULL;

	/* Make blank File Descriptor Table */
    for(i=0; i< MAX_NUM_FILES; i++){
        cur_pcb->fdt[i].file_jmp_table_ptr = &(cur_pcb->file_jump_tables_arr[i]);
        cur_pcb->fdt[i].flags = 0;
        cur_pcb->fdt[i].file_pos = 0;
    }

    /* initalize argument buffer */
    for (i = 0; i < ARG_SIZE; i++)
        cur_pcb->arguments[i] = '\0';

    /* Open stdin and stdout */
    file_descriptor_idx = &(cur_pcb->fdt[0]);

    /* Load the stdin file descriptor entry */
    // file_descriptor_idx->file_jmp_table_ptr->read = &terminal_read;
    // file_descriptor_idx->file_jmp_table_ptr->write = &terminal_write;
    // file_descriptor_idx->file_jmp_table_ptr->open = &terminal_open;
    // file_descriptor_idx->file_jmp_table_ptr->close = &terminal_close;
    
    file_descriptor_idx->file_jmp_table_ptr = &terminal_table_stdin;
    
    file_descriptor_idx->file_pos = 0;
    file_descriptor_idx->flags = 1;
    

    file_descriptor_idx = &(cur_pcb->fdt[1]);

    /* Load the stdout file descriptor entry */
    // file_descriptor_idx->file_jmp_table_ptr->read = &terminal_read;
    // file_descriptor_idx->file_jmp_table_ptr->write = &terminal_write;
    // file_descriptor_idx->file_jmp_table_ptr->open = &terminal_open;
    // file_descriptor_idx->file_jmp_table_ptr->close = &terminal_close;
    
    file_descriptor_idx->file_jmp_table_ptr = &terminal_table_stdout;
    
    file_descriptor_idx->file_pos = 0;
    file_descriptor_idx->flags = 1;

    /* Set the current pid */
    cur_pcb->pid = pid;
    cur_pcb->is_shell = is_shell;

    /* Set parent params for current task */
    if(parent_pcb != NULL){
        cur_pcb->parent_pid = parent_pcb->pid;
        cur_pcb->parent_pcb_ptr = parent_pcb;
    }
    else{
        cur_pcb->parent_pid = -1;
        cur_pcb->parent_pcb_ptr = parent_pcb;
    }

    /* Return current pcb address */
    return addr;
}

/* get_pcb_from_pid
 *  DESCRIPTION: gets pcb address from pid
 *  INPUT:  pid - process id
 *  OUTPUT: none
 *  RETURN VALUE: pcb address
 *  SIDE EFFECT: none
 */
pcb_t* get_pcb_from_pid(int32_t pid){
    return (pcb_t*)(KERNEL_END_PCB - EIGHT_KB*(pid+1));
}
