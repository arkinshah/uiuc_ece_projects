#include "tests.h"
#include "x86_desc.h"
#include "lib.h"
#include "filesys.h"
#include "terminal.h"
#include "rtc.h"

/* format these macros as you see fit */
#define TEST_HEADER 	\
	printf("[TEST %s] Running %s at %s:%d\n", __FUNCTION__, __FUNCTION__, __FILE__, __LINE__)
#define TEST_OUTPUT(name, result)	\
	printf("[TEST %s] Result = %s\n", name, (result) ? "PASS" : "FAIL");

static inline void assertion_failure(){
	/* Use exception #15 for assertions, otherwise
	   reserved by Intel */
	asm volatile("int $15");
}

// int count = 0;
// /* Checkpoint 1 tests */

// /* IDT Test - Example
//  * 
//  * Asserts that first 10 IDT entries are not NULL
//  * Inputs: None
//  * Outputs: PASS/FAIL
//  * Side Effects: None
//  * Coverage: Load IDT, IDT definition
//  * Files: x86_desc.h/S
//  */
// int idt_test(){
// 	TEST_HEADER;

// 	int i;
// 	int result = PASS;
// 	for (i = 0; i < ID_VAL; ++i){
// 		if ((idt[i].offset_15_00 == NULL) && 
// 			(idt[i].offset_31_16 == NULL)){
// 			assertion_failure();
// 			result = FAIL;
// 		}
// 	}

// 	return result;
// }

// // add more tests here

// /* test div by zero exception */

// /* ZERO EXCEPTION TEST
//  * 
//  * throws exception if a divide by 0 is detected
//  * Inputs: None
//  * Outputs: exception
//  * Side Effects: None
//  */
// void div_zero(){
// 	int i = 0;
// 	int a = ID_VAL;
// 	int c = a / i;

// 	printf("C: %d", c);
// 	/* shouldn't make it here */
// 	printf("Did not work\n");
// }

// /* Page Fault Test */

// /* Page Fault TEST
//  * 
//  * Checks if an unpresent page is accessed
//  * Inputs: None
//  * Outputs: PASS/FAIL
//  * Side Effects: Throws error
//  */
// void page_fault_test(){
// 	int *a = 0;
// 	int b = *a;

// 	printf("B: %d", b);
// 	/* Should not make it here */
// 	printf("Did not work\n");
// }

// /* Checkpoint 2 tests */


// /* Read Data Function Test
//  * 
//  * Checks if the correct data is read from the file
//  * Inputs: None
//  * Outputs: Data written onto buffer
//  * Side Effects: None
//  * Files: filesys.h/c
//  */
// void test_read_data(){
	
// 	dentry_t d;
// 	uint8_t buf[BUF1];
// 	uint8_t buf2[BUF2];
// 	int i;
	
// 	read_dentry_by_name((const uint8_t *)"frame0.txt", &d);
// 	// puts((int8_t *)d.filename);
// 	for(i=0; i<NAME_SIZE; i++){
// 		buf[i] = d.filename[i];
// 	}
// 	buf[i] = '\0';
// 	puts((int8_t *) buf);
// 	printf("\n The inode number is %d \n", d.inode);
	
// 	int32_t value = read_data(d.inode, 0, buf2, DATA_BLK_SIZE);
// 	printf("Bytes Read: %d \n", value);
// 	// puts((int8_t *)buf2);
// 	for(i=0; i<value; i++){
// 		putc(buf2[i]);
// 	}
	
// 	// for binary files (fish, hello) use putc else can use puts
// 	// for(i=0; i<value; i++){
// 	// 	putc(buf[i]);
// 	// }
// 	// printf("\n");
	
// 	// return;
// 	// int32_t value_long = read_dentry_by_name("verylargetextwithverylongname.tx", &d);
// 	// // printf("Value Lonf File: %d \n", value_long);
// 	// // puts((uint8_t *)d.filename);
// 	// // printf("%s\n", d.filename);
// 	// for(i=0; i<NAME_SIZE; i++){
// 	// 	buf[i] = d.filename[i];
// 	// }
// 	// buf[i] = '\0';
// 	// printf("%s\n", buf);
// 	// printf("\nThe inode number is %d\n", d.inode);
	
