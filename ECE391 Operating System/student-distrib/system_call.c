//TODO: Definition of all sys_calls ass shown in the documentation

#include "system_call.h"
#include "types.h"

//uint32_t bootblk_start; -> start of our bootblock (file_system)

const int32_t magic_nums[MAGIC_NUM_SIZE] = {MAGIC_NUM_1, MAGIC_NUM_2, MAGIC_NUM_3, MAGIC_NUM_4};
//static int num_shells = -1;
static int32_t exception_raised = 0;
static int32_t boot_num_shells = 0;
static int32_t pids[MAX_NUM_PROCESSES] = {-1, -1, -1, -1, -1, -1};

/* File Ops Table For Each of our Drivers */

static file_jump_table rtc_table = {rtc_read, rtc_write, rtc_open, rtc_close};
static file_jump_table dir_table = {dir_read, dir_write, dir_open, dir_close};
static file_jump_table file_table = {file_read, file_write, file_open, file_close};

// uint32_t cur_pid = -1;
/* 
 * execute
 *   DESCRIPTION: Executes a command
 *   INPUTS: command: The command as a string
 *   OUTPUTS: none
 *   RETURN VALUE: Returns -1 on failure, 256 on exeception and 0-255 for success
 *   SIDE EFFECTS: Modifies kernal and user space memory
 */
int32_t execute(const uint8_t* command){

    cli();
    // int32_t curret
    // while(ge)

    /* Return value */
    int32_t ret_val = 0;
    int32_t is_shell = 0;
    int32_t cur_pid = -1;

    /* Parent ESP and Parent EBP */
    int32_t parent_ESP;
    int32_t parent_EBP;
    int32_t ESP;
    // int32_t EBP;
    int32_t is_base_shell = 0;

    /* Check if there is an empty process */
    cur_pid = get_available_pid();
    if(cur_pid == -1){
        //TODO: change this (to max process reached)
        terminal_write(0, "Max processes reached\n", 23);
        return 2;
    }

    /* Fail if command is invalid */
    if(command == NULL) return -1;

    /* Local variables */
    uint8_t buf[MAGIC_NUM_SIZE]; /* Four bytes of Magic Numbers */
    int32_t i = 0;

    /***** PARSE COMMAND *****/
    uint8_t command_name[COMMAND_NAME_SZ];
    uint8_t command_args[COMMAND_ARG_SZ];

    parse_command(command, command_name, command_args);

    if(terminal_arr[get_cur_terminal_running()-1].num_process_this_terminal == 0){is_base_shell = 1;}
    /* Check if the program being executed is shell */
    //TODO: Fixed //
    // if(!strncmp((int8_t*)command_name, "shell", 5) && is_base_shell != 1){

    //     /* Check if the number of shells run is less than maximum number allowed */
    //     //TODO: Figure this out for max_num_shells
    //     // if (num_shells >= MAX_SHELLS_RUNNING){
    //     //     terminal_write(0, "Max shells reached\n", 20);
    //     //     return 2;
    //     // }
    //     // else{
    //         num_shells++;
    //         is_shell = 1;
    //     //}
    // }

    /***** EXECUTION CHECK *****/
    /* Check if command executable file exists */
    dentry_t d;
    if(read_dentry_by_name(command_name, &d) == -1) return -1;

    /* Fail if dentry is a folder or RTC file */
    if(d.filetype != 2) return -1;

    /* Check if file is an executable */
    if(read_data(d.inode, 0, buf, MAGIC_NUM_SIZE) != MAGIC_NUM_SIZE) return -1;
    for(i = 0; i < MAGIC_NUM_SIZE; i++){

        if(buf[i] != magic_nums[i]) return -1;
    }

    /***** PAGING *****/
    add_page_for_process(cur_pid);

    /***** FILE LOADER *****/
    copy_program(d);
    if(read_data(d.inode, 24, buf, 4) != 4) return -1;

    /***** CREATE PCB *****/
    cur_pcb = (pcb_t*)load_pcb((pcb_t*)cur_pcb, cur_pid, is_shell);

    /* copy parsed arguments over to pcb argument buffer */
    strcpy((int8_t *)cur_pcb->arguments, (int8_t *)command_args);

    /* byte shifts to get bytes 24-27 of the executable to get the entry point of the process */
    cur_eip = ((int32_t)buf[3] << 24) | ((int32_t)buf[2] << 16) | ((int32_t)buf[1] << 8) | (int32_t)buf[0];

    /*** Save parent ESP, EBP here ***/
    asm volatile("                  \
                    movl %%ebp, %1 ;\
                    movl %%esp, %0 ;\
                    movl k_ESP, %%ebx;\
                    movl %%ebx, %2"\
    : "=g" (parent_ESP), "=g" (parent_EBP), "=g" (ESP)
    :
    : "cc", "esp", "ebp"
    );

    /**** saving parent_ebp and parent_esp pointers ****/
    cur_pcb->parent_ebp = parent_EBP;
    cur_pcb->parent_esp = parent_ESP;
    //cur_pcb->ebp = parent_EBP;
    if(boot_num_shells == 0 || (boot_num_shells >= MAX_BOOT_NUM_SHELLS)){   
        //cur_pcb->esp = parent_ESP;
    }
    /**** resetting index to start from 0 ****/
    reset_index_dir();

    tss.esp0 = EIGHTMB - cur_pid*EIGHTKB -4;
    tss.ss0 = KERNEL_DS;

    /* Process successfully started */
    pids[cur_pid] = cur_pid;
    terminal_arr[get_cur_terminal_running()-1].active_pid = cur_pid;
    terminal_arr[get_cur_terminal_running()-1].num_process_this_terminal++;

    // /**** BOOTING MULTIPLE TERMINALS ****/
    // if(boot_num_shells < MAX_BOOT_NUM_SHELLS-1){

    //     boot_num_shells++;
    //     //set_cur_terminal(boot_num_shells+1);
    //     set_cur_terminal_running(boot_num_shells+1);
    //     sti();
    //     execute((uint8_t*)"shell");

    // }

    if(is_base_shell == 1 && !strncmp((int8_t*)command_name, "shell", 5)){
        cur_pcb->parent_pcb_ptr = NULL;
        cur_pcb->parent_pid = -1;
        if(boot_num_shells == 0){
            make_terminal_active(get_cur_terminal());
        }else{
            make_terminal_active(get_cur_terminal_running());        
        }
        boot_num_shells++;
    }

    /***** CONTEXT SWITCH *****/
    context_switch(cur_eip); // IMP: We do sti inside context_switch

    /* Return to execute from halt */
    asm volatile("                  \
                    halt_return    :\
                    movl %%ebx, %0 ;"\
    :
    : "g" (ret_val)
    : "cc"
    );

    /* returns value given by program's call to halt if HALT syscall happened */
    if (exception_raised == 1){
        ret_val = 256;
        exception_raised = 0;
    }

    //sti();
    return ret_val;
}

