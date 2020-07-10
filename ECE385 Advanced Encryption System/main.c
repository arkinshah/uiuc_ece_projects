/************************************************************************
Lab 9 Nios Software

Dong Kai Wang, Fall 2017
Christine Chen, Fall 2013

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "aes.h"

// Pointer to base address of AES module, make sure it matches Qsys
// Execution mode: 0 for testing, 1 for benchmarking
volatile unsigned int * AES_PTR = (unsigned int *) 0x00000000;

int run_mode = 0;

/** charToHex
 *  Convert a single character to the 4-bit value it represents.
 *  
 *  Input: a character c (e.g. 'A')
 *  Output: converted 4-bit value (e.g. 0xA)
 */
char charToHex(char c)
{
	char hex = c;

	if (hex >= '0' && hex <= '9')
		hex -= '0';
	else if (hex >= 'A' && hex <= 'F')
	{
		hex -= 'A';
		hex += 10;
	}
	else if (hex >= 'a' && hex <= 'f')
	{
		hex -= 'a';
		hex += 10;
	}
	return hex;
}

/** charsToHex
 *  Convert two characters to byte value it represents.
 *  Inputs must be 0-9, A-F, or a-f.
 *  
 *  Input: two characters c1 and c2 (e.g. 'A' and '7')
 *  Output: converted byte value (e.g. 0xA7)
 */
char charsToHex(char c1, char c2)
{
	char hex1 = charToHex(c1);
	char hex2 = charToHex(c2);
	return (hex1 << 4) + hex2;
}

/** encrypt
 *  Perform AES encryption in software.
 *
 *  Input: msg_ascii - Pointer to 32x 8-bit char array that contains the input message in ASCII format
 *         key_ascii - Pointer to 32x 8-bit char array that contains the input key in ASCII format
 *  Output:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *               key - Pointer to 4x 32-bit int array that contains the input key
 */
/* WEEK 1:
 * - brianjz2
 * Need to implement: Basic encryption and control loop
 * Key Expansion, AddRoundKey, SubBytes, ShiftRows, MixColumns
 */
//Takes the cipher key and performs to generate a series of round keys
void keyexpansion(unsigned char * Key, unsigned char * Keyhole){

	//implement function and add inputs and outputs
	int byte = 16;
	int Comr = 1; //check this!!
	unsigned char word[4];


	for (int i = 0; i < 16; i++){
		Keyhole[i] = Key[i]; //original 16 bytes
	}

	while(byte < 176){
		for (int b = 0; b < 4; b++){
			word[b] = Keyhole[b + byte - 4]; //fetch the word
		}
		//perform rotate word, subword with Rcon
		if (byte%16 == 0){
			//word = (word >> 8) | ((word & 0xFF) << 24); //check this!
			unsigned char wordswap;
			wordswap = word[0];
			word[0] = word[1];
			word[1] = word[2];
			word[2] = word[3];
			word[3] = wordswap;
		//subword
			printf("\n");
			printf("After wordswap");
			printf(" %x", word[0]);
			printf(" %x", word[1]);
			printf(" %x", word[2]);
			printf(" %x", word[3]);
			printf("\n");
			printf("Our Rcon");
			printf(" %x", Rcon[Comr]);
			for (int a = 0; a < 4; a++){
				word[a] = aes_sbox[word[a]];
				printf("\n");
				printf("After sbox");
				printf(" %x", word[0]);
				printf(" %x", word[1]);
				printf(" %x", word[2]);
				printf(" %x", word[3]);
				printf("\n");
				word[a] = word[a] ^ (Rcon[Comr] >> ((3 - a) * 8));
				printf("\n");
				printf("After Rcon XOR");
				printf(" %x", word[0]);
				printf(" %x", word[1]);
				printf(" %x", word[2]);
				printf(" %x", word[3]);
				printf("\n");
			}
		Comr++;
		}
		//XOR word with Keyhole[byte-16]
		printf("XORING WORD");
		for (int x = 0; x < 4; x++){

		Keyhole[byte] = Keyhole[byte-16] ^ word[x];

		printf(" %x", Keyhole[byte]);
		byte++; //repeat until byte reaches 176
		}
		printf("\n");

}
	printf("\n Expanded Key Now (WITHIN KEY EXPANSION FUNCTION): \n");
								for(int k = 0; k < 176; k++){
									printf(" %x ", Keyhole[k]);
									if(k%16==0) printf("\n");
								}
			printf("\n");

}