// 	// int32_t count = read_data(d.inode, 4100, buf, 10000);
// 	// puts((int8_t *)buf);
// 	// printf("\n%d\n", count);
// }

// /* Read Data by index Function Test
//  * 
//  * Checks if the correct data is read from the file after being indexed
//  * Inputs: None
//  * Outputs: Data written onto buffer
//  * Side Effects: None
//  * Files: filesys.h/c
//  */
// void test_read_data_by_index(){
// 	dentry_t d;
// 	uint8_t buf[BUF3];
	
// 	//10 is frame0.txt
// 	int32_t ret_val = read_dentry_by_index(10, &d);
// 	printf("The return value fir dentry_by_index: %d \n", ret_val);
// 	//puts((int8_t *)d.filename);
// 	int i;
// 	for(i=0; i<NAME_SIZE; i++){
// 		buf[i] = d.filename[i];
// 	}
// 	buf[i] = '\0';
// 	printf("%s\n", buf);
// 	printf("\nThe inode number is %d\n", d.inode);
	
// 	int32_t value = read_data(d.inode, 0, buf, DATA_BLK_SIZE);
// 	printf("Bytes Read: %d \n", value);
// 	//puts((uint8_t *)buf);
// 	for(i=0; i<value; i++){
// 		putc(buf[i]);
// 	}
// }

// /* Read Directory Function Test
//  * 
//  * Checks if the correct directory is read
//  * Inputs: None
//  * Outputs: Directory written onto screen
//  * Side Effects: None
//  * Files: filesys.h/c
//  */
// void test_dir_read(){
// 	uint32_t num_directories = *((uint32_t *)bootblk_start);
// 	int i;
// 	int ret_val;
// 	uint8_t buf[BUF2];
// 	for(i=0; i<num_directories+ID_VAL; i++){
// 		ret_val = dir_read(buf);
// 		if(!ret_val){continue;}
// 		printf("Files: %s \n", buf);
// 	}
// }

// /* Read File Function Test
//  * 
//  * Checks if the correct file is read
//  * Inputs: None
//  * Outputs: File name written onto buffer and number of bytes copied printed onto screen
//  * Side Effects: None
//  * Files: filesys.h/c
//  */
// void test_file_read(){
// 	uint8_t buf[BUF3];
// 	uint32_t nbytes = FREAD_SIZE;
// 	uint32_t offset = 0;
// 	int i;
// 	int32_t bytes_read = file_read(0, buf, nbytes, (uint8_t *)"frame0.txt", offset);
// 	//puts((int8_t *)buf);
// 	printf("\n Bytes Read: %d \n", bytes_read);
// 	for(i=0; i<bytes_read; i++){
// 		putc(buf[i]);
// 	}
// }

// /* Checkpoint 2 tests */

// /* terminal Write Function Test
//  * 
//  * Checks if the correct input is written onto terminal
//  * Inputs: None
//  * Outputs: Specified input written onto screen
//  * Side Effects: None
//  * Files: keyboard.h/c
//  */
// void test_terminal_write(){
// 	terminal_write(0, "Testing Terminal_write()\n", 26);
// 	terminal_write(0, "hello\n", 7); // nbytes size = sizeof(string)
// 	terminal_write(0, "Bananas\n", 4); // nbytes size < sizeof(string)
// 	terminal_write(0, "123456789\n", 20); // nbytes size > sizeof(string)
// 	terminal_write(0, "Biggest freakings string in the world that is probably over 128 characters. Phis crap better freaking work because ain't nobody got time to actually type this\n", 160); // nbytes >> 128
// 	terminal_write(0, 0, 2); // should not output, buffer is NULL
// 	terminal_write(0, "Terminal_write() test done\n", 28);
// 	terminal_write(0, "\n", 1);
// 	terminal_write(0, "\n", 1);

// }

// /* terminal Read Function Test
//  * 
//  * Checks if the correct input is read from user
//  * Inputs: None
//  * Outputs: Specified input written onto screen
//  * Side Effects: None
//  * Files: keyboard.h/c
//  */

// /* to test scrolling, press alt+l , probably best to test keyboard handler without tests for more percise edge cases */
// void test_terminal_read(){
// 	terminal_write (0, "Testing terminal_read now\n", 27);

