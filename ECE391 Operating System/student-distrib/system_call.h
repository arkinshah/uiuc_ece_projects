#ifndef _SYSTEM_CALL_H
#define _SYSTEM_CALL_H

#include "types.h"
#include "keyboard.h"
#include "terminal.h"
#include "rtc.h"
#include "paging.h"
#include "filesys.h"
#include "x86_desc.h"
#include "pcb.h"
#include "scheduling.h"

/* Executable file magic numbers */
#define MAGIC_NUM_1 0x7F
#define MAGIC_NUM_2 0x45
#define MAGIC_NUM_3 0x4C
#define MAGIC_NUM_4 0x46
/* The total number of executable file magic numbers */
#define MAGIC_NUM_SIZE  4 /* Number of magic numbers */

#define COMMAND_NAME_SZ 10 /* Maximum size of the command name */
#define COMMAND_ARG_SZ  117 /* Maximum size of command arg */

#define PCB_START   0x8000000 // 8MB
#define MAX_NUM_FILES 8 /* Maximum number of files in file descriptor table */
#define KERNAL_END  0x7fffff /* End addresss of kernal */
#define FILE_DESC_SIZE 16 /* Ffile descriptor entry size */
#define PCB_SIZE (8*FILE_DESC_SIZE) /* Size of PCB */
#define FILE_JUMP_TABLE_SIZE 16 /* Size of file function jump table */
#define EIGHTKB 0x2000 /* 8kB in bytes */
#define EIGHTMB 0x800000 /* 8MB in bytes */ 
#define ONETWENTYEIGHTMB 0x8000000 /* 128MB in bytes*/
#define ONETHIRTYTWOMB 0x8400000 /* 132MB in bytes */
#define USER_ESP (USER_PROGRAM_VIR_ADDR + FOURMB - 4) /* User stact pointer */
#define MAX_SHELLS_RUNNING 2 /* Max number of running shells */
#define MAX_BOOT_NUM_SHELLS 3
#define MAX_NUM_PROCESSES 6

/* Variables to keep track of pcb state */
//uint32_t cur_pid;
uint32_t cur_eip;
pcb_t* cur_pcb;

//Declarationf all system calls
extern int32_t context_switch(int32_t eip);
int32_t check_valid_fd(pcb_t* pcb_start);
void parse_command(const uint8_t* command, uint8_t *command_name, uint8_t *command_args);
void set_exception_raised(int32_t val);
int32_t get_available_pid();
void set_esp0_from_pid(int32_t pid);
int32_t get_boot_num_shells();

/* System Execute */
int32_t execute(const uint8_t *command);

/* System Halt */
int32_t halt(uint8_t status);

/* System Read */
int32_t read(int32_t fd, void* buf, int32_t nbytes);

/* System Write */
int32_t write(int32_t fd,const void* buf, int32_t nbytes);

/* System Open */
int32_t open(const uint8_t* filename);

/* System Close */
int32_t close(int32_t fd);

/* Get Arguments */
int32_t getargs(uint8_t* buf, int32_t nbytes);

/* Video Map */
int32_t vidmap(uint8_t** screen_start);

/* Extra Credit Function. Implement with Checkpoint 5 */
int32_t set_handler(int32_t signum, void* handler_address);

/* Signals */
int32_t sigreturn(void);

#endif