void addroundkey(unsigned char * msg, unsigned char * key ){ //32 * 8 bits
	for (int i = 0; i< 16; i++){
		msg[i] ^= key[i];
	}
}

void subbytes(unsigned char * msg){
	for (int i = 0; i< 16; i++){
		msg[i] = aes_sbox[msg[i]];
	}
}

void inversesubbytes(unsigned char* msg){
	for (int i = 0; i<16; i++){
		msg[i] = aes_invsbox[msg[i]];
	}
}

void shiftrows(unsigned char * msg){
	//implement function and add inputs and outputs    msg_ascii is 33 times
	unsigned char test[16];

	test[0] = msg[0];
	test[1] = msg[5];
	test[2] = msg[10];
	test[3] = msg[15];

	test[4] = msg[4];
	test[5] = msg[9];
	test[6] = msg[14];
	test[7] = msg[3];

	test[8] = msg[8];
	test[9] = msg[13];
	test[10] = msg[2];
	test[11] = msg[7];

	test[12] = msg[12];
	test[13] = msg[1];
	test[14] = msg[6];
	test[15] = msg[11];

	//you sure this is not 33????

	for (int i = 0; i < 16; i++){
		msg[i] = test[i];
	}
}

void inverseshiftrows (unsigned char * msg){
	//implement function and add inputs and outputs    msg_ascii is 33 times
		unsigned char test[16];

		test[0] = msg[0];
		test[1] = msg[13];
		test[2] = msg[10];
		test[3] = msg[7];

		test[4] = msg[4];
		test[5] = msg[1];
		test[6] = msg[14];
		test[7] = msg[11];

		test[8] = msg[8];
		test[9] = msg[5];
		test[10] = msg[2];
		test[11] = msg[15];

		test[12] = msg[12];
		test[13] = msg[9];
		test[14] = msg[6];
		test[15] = msg[3];

		for (int i = 0; i < 16; i++){
			msg[i] = test[i];
		}

}

void mixcolumns(unsigned char * msg){

unsigned char var[16];

	 var[0] = (unsigned char)(gf_mul[msg[0]][0] ^ gf_mul[msg[1]][1] ^ msg[2] ^ msg[3]);
	 var[1] = (unsigned char)(msg[0] ^ gf_mul[msg[1]][0] ^ gf_mul[msg[2]][1] ^ msg[3]);
	 var[2] = (unsigned char)(msg[0] ^ msg[1] ^ gf_mul[msg[2]][0] ^ gf_mul[msg[3]][1]);
	 var[3] = (unsigned char)(gf_mul[msg[0]][1] ^ msg[1] ^ msg[2] ^ gf_mul[msg[3]][0]);

	 var[4] = (unsigned char)(gf_mul[msg[4]][0] ^ gf_mul[msg[5]][1] ^ msg[6] ^ msg[7]);
	 var[5] = (unsigned char)(msg[4] ^ gf_mul[msg[5]][0] ^ gf_mul[msg[6]][1] ^ msg[7]);
	 var[6] = (unsigned char)(msg[4] ^ msg[5] ^ gf_mul[msg[6]][0] ^ gf_mul[msg[7]][1]);
	 var[7] = (unsigned char)(gf_mul[msg[4]][1] ^ msg[5] ^ msg[6] ^ gf_mul[msg[7]][0]);

	 var[8] = (unsigned char)(gf_mul[msg[8]][0] ^ gf_mul[msg[9]][1] ^ msg[10] ^ msg[11]);
	 var[9] = (unsigned char)(msg[8] ^ gf_mul[msg[9]][0] ^ gf_mul[msg[10]][1] ^ msg[11]);
	 var[10] = (unsigned char)(msg[8] ^ msg[9] ^ gf_mul[msg[10]][0] ^ gf_mul[msg[11]][1]);
	 var[11] = (unsigned char)(gf_mul[msg[8]][1] ^ msg[9] ^ msg[10] ^ gf_mul[msg[11]][0]);

	 var[12] = (unsigned char)(gf_mul[msg[12]][0] ^ gf_mul[msg[13]][1] ^ msg[14] ^ msg[15]);
	 var[13] = (unsigned char)(msg[12] ^ gf_mul[msg[13]][0] ^ gf_mul[msg[14]][1] ^ msg[15]);
	 var[14] = (unsigned char)(msg[12] ^ msg[13] ^ gf_mul[msg[14]][0] ^ gf_mul[msg[15]][1]);
	 var[15] = (unsigned char)(gf_mul[msg[12]][1] ^ msg[13] ^ msg[14] ^ gf_mul[msg[15]][0]);

for(int a = 0; a < 16; a++){
	msg[a] = var[a];
}

}

