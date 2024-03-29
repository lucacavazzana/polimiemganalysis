/*
 * serialComm.c
 *
 *  Created on: Nov 8, 2011
 *      Author: Luca Cavazzana
 *        Mail:	luca.cavazzana@gmail.com
 *
 *
 * Serial port communication with EMGBoard.
 * Wrote merging the code of Luigi Seregni (Win version) and Giuseppe Lisi (OsX
 * version).
 *
 * Last update:   Nov 9, 2011
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

#ifdef _WIN32
#include <windows.h>
#else
// linux headers here
#endif

//#define _PARSEDEBUG

#define APPNAME "serialManager"
#define ERRBOX(txt) MessageBox(NULL, TEXT(txt), TEXT(APPNAME), MB_ICONERROR | MB_OK )	// find a way to make this box non-blocking
#define WARNBOX(txt) MessageBox(NULL, TEXT(txt), TEXT(APPNAME), MB_ICONWARNING | MB_OK )
#define BUFF_SIZE 1000
#define ACQ_SIZE 1000	// single acquisition size

<<<<<<< .mine
int max(int, int);
=======
void parse(char buff[], DWORD* bRead, unsigned long* sets,
		FILE* ch1, FILE* ch2, FILE* ch3, char *startedFlag, char remBuff[], int *rem);
>>>>>>> .r18

<<<<<<< .mine
main(int argc, char* argv[]){

	if (argc == 5) {

		/*
		 * fd1: input source 1 is for the EMG channel input
		 * fd2: input source 2 is for the standard input
		 */
		int fd1, fd2;

		/*destination files*/
		FILE *df, *df1, *df2, *df3;

		/* file descriptor set */
		fd_set readfs;

		/* maximum file desciptor used */
		int maxfd;

		/* loop while TRUE */
		int loop=1;

		int res;
		struct timeval Timeout;

		/*line started*/
		int ls=0;

		int current=0;
		char line[800];
		int flagStart=0;
		char * file;
		int result_code;

		chdir("serial");

		mode_t process_mask = umask(0);

		result_code = mkdir(argv[1], S_IRWXU | S_IRWXG | S_IRWXO);

		chdir(argv[1]);
		umask(process_mask);

		file = malloc(sizeof(char) * ((strlen(argv[2])+strlen(argv[4])) + 6));

		strcpy(file, argv[3]);
		strcat(file, "-");
		strcat(file, argv[4]);
		strcat(file, "-");
		strcat(file, argv[2]);
		strcat(file, ".txt");

		/*
		 * Creates the directories ch1, ch2 and ch3 with the
		 * relative img folders
		 */

		result_code = mkdir("ch1", S_IRWXU | S_IRWXG | S_IRWXO);

		chdir("ch1");

		result_code = mkdir("img", S_IRWXU | S_IRWXG | S_IRWXO);

		umask(process_mask);
		df1 = fopen(file, "w");

		if(df1==NULL) {
			printf("Error: can't create file for writing first channel.\n");
			exit(0);
		}

		chdir("..");

		result_code = mkdir("ch2", S_IRWXU | S_IRWXG | S_IRWXO);

		chdir("ch2");
		result_code = mkdir("img", S_IRWXU | S_IRWXG | S_ IRWXO);

		umask(process_mask);
		df2 = fopen(file, "w");

		if(df2==NULL) {
			printf("Error: can't create file for writing second channel.\n");
			exit(0);
		}

		chdir("..");

		result_code = mkdir("ch3", S_IRWXU | S_IRWXG | S_IRWXO);

		chdir("ch3");

		result_code = mkdir("img", S_IRWXU | S_IRWXG | S_IRWXO);

		umask(process_mask);
		df3 = fopen(file, "w");

		if(df3==NULL) {
			printf("Error: can't create file for writing third channe.\n");
			exit(0);
		}

		/* SERIAL */
		fd1 = open_input_source("/dev/tty.usbserial-A2003H2n");
		if (fd1<0) {exit(0);}
		fcntl(fd1, F_SETFL, 0);
		struct termios options;

		/*
		 * Get the current options for the port
		 */
		tcgetattr(fd1, &options);

		/*
		 * Set the baud rates
		 */
		cfsetispeed(&options, B57600);
		cfsetospeed(&options, B57600);

		/*
		 * Enable the receiver and set local mode
		 */
		options.c_cflag |= (CLOCAL | CREAD);

		/*
		 * Set the new options for the port
		 */

		tcsetattr(fd1, TCSANOW, &options);

		/* STANDARD INPUT */
		fd2 = 0;
		if (fd2<0) exit(0);

		/* maximum bit entry (fd) to test */
		maxfd = max(fd1, fd2)+1;


		/* loop for input */
		while (loop) {

			// set timeout value within input loop
			Timeout.tv_usec = 0;  // milliseconds
			Timeout.tv_sec  = 3;  // seconds

			/* set testing for source 1 */
			FD_SET(fd1, &readfs);

			/* set testing for source 2 */
			FD_SET(fd2, &readfs);

			/* block until input becomes available */
			res = select(maxfd, &readfs, NULL, NULL, &Timeout);

			//number of file descriptors with input = 0,
			//timeout occurred.
			if (res == 0) {
				printf("Timeout occured\n");
				exit(1);
			}
			/* input from source 1 available */
			if (FD_ISSET(fd1, &readfs))
				handle_input_from_source(fd1, df, df1, df2, df3, &flagStart, &ls, &current, line);

			/* input from source 2 available */
			if (FD_ISSET(fd2, &readfs))
				handle_input_from_source2(fd1, fd2, df, df1, df2, df3);
		}
	}

	else{
		printf("Provide in order:\n");
		printf("1) the name of the person \n");
		printf("2) the movement done \n");
		printf("3) the wanted movement identificator(int)\n");
		printf("4) the progressive number of the movement\n");
	}
}
=======
int main (int argc, char** argv){
>>>>>>> .r18

<<<<<<< .mine
/*
 */
int open_input_source(char * port) {
	int fd = 0;

	/* open the device to be non-blocking (read will
	 * return immediatly) */
	fd = open(port, O_RDWR | O_NOCTTY | O_NONBLOCK);
	if (fd <0) {
		perror(port);
		return -1;
	}
	else
		return fd;
}
=======
	char HELPTXT[] =  "help text\n"	// FIXME
			"	-h:	print help\n"
			"	-v:	verbose\n"
			"	-d:	input port (default: COM6 or TTY...)\n"
			"	-n:	# of acquisitions to save\n"
			"	-p:	root path to save output files\n"
			"	-g:	gesture name\n";
>>>>>>> .r18

<<<<<<< .mine
void handle_input_from_source(int fd, FILE *df, FILE *df1, FILE *df2, FILE *df3, int *flagStart, int *ls, int *current, char *line) {
	int res = 0, i;
	char buf[255];
	char ret='\r';
	int d1, d2, d3;
	res = read(fd, buf, 255);
	buf[res]=0;

	/*Parsing of the data coming from the EMG board*/

	for (i = 0; i < res; i++){

		if(*flagStart==0 && buf[i]=='I'){
			*flagStart=1;
		}

		if(*flagStart==1){
			if(buf[i]=='D' && *ls==0){
				*ls=1;
				*current=0;

			}
			else if(*ls==1){
				line[*current]=buf[i];
				*current=*current+1;
			}
			if(buf[i]=='\r' && *ls==1){
				*ls=0;
				*current=0;

				sscanf(line, ":%d %d %d", &d1, &d2, &d3);
				printf("%d %d %d\n", d1, d2, d3);


				fprintf(df1, "%d\r", d1);
				fprintf(df2, "%d\r", d2);
				fprintf(df3, "%d\r", d3);
			}
		}
	}
}
=======
	HANDLE hSer;	// handle serial port
	char rBuff[BUFF_SIZE] = {'0'};	// read buffer
	DWORD bytesRead = 0;
>>>>>>> .r18

<<<<<<< .mine
void handle_input_from_source2(int fd1, int fd2, FILE *df, FILE *df1, FILE *df2, FILE *df3) {
	fclose(df1);
	fclose(df2);
	fclose(df3);
	close(fd1);
	close(fd2);
	exit(0);
}
=======
	// usually 16 chars are enough for a complete data. Make it 25 to be sure.
	char remBuff[25];
	int rem = 0;	// #char of incomplete data set left from last scan
>>>>>>> .r18

<<<<<<< .mine
int max(int i1, int i2) {
	if (i1 > i2)
		return i1;
	else
		return i2;
}
=======
	char startedFlag;
	unsigned long sets = 0;	//

	FILE *ch1 = NULL, *ch2 = NULL, *ch3 = NULL; // FIXME replace with output handlers

	// options
	char verb = 0;	// verbose
#ifdef _WIN32
	char *port = "COM6";	// FIXME: default port name (my default port is COM6)
#else
	char *port = "TTY";	// FIXME: default port name (my default port is ...)
#endif
	int nAcq = 0;
	char* outPath = NULL;
	char* gestName = NULL;

	char* filePath = NULL;

	// options parsing -------------------------------------
	int c;
	while ((c = getopt (argc, argv, "vhd:n:o:g:")) != -1) {
		switch(c) {
		case 'd':
			port = optarg;
			printf("- port  '%s' set\n", port);
			break;
		case 'h':
			printf(HELPTXT);
			return 0;
			break;
		case 'v':
			verb = 1;
			break;
		case 'n':
			nAcq = atoi((char*)optarg);
			break;
		case 'o':
			outPath = optarg;
			printf("- writing output into '%s' folder\n", outPath);
			// TODO: check folder
			break;
		case 'g':
			gestName = optarg;
			break;
		case '?':
			printf("See help for more info\n");
			return 0;
		default:
			abort();
		}
	}

	// checking parameters
	if(nAcq && !outPath) {
		printf("\nERROR: specify the output path to save data\n");
		exit(-1);
	}

	/***************************************************************************
	 ******    initialize output streams    ************************************
	 **************************************************************************/
	if(nAcq) {	// files

		if(mkdir(outPath)) {
			if(errno == EEXIST) {
				printf("WARNING: '%s' folder already exists\n", outPath);
			} else {
				printf("ERROR: could not create '%s' folder \n", outPath);
				exit(-1);
			}
		}

		if(gestName) {
			filePath = malloc(sizeof(char)*(strlen(outPath)+strlen(gestName)+10));
			strcpy(filePath, outPath);
#ifdef _WIN32
			strcat(filePath, "\\");
#else
			strcat(filePath, "/");
#endif
			strcat(filePath, gestName);

			if(mkdir(filePath)) {
				printf("ERRROR: could not create '%s' folder\n", filePath);
				exit(-1);
			}
		} else {
			filePath = malloc(sizeof(char)*(strlen(outPath)+10));
			strcpy(filePath, outPath);
		}

#ifdef _WIN32
		strcat(filePath, "\\ch1.txt");
#else
		strcat(filePath, "/ch1.txt");
#endif
		printf("%s\n", filePath);
		ch1 = fopen(filePath, "w");
		filePath[strlen(filePath)-5] = '2';
		ch2 = fopen(filePath, "w");
		filePath[strlen(filePath)-5] = '3';
		ch3 = fopen(filePath, "w");
		if(!(ch1 && ch2 && ch3)) {
			printf("ERROR: could not open output files\n");
			exit(-1);
		}
	} else {	// sockets / pipes

	}

	/***************************************************************************
	 ******    initialize input board    ***************************************
	 **************************************************************************/
	hSer = CreateFile(port,
			GENERIC_READ | GENERIC_WRITE,
			0,
			NULL,
			OPEN_EXISTING,
			0, //FILE_ATTRIBUTE_NORMAL,
			NULL);

	if(hSer == INVALID_HANDLE_VALUE) {
		if(GetLastError() == ERROR_FILE_NOT_FOUND) {
			printf("Wrong serial port");
			//ERRBOX("Wrong serial port");
		}
		else {
			printf("A serial error occurred");
			//ERRBOX("A serial error occurred");
		}
		exit(-1);
	}

	DCB dcbPars;// = {0};
	dcbPars.DCBlength = sizeof(dcbPars);

	if (!GetCommState(hSer, &dcbPars)) {
		fprintf(stderr, "Error getting serial state");
		ERRBOX("Error getting serial state");
	}

	dcbPars.BaudRate = CBR_57600;
	dcbPars.ByteSize = 8;
	dcbPars.StopBits = ONESTOPBIT;
	dcbPars.Parity = NOPARITY;

	if(!SetCommState(hSer, &dcbPars)) {
		fprintf(stderr, "Error setting serial port state");
		ERRBOX("Error setting serial port state");
	}

	COMMTIMEOUTS timeouts={0};
	/*timeouts.ReadIntervalTimeout=MAXDWORD;
	timeouts.ReadTotalTimeoutConstant=0;
	timeouts.ReadTotalTimeoutMultiplier=0;
	timeouts.WriteTotalTimeoutConstant=0;
	timeouts.WriteTotalTimeoutMultiplier=0;*/
	timeouts.ReadIntervalTimeout = 50;	// TODO: test to find suitable values
	timeouts.ReadTotalTimeoutConstant = 50;
	timeouts.ReadTotalTimeoutMultiplier = 10;
	timeouts.WriteTotalTimeoutConstant = 50;
	timeouts.WriteTotalTimeoutMultiplier = 10;

	if(!SetCommTimeouts(hSer, &timeouts)) {
		fprintf(stderr, "Error occurred setting timeouts");
		ERRBOX("Error occurred setting timeouts");
	}

	if(verb)
		printf("Serial port opened\n");

	printf("Starting acquisition\n");

	/***************************************************************************
	 *****    ACQUISITION    ***************************************************
	 **************************************************************************/
	while(ReadFile(hSer, rBuff, sizeof(rBuff), &bytesRead, NULL)) {

		// managing input
		parse(rBuff, &bytesRead, &sets, ch1, ch2, ch3, &startedFlag, remBuff, &rem);

		// counting acquisitions
		if(nAcq) {
			if(sets > ACQ_SIZE) {
				if(verb)
					printf("Acq %d completed\n", nAcq);
				sets = 0;
			}
			if (--nAcq == 1)
				break;
		}
	}	// end parsing WHILE


	// bye bye
	CloseHandle(hSer);
	fclose(ch1);
	fclose(ch2);
	fclose(ch3);

	return 0;
}	// end MAIN