/* 
 * context_switch
 *   DESCRIPTION: switches context of tasks
 *   INPUTS: current_pcb:   current pcb value
 *           processID:     process ID of current process
 *           eip:           register eip to switch instruction procedure
 *           esp:           register esp to switch stack pointer
 *   OUTPUTS: switches tasks
 *   RETURN VALUE: none
 *   SIDE EFFECTS: sets up for privilege change
 */
int32_t context_switch(int32_t eip){

    /* Return Value */
    int32_t ret_val = 0;
    //int32_t parent_ESP;
    //int32_t parent_EBP;

    /* Stack must be the following before IRET
                |   EIP   |     // entry point
                |   CS    |     
                |  EFLAG  |
                |   ESP   |     // stack for privilege level being called
                | USER_DS |
    */

    /* write new process' info to TSS (esp0 & SS) */

    /* Process' PCB location = 8MB - (process# * 8KB) */
    //uint32_t newESP = PCB_START - (processID * EIGHT_KB);
    
    /* Will be put into SS and ESP when performing privilege switch from 3->0 */
    // tss.esp0 = EIGHTMB - processID*EIGHTKB -4;
    // tss.ss0 = KERNEL_DS;

    /* need to save parent process's ESP & EBP 
     * load USER_DS value into %ds, then push in order
     * USER_DS, CURRENT_PROCESS_ESP, EIP, EFLAGS, the ESP of new process
     * raise IF = 1 again
     * Call iret
     * halt_return = halt will return to this label when child process halts
     */

    asm volatile("                       \
                    movw    %0, %%ax    ;\
                    movw    %%ax, %%ds  ;\
                    pushl   %0          ;\
                    pushl   %1          ;\
                    pushfl              ;\
                    popl    %%eax       ;\
                    orl     $0x200, %%eax ;\
                    pushl   %%eax       ;\
                    pushl   %2          ;\
                    pushl   %3          ;\
                    iret                ;"\
                :\
                : "g" (USER_DS), "g" (USER_ESP), "g" (USER_CS), "g" (eip)          \
                : "eax", "memory"                                  \
   );

   return ret_val;
     
}