void inversemixcolumns(unsigned char * msg){


		unsigned char var[16];

		 var[0] = (unsigned char)(gf_mul[msg[0]][5] ^ gf_mul[msg[1]][3] ^ msg[2][4] ^ msg[3][2]);
		 var[1] = (unsigned char)(msg[0][2] ^ gf_mul[msg[1]][5] ^ gf_mul[msg[2]][3] ^ msg[3][4]);
		 var[2] = (unsigned char)(msg[0][4] ^ msg[1][2] ^ gf_mul[msg[2]][5] ^ gf_mul[msg[3]][3]);
		 var[3] = (unsigned char)(gf_mul[msg[0]][3] ^ msg[1][4] ^ msg[2][2] ^ gf_mul[msg[3]][5]);

		 var[4] = (unsigned char)(gf_mul[msg[4]][5] ^ gf_mul[msg[5]][3] ^ msg[6][4] ^ msg[7][2]);
		 var[5] = (unsigned char)(msg[4][2] ^ gf_mul[msg[5]][5] ^ gf_mul[msg[6]][3] ^ msg[7][4]);
		 var[6] = (unsigned char)(msg[4][4] ^ msg[5][2] ^ gf_mul[msg[6]][5] ^ gf_mul[msg[7]][3]);
		 var[7] = (unsigned char)(gf_mul[msg[4]][3] ^ msg[5][4] ^ msg[6][2] ^ gf_mul[msg[7]][5]);

		 var[8] = (unsigned char)(gf_mul[msg[8]][5] ^ gf_mul[msg[9]][3] ^ msg[10][4] ^ msg[11][2]);
		 var[9] = (unsigned char)(msg[8][2] ^ gf_mul[msg[9]][5] ^ gf_mul[msg[10]][3] ^ msg[11][4]);
		 var[10] = (unsigned char)(msg[8][4] ^ msg[9][2] ^ gf_mul[msg[10]][5] ^ gf_mul[msg[11]][3]);
		 var[11] = (unsigned char)(gf_mul[msg[8]][3] ^ msg[9][4] ^ msg[10][2] ^ gf_mul[msg[11]][5]);

		 var[12] = (unsigned char)(gf_mul[msg[12]][5] ^ gf_mul[msg[13]][3] ^ msg[14][4] ^ msg[15][2]);
		 var[13] = (unsigned char)(msg[12][2] ^ gf_mul[msg[13]][5] ^ gf_mul[msg[14]][3] ^ msg[15][4]);
		 var[14] = (unsigned char)(msg[12][4] ^ msg[13][2] ^ gf_mul[msg[14]][5] ^ gf_mul[msg[15]][3]);
		 var[15] = (unsigned char)(gf_mul[msg[12]][3] ^ msg[13][4] ^ msg[14][2] ^ gf_mul[msg[15]][5]);

	for(int a = 0; a < 16; a++){
		msg[a] = var[a];
	}


}