// 	uint8_t buffer1[6], buffer2[10], buffer3[150];

// 	terminal_write(0, "Type something, outputting buffer_size - 2 = 4: ", 50);
// 	terminal_read(0, buffer1, 4);
// 	terminal_write(0, "You wrote: ", 13); 
// 	terminal_write(0, buffer1, 6);	// display what user typed (only 6 chars)
// 	terminal_write(0, "\n", 1);

// 	terminal_write(0, "Type anything, will output 10 characters = buffer size: ", 43);
// 	terminal_read(0, buffer2, 10);
// 	terminal_write(0, "You wrote: ", 13);
// 	terminal_write(0, buffer2, 10);	// write only nbytes characters
// 	terminal_write(0, "\n", 1);

// 	terminal_write(0, "Type anything again, will output 128 characters since read only reads 127 + newline: ", 87);
// 	terminal_read(0, buffer3, 150);	// will only read 127 + newline character
// 	terminal_write(0, "You wrote: ", 13);
// 	terminal_write(0, buffer3, 150);
// 	terminal_write(0, "\n", 1);

// 	terminal_write(0, "Terminal_read Test done\n", 26);

// }

// /* RTC open Function Test
//  * 
//  * Checks if RTC is opened correctly
//  * Inputs: None
//  * Outputs: RTC opens
//  * Side Effects: None
//  * Files: rtc.h/c
//  */
// void rtc_test_open(){
// 	const uint8_t filename = "shell";
// 	rtc_open(filename);
// }

// /* RTC read Function Test
//  * 
//  * Checks if RTC is read correctly
//  * Inputs: None
//  * Outputs: RTC input is read
//  * Side Effects: Changes rate
//  * Files: rtc.h/c
//  */
// void rtc_test_read(){
// 	rtc_open();
// 	printf("Read Called \n");
// 	rtc_read();
// 	printf("Read Returned \n");

// 	int i;
// 	for(i = 0; i<TESTDONE; i++){
// 		rtc_read();
// 		printf("RTC interrupted occured %d times. \n", i);
// 	}
// }

// /* RTC r/w Function Test
//  * 
//  * Checks if RTC is read/written correctly
//  * Inputs: Rate to change to
//  * Outputs: RTC rate is changed
//  * Side Effects: Changes rate
//  * Files: rtc.h/c
//  */
// void rtc_test_write_and_read(uint32_t rate){
// 	rtc_open(); //rate:2
// 	int i;
// 	for(i=0;i<ID_VAL;i++){
// 		rtc_read();
// 		printf("RTC interrupt occur %d times and 2hz frequency. \n", i);
// 	}
// 	rtc_write(rate);
// 	for(i=0;i<RTCWRITERATE;i++){
// 		rtc_read();
// 		printf("RTC interrupt occured %d times at %d frequency. \n", i, rate);
// 	}
// }

// /* RTC write Function Test
//  * 
//  * Checks if RTC is written correctly
//  * Inputs: Rate
//  * Outputs: RTC changes rate
//  * Side Effects: Changes rate
//  * Files: rtc.h/c
//  */

// void rtc_test_write(uint32_t rate){
// 	int rate_ = rtc_write(rate);
// 	printf("Rate: %d", rate_);
// }
// /* Checkpoint 3 tests */
// /* Checkpoint 4 tests */
// /* Checkpoint 5 tests */


// /* Test suite entry point */

// /* Launch all tests
//  * 
//  * Inputs: None
//  * Outputs: Depends on uncommented test function
//  * Side Effects: N/A
//  * Files: subjective
//  */

// void launch_tests(){
// 	//TEST_OUTPUT("idt_test", idt_test());
// 	// launch your tests here
// 	// div_zero();
// 	// page_fault_test();
	
// 	/** cp2 **/

// 	//test_read_data();
// 	//test_read_data_by_index();
// 	//test_dir_read();
// 	//test_file_read();

// 	//test_terminal_write();
// 	//test_terminal_read();
// 	rtc_test_open();
// 	//rtc_test_read();
// 	//rtc_test_write_and_read(RTCRWTEST);
// 	//rtc_test_write(RTCWRITETEST);
// }