/* 
 * halt
 *   DESCRIPTION: halts current process
 *   INPUTS: status: the current status of the machine
 *   OUTPUTS: halts current process and goes back to parent process
 *   RETURN VALUE: 0 for success, -1 for failure
 *   SIDE EFFECTS: modifies registers and clears out pcb so that the task switch occurs
 */
int32_t halt(uint8_t status){
    sti();
    while(get_cur_terminal_running() != get_cur_terminal());
    cli();
    //restore parent data
    int i;
    int32_t parent_esp = 0;
    int32_t parent_ebp = 0;
    int32_t cur_pid = cur_pcb->pid;

    if(cur_pid == -1) return -1; /* Should Never Exist */

    /***** Restart Shell *****/
    if(terminal_arr[get_cur_terminal_running()-1].num_process_this_terminal == 1){ //only shell process exists

        for(i = 0; i < MAX_NUM_FILES; i++){
                cur_pcb->fdt[i].flags = 0;
                cur_pcb->fdt[i].file_pos = 0;
        }

        //  if (cur_pcb->is_shell){
        //     num_shells--;
        //     cur_pcb->is_shell = 0;
        // }
        
        terminal_arr[get_cur_terminal_running()-1].num_process_this_terminal = 0;
        boot_num_shells--;
        //TODO: Change this, this is wrong
        //cur_pid--;
        pids[cur_pid] = -1;
        //num_shells = -1;
        cur_pcb = NULL;
        execute((uint8_t *)"shell");
        return 0;
        //restart shell by calling execute
        //cur_esp = (int32_t)cur_pcb + EIGHT_KB;
        // cur_eip = ((int32_t)buf[0] << 24) | ((int32_t)buf[1] << 16) | ((int32_t)buf[2] << 8) | (int32_t)buf[3];
        // context_switch(cur_pcb, cur_pid, cur_esp, cur_eip);
    }

    // if parent exists
    if(cur_pcb->parent_pcb_ptr != NULL){
        //tss.esp0 = EIGHTMB - (cur_pcb->parent_pid * EIGHTKB);
        //int pid = cur_pcb->parent_pid;

        for(i = 0; i < MAX_NUM_FILES; i++){
            // cur_pcb->fdt[i].flags = 0;
            // cur_pcb->fdt[i].file_pos = 0;
            close(i);
        }

        pids[cur_pid] = -1;
        terminal_arr[get_cur_terminal_running()-1].active_pid = cur_pcb->parent_pid;
        terminal_arr[get_cur_terminal_running()-1].num_process_this_terminal--;
        cur_pid = cur_pcb->parent_pid;
        parent_esp = cur_pcb->parent_esp;
        parent_ebp = cur_pcb->parent_ebp;
        
        cur_pcb = cur_pcb->parent_pcb_ptr;
        cur_pcb->pid = cur_pid;
        
        add_page_for_process(cur_pcb->pid); // only if parent exists
        // jump to execute parents 
         // switch status to parent
    }

        /* jump back to execute return */
        tss.esp0 = EIGHTMB - cur_pid*EIGHTKB -4;
        tss.ss0 = KERNEL_DS;

    /*
                    movw    %1, %%ax    ;\
                    movw    %%ax, %%ds  ;\
    */
    
    asm volatile("                       \
                    xorl    %%ebx, %%ebx ;\
                    movb    %0, %%bl    ;\
                    movl    %2, %%esp   ;\
                    movl    %3, %%ebp   ;\
                    jmp halt_return     ;"\
                :                       \
                : "g" (status), "g" (USER_DS) , "g" (parent_esp), "g" (parent_ebp)\
                : "bl", "esp", "ebp"              \
   );
    //context_switch(NULL, cur_pcb->parent_pid, tss.eip);

    return 0;

    // add_page_for_process(cur_pcb->parent_pid); // only if parent exists
    
}
/*
 * check_valid_fd
 *   DESCRIPTION: checks for lowest possible available fd space
 *   INPUTS: beginning to PCB
 *   OUTPUTS: none
 *   RETURN VALUE: index of lowest available fd space
 *   SIDE EFFECTS: none
 */