void encrypt(unsigned char * msg_ascii, unsigned char * key_ascii, unsigned int * msg_enc, unsigned int * key)
{
	//Do we need to add null space again after the encypt?
	//What is a 4x 32 output?? What exactly is it pointing to?
	//in that case msg_ascii will hold our unencrypted word
	//Because aes can only process 128 bits at a time, we are scanning 256 bits.
	unsigned char toEncrypt[16];
	unsigned char HexKey[16];
	unsigned char KeyHole[176]; //full KeyExpansion

	/////////////////// COPYING ORIGINAL MESSAGE //////////////////////////////

	printf("\n Making a copy of original message now, also making chars to hex: \n");
	for (int a = 0; a < 32 ; a = a+2){
		toEncrypt[a/2] = charsToHex(msg_ascii[a],msg_ascii[a+1]);
	}

//	unsigned char tempx;
//
//	for(int i=0; i<4; ++i) {
//	      for(int j=i+1; j<4; ++j){
//	    	  tempx = toEncrypt[4*i + j];
//	    	  toEncrypt[4*i + j] = toEncrypt[4*j + i];
//	    	  toEncrypt[4*j + i] = tempx;
//	      }
//	   }

	printf("\n Ready to process this data: \n");
	for(int k = 0; k < 16; k++){
				if(k%4==0) printf("\n");
				printf(" %x ", toEncrypt[k]);
			}
	printf("\n");

	////////////////////// COPYING ORIGINAL KEY ///////////////////////////

	printf("\n Making a copy of original key now, also making chars to hex: \n");
	for (int b = 0; b < 32; b=  b+2){
		HexKey[b/2] = charsToHex(key_ascii[b], key_ascii[b+1]);
	}

//	for(int i=0; i<4; ++i) {
//		      for(int j=i+1; j<4; ++j){
//		    	  tempx = HexKey[4*i + j];
//		    	  HexKey[4*i + j] = HexKey[4*j + i];
//		    	  HexKey[4*j + i] = tempx;
//		      }
//		   }


	for(int k = 0; k < 16; k++){
					if(k==0) continue;
					if(k%4==0) printf("\n");
					printf(" %x ", HexKey[k]);
				}
		printf("\n");

	for(int m = 0; m < 4; m++) {
		//msg_enc[m] = 0;
		key[m] = 0;
	}


	key[0] = ((key[0] | HexKey[0]) << 24) + ((key[0] | HexKey[1]) << 16) + ((key[0] | HexKey[2]) << 8) + (key[0] | HexKey[3]); //CHECK!!
	key[1] = ((key[1] | HexKey[4]) << 24) + ((key[1] | HexKey[5]) << 16) + ((key[1] | HexKey[6]) << 8) + (key[1] | HexKey[7]);
	key[2] = ((key[2] | HexKey[8]) << 24) + ((key[2] | HexKey[9]) << 16) + ((key[2] | HexKey[10]) << 8) + (key[2] | HexKey[11]);
	key[3] = ((key[3] | HexKey[12]) << 24) + ((key[3] | HexKey[13]) << 16) + ((key[3] | HexKey[14]) << 8) + (key[3] | HexKey[15]);



	//printf("\n Ready to process this key: %s \n", HexKey);

	//{leave state as an array}, documentation states "state" is four
	int rounds = 9;

	//////////////////// KEY EXPANSION /////////////////////////////

	printf("\n KeyExpansion now: \n");
	keyexpansion(HexKey, KeyHole);
	printf("\n Expanded Key Now: \n");
					for(int k = 0; k < 176; k++){
						printf(" %x ", KeyHole[k]);
						if(k%16==0) printf("\n");
					}
				printf("\n");

	////////////////////// ADD ROUND KEY ///////////////////////////

	addroundkey(toEncrypt, HexKey); //check if it is KeyHole or HexKey
	printf("\n After Added Round Key, state is now: \n");
		for(int k = 0; k < 16; k++){
				printf(" %x ", toEncrypt[k]);
				if(k%3==0) printf("\n");
			}
	printf("\n");

	////////////////////// ALL 10 ROUNDS ///////////////////////////

	printf("\n Beginning rounds now . . . \n");
	for (int i = 0; i < rounds; i++){
	subbytes(toEncrypt);
	shiftrows(toEncrypt);
	mixcolumns(toEncrypt); //subtraction is the same as addition mod 2
	addroundkey(toEncrypt, KeyHole + (16 * (i+1)));
	printf("\n At end of round %d , the message looks like this: \n", i);
		for(int k = 0; k < 16; k++){
			printf(" %x ", toEncrypt[k]);
			if(k%3==0) printf("\n");
		}
	printf("\n");
	}

	///////////////////// LAST ROUND ////////////////////////////

		printf("\n Commencing final round: \n");

		//////////////////// SUB BYTES LAST TIME /////////////////////////////

		subbytes(toEncrypt);
		printf("\n After subtitution one last time, the message looks like this: \n");
				for(int k = 0; k < 16; k++){
					printf(" %x ", toEncrypt[k]);
					if(k%3==0) printf("\n");
				}
			printf("\n");

		////////////////////// SHIFT ROWS LAST TIME ///////////////////////////

		shiftrows(toEncrypt);
		printf("\n After shift rows one last time, the message looks like this: \n");
						for(int k = 0; k < 16; k++){
							printf(" %x ", toEncrypt[k]);
							if(k%3==0) printf("\n");
						}
					printf("\n");

		////////////////////// ROUND KEY LAST TIME, THIS IS THE FINAL ENCYPTED TEXT ///////////////////////////

		addroundkey(toEncrypt, KeyHole + 160);
		printf("\n After add round key one last time, the message looks like this: \n");
						for(int k = 0; k < 16; k++){
							printf(" %x ", toEncrypt[k]);
							if(k%3==0) printf("\n");
						}
		printf("\n");


	//loop for charsToHex and charToHEX
		for(int m = 0; m < 4; m++) {
			msg_enc[m] = 0;
			//key[m] = 0;
		}

	msg_enc[0] = ((msg_enc[0] | toEncrypt[0]) << 24) + ((msg_enc[0] | toEncrypt[1]) << 16) + ((msg_enc[0] | toEncrypt[2]) << 8) + (msg_enc[0] | toEncrypt[3]); //CHECK!!
	msg_enc[1] = ((msg_enc[1] | toEncrypt[4]) << 24) + ((msg_enc[1] | toEncrypt[5]) << 16) + ((msg_enc[1] | toEncrypt[6]) << 8) + (msg_enc[1] | toEncrypt[7]);
	msg_enc[2] = ((msg_enc[2] | toEncrypt[8]) << 24) + ((msg_enc[2] | toEncrypt[9]) << 16) + ((msg_enc[2] | toEncrypt[10]) << 8) + (msg_enc[2] | toEncrypt[11]);
	msg_enc[3] = ((msg_enc[3] | toEncrypt[12]) << 24) + ((msg_enc[3] | toEncrypt[13]) << 16) + ((msg_enc[3] | toEncrypt[14]) << 8) + (msg_enc[3] | toEncrypt[15]);


}





