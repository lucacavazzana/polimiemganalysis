/*
 * serialComm.c
 *
 *  Created on: Nov 8, 2011
 *      Author: Luca Cavazzana
 *        Mail:	luca.cavazzana@gmail.com
 *
 *
 * Serial port communication with EMGBoard.
 * Inspired by Lisi' OsX version.
 *
 * The more I work on this code the messier it becomes... one day I'll refactor
 * I promise...
 *
 * Last update:   Nov 24, 2011
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

#include <fcntl.h>
#include <string.h>
#include <sys/shm.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <termios.h>
#include <unistd.h>


//#define _PARSEDEBUG

#define APPNAME "serialManager"
#define BUFF_SIZE 100
#define ACQ_SIZE 540	// single acquisition size

void parseFile(char buff[], int bRead, unsigned long* sets,
		FILE* ch1, FILE* ch2, FILE* ch3, FILE* raw,
		char remBuff[], int *rem);

void parseFifo(char buff[], int bRead, unsigned long* sets,
		int ch1, int ch2, int ch3,
		char remBuff[], int *rem);

int main (int argc, char** argv){

	char HELPTXT[] =  "help text\n"	// FIXME
			"	-h:	print help\n"
			"	-v:	verbose\n"
			"	-d:	set input port (default: COM6 or /dev/ttyUSB0)\n"
			"	-a:	acquisition mode\n"
			"	-p:	set root folder to save output files (patient name) (acq mode)\n"
			"	-i:	set gesture ID (acq mode)\n"
			"	-g:	set gesture name (acq mode)\n"
			"	-s: sequence number (acq mode)\n";

	int hSer;
	struct termios portOpts;

	int bytesRead = 0;

	char rBuff[BUFF_SIZE];	// read buffer


	// usually 16 chars are enough for a complete data. Make it 25 to be sure.
	char remBuff[25];
	int rem = 0;	// #char of incomplete data set left from last scan

	unsigned long sets = 0;	//

	FILE *ch1 = NULL, *ch2 = NULL, *ch3 = NULL;
	FILE *raw = NULL;

	int fifo1, fifo2, fifo3;

	// options
	char verb = 0;	// verbose
	char *port = "/dev/ttyUSB0";

	char acq = 0;
	char* patient = NULL;
	char* gestName = NULL;
	int gestID = -1;
	int seq = -1;

	char* filePath = NULL;

	// options parsing -------------------------------------
	int c;
	while ((c = getopt (argc, argv, "vhd:ap:g:i:s:")) != -1) {
		switch(c) {
		case 'd':
			port = optarg;
			break;
		case 'h':
			printf("%s", HELPTXT);
			return 0;
			break;
		case 'v':
			verb = 1;
			break;
		case 'a':
			acq = 1;
			break;
		case 'p':
			patient = optarg;
			break;
		case 'g':
			gestName = optarg;
			break;
		case 'i':
			sscanf(optarg, "%d", &gestID);
			break;
		case 's':
			sscanf(optarg, "%d", &seq);
			break;
		case '?':
			printf("See help for more info\n");
			return -1;
		default:
			abort();
		}
	}

	if(verb) {
		printf("- port '%s' set\n", port);
		fflush(stdout);
	}

	if(acq) {	// if in acquisition mode

		// checking parameters
		if(!patient) {
			printf("\nERROR: specify root folder / patient name ID\n");
			exit(-1);
		}

		if(gestID<0) {
			printf("\nERROR: specify gesture ID\n");
			exit(-1);
		}

		if(seq<0) {
			printf("\nERROR: specify sequence number\n");
			exit(-1);
		}

		if(verb){
			printf("- writing output into '%s' folder\n", patient);
			fflush(stdout);
		}


		/***********************************************************************
		 ******    INITIALIZE OUTPUT STREAMS    ********************************
		 **********************************************************************/
		if(mkdir(patient, S_IRWXU | S_IRWXG | S_IRWXO)) {
			if(errno != EEXIST) {
				printf("ERROR: could not create '%s' folder\n", patient);
				exit(-1);
			} //else
			//	printf("WARNING: '%s' folder already execlipseists (coud overwrite data)\n", patient);
		}

		filePath = malloc(sizeof(char)*(strlen(patient) +
				(gestName?strlen(gestName):0) + 15));

		strcpy(filePath, patient);
		strcat(filePath, "/ch1");

		do {
			if(mkdir(filePath, S_IRWXU | S_IRWXG | S_IRWXO)) {
				if(errno != EEXIST) {
					printf("ERROR: could not create '%s' folder\n", filePath);
					exit(-1);
				} //elseres = read(fd, buff, BUFFSIZE);
				//	printf("WARNING: '%s' folder already exists\n", filePath);
			}
		} while(++filePath[strlen(patient)+3]!='4');	// ch1, ch2, ch3

		filePath[strlen(patient)+3]='1';

		strcat(filePath, "/");

		if(gestName) {
			sprintf(filePath+strlen(patient)+5, "%d-%d-%s.txt", gestID, seq, gestName);
		} else {
			sprintf(filePath+strlen(patient)+5, "%d-%d.txt", gestID, seq);
		}

		ch1 = fopen(filePath, "w");
		filePath[strlen(patient)+3]++;
		ch2 = fopen(filePath, "w");
		filePath[strlen(patient)+3]++;
		ch3 = fopen(filePath, "w");

		// raw data file
		sprintf(filePath+strlen(patient)+1, "raw");
		mkdir(filePath, S_IRWXU | S_IRWXG | S_IRWXO);

		filePath[strlen(patient)+4] = '/';

		raw = fopen(filePath, "w");
		if(!(ch1 && ch2 && ch3 && raw)) {
			printf("ERROR: could not open output files\n");
			exit(-1);
		}

	} else {

		if(mkfifo("ch1", S_IRUSR | S_IWUSR) == -1 ||
				mkfifo("ch2", S_IRUSR | S_IWUSR) == -1 ||
				mkfifo("ch3", S_IRUSR | S_IWUSR) == -1) {

			printf(" - WARNING: FIFOs already exist\n");
			fflush(stdout);
		}

		fifo1 = open("ch1", O_WRONLY);
		fifo2 = open("ch2", O_WRONLY);
		fifo3 = open("ch3", O_WRONLY);

		raw = fopen("raw.txt", "w");
		if(!raw){
			printf(" - WARNING: could not open raw output file\n");
			fflush(stdout);
		}

	}

	/***************************************************************************
	 ******    INITIALIZE INPUT BOARD    ***************************************
	 **************************************************************************/
	hSer = open(port, O_RDWR | O_NOCTTY | O_NDELAY);

	if(hSer < 0) {
		printf("Could not open serial port %s\n", port);
		exit(-1);
	}

	tcgetattr(hSer, &portOpts);
	fcntl(hSer, F_SETFL, 0);

	// set baud rate
	cfsetispeed(&portOpts, B57600);
	cfsetospeed(&portOpts, B57600);

	portOpts.c_cflag |= (CLOCAL | CREAD);
	portOpts.c_oflag = 0;
	portOpts.c_cc[VTIME] = 0;	// reading timeout
	portOpts.c_cc[VMIN] = 100;	// blocks until at least # chars received

	tcflush(hSer, TCIFLUSH);
	tcsetattr(hSer, TCSANOW, &portOpts);


	if(verb) {
		printf("Serial port opened\n"
				"Starting acquisition\n");
	}

	sets = 0;

	/***************************************************************************
	 *****    ACQUISITION    ***************************************************
	 **************************************************************************/
	if(acq){
		printf("Starting acquisition\n");
		fflush(stdout);
		// ready... set... start!
		for(c=2; c!=0; c--) {
			printf("%d...\n", c);
			fflush(stdout);
			sleep(1);
		}
		printf("Start!\n");
		tcflush(hSer, TCIFLUSH);
		fflush(stdout);

		while(sets < ACQ_SIZE) {
			bytesRead = read(hSer, rBuff, BUFF_SIZE);

			if(bytesRead == -1) {
				printf("An error occurred reading the EMG board\n");
				exit(-1);
			}

			rBuff[bytesRead] = '\0';

			printf("%s\n---\n", rBuff);

			parseFile(rBuff, bytesRead, &sets, ch1, ch2, ch3, raw,
					remBuff, &rem);
		}	// end parsing WHILE


		// end acquisition IF
	} else {

		/**********************************************************************
		 *****    RECOGNITION    **********************************************
		 **********************************************************************/

		//while(1) {
		bytesRead = read(hSer, rBuff, BUFF_SIZE);
		if(bytesRead == -1) {
			printf("An error occurred reading the EMG board\n");
			exit(-1);
		}

		rBuff[bytesRead] = '\0';
		fprintf(raw, "%s", rBuff);
		parseFifo(rBuff, bytesRead, &sets, fifo1, fifo2, fifo3,
				remBuff, &rem);
		//}

	}


	// bye bye
	if(acq) {
		fclose(ch1);
		fclose(ch2);
		fclose(ch3);
	} else {
		close(fifo1);
		close(fifo2);
		close(fifo3);
	}

	close(hSer);
	fclose(raw);

	return 0;
}	// end MAIN