int32_t check_valid_fd(struct pcb_t* pcb_start){
    int32_t i;
    if(pcb_start == NULL) return -1; 
    for(i=2; i<MAX_NUM_FILES; i++){ // changed from 0 to 2
        if(pcb_start->fdt[i].flags == 0){
            //lowest possible available fd
            return i;
        }
    }
    return -1;
}

/* 
 * open
 *   DESCRIPTION: opens the file for further action
 *   INPUTS: filename: name of the file
 *   OUTPUTS: none
 *   RETURN VALUE: -1 on failure and 0 on success
 *   SIDE EFFECTS: changes file descriptor values
 */
int32_t open(const uint8_t* filename){

    //int i = 5/0;

    //read_dentry_by_name(const uint8_t* fname, dentry_t* dentry)
    //RETURN VALUE: 0 on success and -1 on failure.

    dentry_t dentry;
    int32_t fd;

    //check first if the filename even exists (if not return -1)
    if(filename == NULL || strlen((int8_t*)filename) == 0){return -1;}
    if(read_dentry_by_name(filename, &dentry) == -1){return -1;}

    //check if fd exists or not
    //pcb_t* pcb_start = EIGHTMB - (num_task_running * EIGHTKB);
    fd = check_valid_fd(cur_pcb);
    if(fd < 0){return -1;}
    //if(fd < 2) {return -1};

    //else fill the fd with the stuff (inode etc.)
    //if(fd == 0  || fd == 1){return 0;} //as stdin and stdout are default implemented

    //file_desc_t *cur_pcb->fdt[fd] = &(cur_pcb->fdt[fd]);

    /* check if trying to open an openned file */
    if (cur_pcb->fdt[fd].flags == 1)  return -1;

    uint32_t filetype = dentry.filetype;
    //uint32_t inode_number = dentry.inode;
    if(filetype == 0){
        /* RTC */
        // cur_pcb->fdt[fd].file_jmp_table_ptr->open = &rtc_open;
        // cur_pcb->fdt[fd].file_jmp_table_ptr->close = &rtc_close;
        // cur_pcb->fdt[fd].file_jmp_table_ptr->read = &rtc_read;
        // cur_pcb->fdt[fd].file_jmp_table_ptr->write = &rtc_write;

        cur_pcb->fdt[fd].file_jmp_table_ptr = &rtc_table;

        //do not care about inode number for RTC
        //file_descriptor_index->inode = inode_number;
        cur_pcb->fdt[fd].file_pos = 0; //initially reading from 0
        cur_pcb->fdt[fd].flags = 1; //in use

        //call rtc_open to initialize rtc
        rtc_open(filename);
    }
    else if(filetype == 1){
        /* Directory */
        // cur_pcb->fdt[fd].file_jmp_table_ptr->open = &dir_open;
        // cur_pcb->fdt[fd].file_jmp_table_ptr->close = &dir_close;
        // cur_pcb->fdt[fd].file_jmp_table_ptr->read = &dir_read;
        // cur_pcb->fdt[fd].file_jmp_table_ptr->write = &dir_write;

        cur_pcb->fdt[fd].file_jmp_table_ptr = &dir_table;

        //do not care about inode (is ignored)

        cur_pcb->fdt[fd].file_pos = 0; //initially reading from 0
        cur_pcb->fdt[fd].flags = 1; //in use
    }
    else if(filetype == 2){
        /*Regular File*/
        // cur_pcb->fdt[fd].file_jmp_table_ptr->open = &file_open;
        // cur_pcb->fdt[fd].file_jmp_table_ptr->close = &file_close;
        // cur_pcb->fdt[fd].file_jmp_table_ptr->read = &file_read;
        // cur_pcb->fdt[fd].file_jmp_table_ptr->write = &file_write;

        cur_pcb->fdt[fd].file_jmp_table_ptr = &file_table;

        cur_pcb->fdt[fd].inode = dentry.inode;
        cur_pcb->fdt[fd].file_pos = 0; //initially reading from 0
        cur_pcb->fdt[fd].flags = 1; //in use
    }
    else {return -1;}

    return fd;
}