/** decrypt
 *  Perform AES decryption in hardware.
 *
 *  Input:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *              key - Pointer to 4x 32-bit int array that contains the input key
 *  Output: msg_dec - Pointer to 4x 32-bit int array that contains the decrypted message
 */
void decrypt(unsigned int * msg_enc, unsigned int * msg_dec, unsigned int * key)
{
	unsigned char toDecrypt[16];

	for (int i = 0; i< 16; i++){
		toDecrypt[i] = msg_enc[i];
	}

	// Implement this function
	addroundkey();
	for (int i = 0; i< 9; i++){

		inverseshiftrows(toDecrypt);
		inversesubbytes(toDecrypt);
		addroundkey(toDecrypt, key + (16 * (i+1)));
		inversemixcolumns(toDecrypt);

	}

	inverseshiftrows(toDecrypt);
	inversesubbytes(toDecrypt);
	addroundkey(toDecrypt, key + 160);

	for (int j = 0; j < 16; j++){
		msg_dec[j] = toDecrypt[j];
	}



}

/** main
 *  Allows the user to enter the message, key, and select execution mode
 *
 */



int main()
{
	// Input Message and Key as 32x 8-bit ASCII Characters ([33] is for NULL terminator)
	unsigned char msg_ascii[33];
	unsigned char key_ascii[33];
	// Key, Encrypted Message, and Decrypted Message in 4x 32-bit Format to facilitate Read/Write to Hardware
	unsigned int key[4];
	unsigned int msg_enc[4];
	unsigned int msg_dec[4];

	printf("Select execution mode: 0 for testing, 1 for benchmarking: ");
	scanf("%d", &run_mode);

	if (run_mode == 0) {
		// Continuously Perform Encryption and Decryption
		while (1) {
			int i = 0;
			printf("\nEnter Message:\n");
			scanf("%s", msg_ascii);
			printf("\n");
			printf("\nEnter Key:\n");
			scanf("%s", key_ascii);
			printf("\n");
			encrypt(msg_ascii, key_ascii, msg_enc, key);
			printf("\nEncrpted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_enc[i]);
			}
			printf("\n");
			decrypt(msg_enc, msg_dec, key);
			printf("\nDecrypted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_dec[i]);
			}
			printf("\n");
		}
	}
	else {
		// Run the Benchmark
		int i = 0;
		int size_KB = 2;
		// Choose a random Plaintext and Key
		for (i = 0; i < 32; i++) {
			msg_ascii[i] = 'a';
			key_ascii[i] = 'b';
		}
		// Run Encryption
		clock_t begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			encrypt(msg_ascii, key_ascii, msg_enc, key);
		clock_t end = clock();
		double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		double speed = size_KB / time_spent;
		printf("Software Encryption Speed: %f KB/s \n", speed);
		// Run Decryption
		begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			decrypt(msg_enc, msg_dec, key);
		end = clock();
		time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		speed = size_KB / time_spent;
		printf("Hardware Encryption Speed: %f KB/s \n", speed);
	}
	return 0;
}