void parseFile(char buff[], int bRead, unsigned long* sets,
		FILE* ch1, FILE* ch2, FILE* ch3, FILE* raw, char remBuff[], int *rem) {

	int j, i=0;
	int v1, v2, v3;

#ifdef _PARSEDEBUG
	if(bRead)
		printf("PARSE FUNCT: I'm alive! Bytes read: %d\n", bRead);
#endif

	fprintf(raw, "%s", buff);

	while(i<bRead && buff[i]!='D' && buff[i]!='I'){i++;};

	if(i==bRead) {	// less than a complete set, add to remBuffer
		memcpy(remBuff+(*rem), buff, bRead);
		*rem += bRead;
		return;
	}
	write(ch3, " ", 1);
	if(*rem) {	// managing remaining chunk from previous acq
		memcpy(remBuff+(*rem), buff, i);

		// parsing values
		sscanf(remBuff+2,"%d %d %d", &v1, &v2, &v3);

		// writing output

		if(ch1 && ch2 && ch3) {
			fprintf(ch1, "%d\n", v1);
			fprintf(ch2, "%d\n", v2);
			fprintf(ch3, "%d\n", v3);
			(*sets)++;
		}

		*rem = 0;

#ifdef _PARSEDEBUG
		printf("---\n%.14s    <- starting chunk\n---\n", buff);
		printf("%.13s    <- now in remBuff\n", remBuff);
		printf("d-%d %d %d    <- parsed\n---\n", v1, v2, v3);
		fflush(stdout);
#endif
	}	// else ignore starting chunk


	while(1){	// now managing the big part

#ifdef _PARSEDEBUG
		printf("%.13s ", buff+i);
#endif

		if(buff[i]=='I'){
			while(i<bRead && buff[i]!='D'){i++;}; // go to D or end buff
			if(i==bRead)	// trash this chunk, else we have D-index
				return;
		}

		// check if we have a complete data set (look for the next D)
		j = i+1;
		while(j<bRead && buff[j]!='D' && buff[j]!='I'){j++;}

#ifdef _PARSEDEBUG
		printf(" D in %d, next in %d (%d)\n", i, j, bRead);
#endif

		if(j<bRead){	// found next 'D'

			// parsing values
			sscanf(buff+i+2,"%d %d %d", &v1, &v2, &v3);

			// writing output
			if(ch1 && ch2 && ch3) {
				fprintf(ch1, "%d\n", v1);
				fprintf(ch2, "%d\n", v2);
				fprintf(ch3, "%d\n", v3);
				(*sets)++;
			}

			i = j;

#ifdef _PARSEDEBUG
			printf("d-%d %d %d\n", v1, v2, v3);
			fflush(stdout);
#endif

		} else {	// incomplete data set
			memcpy(remBuff, buff+i, j-i);
			*rem = j-i;
#ifdef _PARSEDEBUG
			printf("---\n%.14s    <- moved to remBuff (last chars could be dirty Bytes from previous parsing)\n---\n", remBuff);
			printf("PARSE FUNCT: exit\n");
			//if (bRead!=N)	// if this error occurs, probably bRead was overredredwritten by an buffOverflow somewhere
			//	ERRBOX("DAMN!");
			fflush(stdout);
#endif
			return;
		}
	}	// end WHILE(1)

}	// end parse FUNCTION




