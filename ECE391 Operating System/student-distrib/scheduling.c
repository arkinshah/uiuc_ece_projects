#include "scheduling.h"

// static int32_t cur_terminal = 1;
// static int32_t cur_terminal_running = 1;

/* make_terminal_active
 *  DESCRIPTION: switches terminals
 *  INPUT: terminal - terminal to make active
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE EFFECT: changes the terminal
 */
void make_terminal_active(int32_t terminal){

    // int32_t screen_x = 0;
    // int32_t screen_y = 0;

    cli();

    int32_t temp_addr = 0;

    //if (terminal != get_cur_terminal()){
        /* Copy active terminal screen to garbage space for current terminal */
        //vidmap_paging(get_cur_terminal(), 1);
        temp_addr = _136MB + (get_cur_terminal() << PAGE_INDEX_SHIFT);
        //memcpy((uint8_t*)temp_addr, (uint8_t*)_136MB, FOURKB);
        memcpy((uint8_t*)(0xB8000 + get_cur_terminal()*FOURKB), (uint8_t*)0xB8000, FOURKB);

        /* Save the position of the cursor */
        // TO DO: CHANGE CURSOR PROBLEM
        terminal_arr[get_cur_terminal() - 1].screen_x = get_screen_x(get_cur_terminal());
        terminal_arr[get_cur_terminal() - 1].screen_y = get_screen_y(get_cur_terminal());

        /* Save the eip of the program */
        //cur_pcb->eip = 

        // temp_addr = temp_addr + (NUM_ROWS*NUM_COLS);
        // memset((uint8_t*)temp_addr, get_screen_x(), INT_SIZE);
        // temp_addr = temp_addr + INT_SIZE;
        // memset((uint8_t*)temp_addr, get_screen_y(), INT_SIZE);

        /* Make the currently active terminal screen point to garbage address */
        //vidmap_paging(get_cur_terminal(), 0);

        set_cur_terminal(terminal);
   // }

    //TODO: Change cur_pcb
    //cur_pcb = get_pcb_from_pid(terminal_arr[cur_terminal-1].active_pid);

    /* Switch to paging for another terminal*/
    //add_page_for_process(terminal_arr[cur_terminal-1].active_pid);
    //vidmap_paging(get_cur_terminal(), 1);
    //tss.esp0 = EIGHTMB - (cur_terminal - 1)*_8KB - 4;
    //tss.ss0 = KERNEL_DS;

    /* Copy new terminal screen to active terminal */
    temp_addr = _136MB + (get_cur_terminal() << PAGE_INDEX_SHIFT);
    /* Get the cursor position */
    
    // screen_x = *((uint8_t*)temp_addr + (NUM_ROWS*NUM_COLS));
    // screen_y = *((uint8_t*)temp_addr + (NUM_ROWS*NUM_COLS) + INT_SIZE);
    
    clear_screen_and_buffer(terminal_arr[get_cur_terminal() - 1].screen_x, terminal_arr[get_cur_terminal() - 1].screen_y);
    //memcpy((uint8_t*)_136MB, (uint8_t*)temp_addr, FOURKB);
    memcpy((uint8_t*)0xB8000, (uint8_t*)(0xB8000 + get_cur_terminal()*FOURKB), FOURKB);

    if(get_cur_terminal_running() != get_cur_terminal()){
        vidmap_paging(get_cur_terminal_running(), 0);
        set_video_mem(VIDMEM + FOURKB*get_cur_terminal_running());
    }else{
        vidmap_paging(get_cur_terminal_running(), 1);
        set_video_mem(VIDMEM);
    }

    //set_video_mem(VIDMEM + FOURKB*(cur_terminal-1));
    //context_switch(cur_pcb->eip);
    sti();
    
}

/* get_next_active_terminal
 *  DESCRIPTION: gets the index for the next terminal
 *  INPUT: none
 *  OUTPUT: none
 *  RETURN VALUE: index to next terminal or -1 on failure
 *  SIDE EFFECT: none
 */
int32_t get_next_active_terminal(){

    if(get_boot_num_shells() <= 1) return -1;

    int32_t i = 0;
    int32_t index = get_cur_terminal_running() % MAX_BOOT_NUM_SHELLS;

    for(i = 0; i < MAX_BOOT_NUM_SHELLS; i++){

        if(get_terminals(index) != -1){

            return index+1;
        }

        index = (index + 1) % MAX_BOOT_NUM_SHELLS;
    }

    return -1;
}


//PIT Interrupt HANDLER //

/* switch_tasks
 *  DESCRIPTION: This is our scheduler. Saves the old ESP/EBP, then switches process paging.
 *               Then sets the tss to the new process. Updates the terminal struct to be the new process.
 *               Finally switch to new process ESP/EBP
 * INPUT: none
 * OUTPUT: none
 * RETURN VALUE: none
 * SIDE EFFECT: switches process for scheduler on PIT interrupts
 */
void switch_tasks(){

    send_eoi(0);
    cli();

    int32_t terminal = get_next_active_terminal();
    int32_t pid = -1;

    if(terminal == -1){
        sti();
        return;
    }

    pid = terminal_arr[terminal - 1].active_pid;
    //terminal_arr[get_cur_terminal_running()-1].screen_x = get_screen_x();
    //terminal_arr[get_cur_terminal_running()-1].screen_y = get_screen_y();

    //TODO: Look at this
    set_cur_terminal_running(terminal);

    int32_t ESP = -1;
    int32_t EBP = -1;

    /* save current EBP/ESP for current process */
    asm volatile("                  \
                    movl %%ebp, %1 ;\
                    movl %%esp, %0;"\
    : "=g" (ESP), "=g" (EBP)\
    :\
    : "cc", "esp", "ebp"\
    );

    cur_pcb->esp = ESP;
    cur_pcb->ebp = EBP;

    /*** Switch process paging ***/
    add_page_for_process(pid);

    /*** Restore tss ***/
    tss.esp0 = EIGHTMB - pid*EIGHTKB - 4;
    tss.ss0 = KERNEL_DS;

    /*** Update video paging ***/
    if(get_cur_terminal_running() == get_cur_terminal()){
        set_video_mem(VIDMEM);
        vidmap_paging(get_cur_terminal(), 1);
        //set_cursor(terminal_arr[get_cur_terminal_running()-1].screen_x, terminal_arr[get_cur_terminal_running()-1].screen_y);
    }else{
        set_video_mem(VIDMEM + FOURKB*get_cur_terminal_running());
        vidmap_paging(get_cur_terminal_running(), 0);
    }

    /*** Switch cur pcb ***/
    cur_pcb = get_pcb_from_pid(pid);

    ESP = cur_pcb->esp;
    EBP = cur_pcb->ebp;

    asm volatile("                  \
                    movl %1, %%ebp;\
                    movl %0, %%esp;\
                    sti;\
                    leave;\
                    ret;"\
    :\
    : "g" (ESP), "g" (EBP)\
    : "cc", "esp", "ebp"\
    );

    return;
}