void parse(char buff[], DWORD* bRead, unsigned long* sets,
		FILE* ch1, FILE* ch2, FILE* ch3, char *startedFlag, char remBuff[], int *rem) {
	int j, i=0;
	int v1, v2, v3;

#ifdef _PARSEDEBUG
	if(*bRead)
		printf("PARSE FUNCT: I'm alive! Bytes red: %d\n", (int)*bRead);
#endif

	while(i<(int)(*bRead) && buff[i]!='D' && buff[i]!='I'){i++;};

	if(i==(int)(*bRead)) {	// add to remBuffer
		memcpy(remBuff+(*rem), buff, (int)(*bRead));
		*rem += (int)(*bRead);
		return;
	}

	if(*rem) {	// managing remaining chunk from previous acq
		memcpy(remBuff+(*rem), buff, i);

		// parsing values
		/*
		v1 = atoi(remBuff+2);	// pointing to the first number
		j=3;
		while(remBuff[j++]!=' '); // looking for second number
		v2 = atoi(remBuff+j);
		while(remBuff[j++]!=' '); // looking for third number
		v3 = atoi(remBuff+j);
		 */
		sscanf(remBuff+2,"%d %d %d", &v1, &v2, &v3);

		// writing output

		if(ch1 && ch2 && ch3) {
			fprintf(ch1, "%d\n", v1);
			fprintf(ch2, "%d\n", v2);
			fprintf(ch3, "%d\n", v3);
			*sets++;
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
			while(i<(int)(*bRead) && buff[i]!='D'){i++;}; // go to D or end buff
			if(i==(int)(*bRead))	// trash this chunk, else we have D-index
				return;
		}

		// check if we have a complete data set (look for the next D)
		j = i+1;
		while(j<(int)(*bRead) && buff[j]!='D' && buff[j]!='I'){j++;}

#ifdef _PARSEDEBUG
		printf(" D in %d, next in %d (%d)\n", i, j, (int)(*bRead));
#endif

		if(j<((int)(*bRead))){	// found next 'D'

			// parsing values
			/*
			i = i+2;	// pointing to the first number
			v1 = atoi(buff+i);
			while(buff[i++]!=' '); // looking for second number
			v2 = atoi(buff+i);
			while(buff[i++]!=' '); // looking for third number
			v3 = atoi(buff+i);
			 */
			sscanf(buff+i+2,"%d %d %d", &v1, &v2, &v3);

			// writing output
			if(ch1 && ch2 && ch3) {
				fprintf(ch1, "%d\n", v1);
				fprintf(ch2, "%d\n", v2);
				fprintf(ch3, "%d\n", v3);
				*sets++;
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
			//if ((int)(*bRead)!=N)	// if this error occurs, probably bRead was overwritten by an buffOverflow somewhere
			//	ERRBOX("DAMN!");
			fflush(stdout);
#endif
			return;
		}
	}	// end WHILE(1)

}	// end parse FUNCTION
>>>>>>> .r18