/* 
 * close
 *   DESCRIPTION: closes the file
 *   INPUTS: fd: file descriptor
 *   OUTPUTS: none
 *   RETURN VALUE: Returns -1 on failure, 0 on success
 *   SIDE EFFECTS: closes file by setting the file descriptor value flag to 0, marked not busy
 */
int32_t close(int32_t fd){
    if(fd == 0 || fd == 1){return -1;} /* user cannot close stdin and stdout */
    if(fd < 0 || fd >= MAX_NUM_FILES){return -1;} /*Invalid fd*/

    //pcb_t* pcb_start = EIGHTMB - (num_task_running * EIGHTKB);

    if(cur_pcb->fdt[fd].flags == 0){return -1;} /*Already closed*/

    cur_pcb->fdt[fd].flags = 0; /*set not in use*/
    cur_pcb->fdt[fd].file_jmp_table_ptr = NULL;
    cur_pcb->fdt[fd].file_pos = 0;
    cur_pcb->fdt[fd].inode = 0;
    return 0;
}

/* 
 * read
 *   DESCRIPTION: reads the file descriptor from the cur pcb as specified by argument
 *   INPUTS:    fd:     file descriptor
 *              buf:    buffer to be read from
 *              nbytes: number of bytes to be read
 *   OUTPUTS: none
 *   RETURN VALUE: Returns -1 on failure, num of bytes read on success
 *   SIDE EFFECTS: modifies file descriptor jump table value so that the read value is stored into the array
 */
int32_t read(int32_t fd, void* buf, int32_t nbytes){
    if(fd < 0 || fd >= MAX_NUM_FILES || fd == 1){return -1;} /*Invalid fd*/
    if(buf == NULL){return -1;}

    //pcb_t* pcb_start = EIGHTMB - (num_task_running * EIGHTKB);
    //file_desc_t *file_descriptor_index = &(cur_pcb->fdt[fd]);

    /* if reading from unopenned file */
    if (cur_pcb->fdt[fd].flags == 0)  return -1;

    int32_t ret_val =  cur_pcb->fdt[fd].file_jmp_table_ptr->read(fd, buf, nbytes);
    return ret_val;
}

/* 
 * write
 *   DESCRIPTION: writes into the file descriptor at appropriate location
 *   INPUTS:    fd:     file descriptor
 *              buf:    buffer to be written into
 *              nbytes: number of bytes to be written
 *   OUTPUTS: none
 *   RETURN VALUE: Returns -1 on failure, num of bytes written on success
 *   SIDE EFFECTS: modifies file descriptor jump table value so that the read value is stored into the array
 */
int32_t write(int32_t fd, const void* buf, int32_t nbytes){
    cli();

    /* Invalid fd */
    if(fd < 0 || fd >= MAX_NUM_FILES || fd == 0){return -1;}
    if(buf == NULL){return -1;}

    //pcb_t* pcb_start = EIGHTMB - (num_task_running * EIGHTKB);
    //file_desc_t *file_descriptor_index = &(cur_pcb->fdt[fd]);

    /* Fail if file is not open at fd */
    if(cur_pcb->fdt[fd].flags == 0) return -1;

    /* Set return value to call specific write function */
    int32_t ret_val = cur_pcb->fdt[fd].file_jmp_table_ptr->write(fd, buf, nbytes);
    sti();
    return ret_val;
}

/* getargs
 *  DESCRIPTION: copies the cur_pcb arguments over to the buffer passed in
 *  INPUT:  buf - buffer to copy to
 *          nbytes - size of the buffer
 *  OUTPUT: none
 *  RETURN VALUE: 0 success, -1 failure
 *  SIDE EFFECT: writes to buffer
 */
int32_t getargs(uint8_t* buf, int32_t nbytes){
    /* check if pcb has arguments and if these arguments fit inside buf */
    // if (strlen((int8_t *)cur_pcb->arguments) == 0 || (strlen((int8_t *)cur_pcb->arguments) > strlen((int8_t *)buf)))
    //     return -1;
    if(buf == NULL){
        return -1;
    }
    if(cur_pcb->arguments[0] == '\0'){
        return -1;
    }
    /* squash user-level exceptions test
    int i = 0;
    int j = 1;
    printf("%d", j / i);
    */
        
    /* copy pcb arguments to user-level buffer */
    strncpy((int8_t *)buf, (int8_t *)cur_pcb->arguments, nbytes);
    return 0;
}