void parseFifo(char buff[], int bRead, unsigned long* sets,
		int ch1, int ch2, int ch3, char remBuff[], int *rem) {

	int j, i=0;

#ifdef _PARSEDEBUG
	if(bRead)
		printf("PARSE FUNCT: I'm alive! Bytes read: %d\n", bRead);
#endif


	while(i<bRead && buff[i]!='D' && buff[i]!='I'){i++;};

	if(i==bRead) {	// less than a complete set, add to remBuffer
		memcpy(remBuff+(*rem), buff, bRead);
		*rem += bRead;
		return;
	}

	if(*rem) {	// managing remaining chunk from previous acq
		memcpy(remBuff+(*rem), buff, i);

		j = 3; // first space can't be
		while(remBuff[j++]!=' ');
		write(ch1, remBuff+2, j-2);
		// writing ch2
		i = j+1;
		while(remBuff[i++]!=' ');
		write(ch2, remBuff+j, i-j);
		j = i+1;
		while(remBuff[j++]!='\r');
		write(ch3, remBuff+i, j-i);

		(*sets)++;
		*rem = 0;

#ifdef _PARSEDEBUG
		printf("---\n%.14s    <- starting chunk\n---\n", buff);
		printf("%.13s    <- now in remBuff\n", remBuff);
		printf("d-%d %d %d    <- parsed\n---\n", v1, v2, v3);
		fflush(stdout);
#endif
	}	// else ignore starting chunk


	while(1) {	// now managing the big part

#ifdef _PARSEDEBUG
		printf("%.13s ", buff+i);
#endif

		if(buff[i]=='I'){
			while(i<bRead && buff[i]!='D'){i++;}; // go to D or end buff
			if(i == bRead)	// trash this chunk, else we have D-index
				return;
		}

		// check if we have a complete data set (look for the next D)
		j = i+1;
		while(j<bRead && buff[j]!='D' && buff[j]!='I'){j++;}

#ifdef _PARSEDEBUG
		printf(" D in %d, next in %d (%d)\n", i, j, bRead);
#endif

		if(j<bRead){	// found next 'D'

			// parsing values
			// sscanf(buff+i+2,"%d %d %d", &v1, &v2, &v3);

			// writing ch1
			i += 2;
			j = i+1;
			while(buff[j++]!=' ');
			write(ch1, buff+i, j-i);
			// writing ch2
			i = j+1;
			while(buff[i++]!=' ');
			write(ch2, buff+j, i-j);
			j = i+1;
			while(buff[j++]!='\r');
			write(ch3, buff+i, j-i);

			(*sets)++;

			i = j;

		} else {	// incomplete data set
			memcpy(remBuff, buff+i, j-i);
			*rem = j-i;
#ifdef _PARSEDEBUG
			printf("---\n%.14s    <- moved to remBuff (last chars could be dirty Bytes from previous parsing)\n---\n", remBuff);
			printf("PARSE FUNCT: exit\n");
			//if (bRead!=N)	// if this error occurs, probably bRead was overredredwritten by an buffOverflow somewhere
			//	ERRBOX("DAMN!");
			fflush(stdout);
#endif
			return;
		}
	}	// end WHILE(1)

}	// end parse FUNCTION