/* vidmap
 *  DESCRIPTION: handles video memory paging for user programs 
 *  INPUT:  screen_start : pointer to the beginning of the virtual memory for video memory
 *  OUTPUT: screen_start gets 136MB as it was arbitrarily chosen as location of vmem
 *  RETURN VALUE: 0 success, -1 failure
 *  SIDE EFFECT: paging for video memory
 */
int32_t vidmap(uint8_t** screen_start){
    cli();
    // sanity check for bad args
    if(screen_start == NULL || (int32_t)screen_start < ONETWENTYEIGHTMB || (int32_t)screen_start >= ONETHIRTYTWOMB) return -1;
    vidmap_paging(get_cur_terminal(), 1);
    *screen_start = (uint8_t*)_136MB;
    sti();
    return 0;
}

/* set handler
 *  DESCRIPTION: none
 *  INPUT:  signum:
 *          handler address: 
 *  OUTPUT: none
 *  RETURN VALUE: 0 success, -1 failure
 *  SIDE EFFECT: always fails, not yet implemented
 */
int32_t set_handler(int32_t signum, void* handler_address){
    return -1;
}

/* sig return
 *  DESCRIPTION: none
 *  INPUT: none 
 *  OUTPUT: none
 *  RETURN VALUE: 0 success, -1 failure
 *  SIDE EFFECT: always fails, not yet implemented
 */
int32_t sigreturn(void){
    return -1;
}

/* parse_command
 *  DESCRIPTION: parses command string for the command name, and arguments(if any)
 *  INPUT: command - command to parse
 *         command_name - buffer to hold command name
 *         command_arg - buffer to hold command arguments
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE EFFECT: populates buffers passed in
 */
void parse_command(const uint8_t* command, uint8_t *command_name, uint8_t *command_args){
    int i = 0;
    int j = 0;

    /* first word is command name */
    while (i < COMMAND_NAME_SZ && command[i] != ' '){

        /* Return if command has to arguments */
        if(command[i] == '\0' || command[i] == '\n'){

            command_name[i] = '\0';
            command_args[0] = '\0';
            return;
        }

        command_name[i] = command[i];
        i++;
    }

    /* null terminate it */
    command_name[i] = '\0';
    i++;

    /* if command is shell, it has no arguments so return */
    // if (strncmp((int8_t *)command_name, "shell", 5) == 0)
    //     return;

    /* remove leading spaces */
    while(command[i] == ' ')
        i++;

    /* the rest is the argument */
    while (j < COMMAND_ARG_SZ && command[i] != ' ' && command[i] != '\0' && command[i] != '\n'){
        command_args[j] = command[i];
        j++;
        i++;
    }

    command_args[j] = '\0';
}


/* set_exception_raised
 *  DESCRIPTION: setter function to change the exception_raised flag
 *  INPUT: val -> flag value we want to change
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE EFFECT: populates buffers passed in
 */
void set_exception_raised(int32_t val){

    /* Set exception to the value passed */
    exception_raised = val;
}

/* get_available_pid
 *  DESCRIPTION: get the first open pid
 *  INPUT: None
 *  OUTPUT: None
 *  RETURN VALUE: -1 n failure, pid on success
 *  SIDE EFFECT: None
 */
int32_t get_available_pid(){

    int32_t i = 0;

    for(i = 0; i < MAX_NUM_PROCESSES; i++){

        if(pids[i] == -1) return i;
    }

    /* Return failure if none of the pids are open */
    return -1;
}

/* set_esp0_from_pid
 *  DESCRIPTION: sets tss.esp0 based on pid value passed
 *  INPUT: pid - process id
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE EFFECT: changes esp0
 */
void set_esp0_from_pid(int32_t pid){

    tss.esp0 = EIGHTMB - pid*EIGHTKB - 4;
}

/* get_boot_num_shells
 *  DESCRIPTION: gets the number for boot shells
 *  INPUT: none
 *  OUTPUT: none
 *  RETURN VALUE: number of boot shells
 *  SIDE EFFECT: none
 */
int32_t get_boot_num_shells(){
    return boot_num_shells;
}
