/*
 * serialComm.c
 *
 *  Created on: Nov 8, 2011
 *      Author: Luca Cavazzana
 *        Mail:	luca.cavazzana(at)gmail.com
 *
 *
 * Serial port communication with EMGBoard.
 * Wrote merging the code of Luigi Seregni (Win version) and Giuseppe Lisi (OsX
 * version).
 *
 * The more I work on this code the messier it becomes... one day I'll refactor
 * I promise...
 *
 * Last update:   Nov 9, 2011
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

#ifdef _WIN32
#include <windows.h>
#include <conio.h>
#else
// linux headers here
#endif

//#define _PARSEDEBUG

#define APPNAME "serialManager"
#define ERRBOX(txt) MessageBox(NULL, TEXT(txt), TEXT(APPNAME), MB_ICONERROR | MB_OK )	// find a way to make this box non-blocking
#define WARNBOX(txt) MessageBox(NULL, TEXT(txt), TEXT(APPNAME), MB_ICONWARNING | MB_OK )
#define BUFF_SIZE 1000
#define ACQ_SIZE 540	// single acquisition size

void parse(char buff[], DWORD* bRead, unsigned long* sets,
		FILE* ch1, FILE* ch2, FILE* ch3, FILE* raw,
		char *startedFlag, char remBuff[], int *rem);

int main (int argc, char** argv){

	char HELPTXT[] =  "help text\n"	// FIXME
			"	-h:	print help\n"
			"	-v:	verbose\n"
			"	-d:	set input port (default: COM6 or TTY...)\n"
			"	-a:	acquisition mode\n"
			"	-p:	set root folder to save output files (patient name) (acq mode)\n"
			"	-i:	set gesture ID (acq mode)\n"
			"	-g:	set gesture name (acq mode)\n"
			"	-s: sequence number (acq mode)\n";

	HANDLE hSer;	// handle serial port
	char rBuff[BUFF_SIZE] = {'0'};	// read buffer
	DWORD bytesRead = 0;

	// usually 16 chars are enough for a complete data. Make it 25 to be sure.
	char remBuff[25];
	int rem = 0;	// #char of incomplete data set left from last scan

	char startedFlag;
	unsigned long sets = 0;	//

	FILE *ch1 = NULL, *ch2 = NULL, *ch3 = NULL; // FIXME replace with output handlers
	FILE *raw = NULL;

	// options
	char verb = 0;	// verbose
#ifdef _WIN32
	char *port = "COM6";	// FIXME: default port name (my default port is COM6)
#else
	char *port = "TTY";	// FIXME: default port name (my default port is ...)
#endif
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
			printf(HELPTXT);
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
		if(mkdir(patient)) {
			if(errno != EEXIST) {
				printf("ERROR: could not create '%s' folder\n", patient);
				exit(-1);
			} //else
			//	printf("WARNING: '%s' folder already exists (coud overwrite data)\n", patient);
		}

		filePath = malloc(sizeof(char)*(strlen(patient) +
				(gestName?strlen(gestName):0) + 15));

		strcpy(filePath, patient);
#ifdef _WIN32
		strcat(filePath, "\\ch1");
#else
		strcat(filePath, "/ch1");
#endif

		do {
			if(mkdir(filePath)) {
				if(errno != EEXIST) {
					printf("ERROR: could not create '%s' folder\n", filePath);
					exit(-1);
				} //else
				//	printf("WARNING: '%s' folder already exists\n", filePath);
			}
		} while(++filePath[strlen(patient)+3]!='4');	// ch1, ch2, ch3

		filePath[strlen(patient)+3]='1';
#ifdef _WIN32
		strcat(filePath, "\\");
#else
		strcat(filePath, "/");
#endif

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
		mkdir(filePath);

#ifdef _WIN32
		filePath[strlen(patient)+4] = '\\';
#else
		filePath[strlen(patient)+4] = '/';
#endif
		raw = fopen(filePath, "w");

		// one-folder-per-gesture version
		/* if(gestName) {
			filePath = malloc(sizeof(char)*(strlen(patient)+strlen(gestName)+10));
			strcpy(filePath, patient);
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
			filePath = malloc(sizeof(char)*(strlen(patient)+10));
			strcpy(filePath, patient);
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
		ch3 = fopen(filePath, "w"); */

		if(!(ch1 && ch2 && ch3 && raw)) {
			printf("ERROR: could not open output files\n");
			exit(-1);
		}
	} else {	// sockets / pipes
		ch1 = CreateNamedPipe(
				"\\.\pipe\emgCh1",
				PIPE_ACCESS_OUTBOUND,
				PIPE_TYPE_BYTE, // mode
				1,		// max instances
				1000,	// out buffSize
				1000,	// in buffSize
				0,		// time out
				NULL);	// security

		ch2 = CreateNamedPipe(
				"\\.\pipe\emgCh2",
				PIPE_ACCESS_OUTBOUND,
				PIPE_TYPE_BYTE, // mode
				1,		// max instances
				1000,	// out buffSize
				1000,	// in buffSize
				0,		// time out
				NULL);	// security

		ch3 = CreateNamedPipe(
				"\\.\pipe\emgCh3",
				PIPE_ACCESS_OUTBOUND,
				PIPE_TYPE_BYTE, // mode
				1,		// max instances
				1000,	// out buffSize
				1000,	// in buffSize
				0,		// time out
				NULL);	// security

		raw = CreateNamedPipe(
				"\\.\pipe\emgRaw",
				PIPE_ACCESS_OUTBOUND,
				PIPE_TYPE_BYTE, // mode
				1,		// max instances
				1000,	// out buffSize
				1000,	// in buffSize
				0,		// time out
				NULL);	// security
	}

	if(ConnectNamedPipe(ch1, NULL)) {
		printf("ch1 connected\n");
		fflush(stdout);
	}
	if(ConnectNamedPipe(ch2, NULL)) {
		printf("ch1 connected\n");
		fflush(stdout);
	}
	if(ConnectNamedPipe(ch3, NULL)) {
		printf("ch3 connected\n");
		fflush(stdout);
	}
	if(ConnectNamedPipe(raw, NULL)) {
		printf("raw connected\n");
		fflush(stdout);
	}

	/***************************************************************************
	 ******    INITIALIZE INPUT BOARD    ***************************************
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
			printf("Wrong serial port\n");
			//ERRBOX("Wrong serial port");
		}
		else {
			printf("A serial error occurred\n");
			//ERRBOX("A serial error occurred");
		}
		exit(-1);
	}

	DCB dcbPars;// = {0};
	dcbPars.DCBlength = sizeof(dcbPars);

	if (!GetCommState(hSer, &dcbPars)) {
		fprintf(stderr, "Error getting serial state\n");
		ERRBOX("Error getting serial state");
	}

	dcbPars.BaudRate = CBR_57600;
	dcbPars.ByteSize = 8;
	dcbPars.StopBits = ONESTOPBIT;
	dcbPars.Parity = NOPARITY;

	if(!SetCommState(hSer, &dcbPars)) {
		fprintf(stderr, "Error setting serial port state\n");
		ERRBOX("Error setting serial port state");
	}

	COMMTIMEOUTS timeouts={0};
	if(acq) {	// if training get the char we need
		timeouts.ReadIntervalTimeout = 50;	// TODO: test to find suitable values
		timeouts.ReadTotalTimeoutConstant = 50;
		timeouts.ReadTotalTimeoutMultiplier = 10;
		timeouts.WriteTotalTimeoutConstant = 50;
		timeouts.WriteTotalTimeoutMultiplier = 10;
	} else {	// if recognizing read sets as soon as they're ready
		/* FIXME: maybe we're wasting time lock-spinning...
		 * maybe is better simply to set a little buffer */
		timeouts.ReadIntervalTimeout = MAXDWORD;
		timeouts.ReadTotalTimeoutConstant = 0;
		timeouts.ReadTotalTimeoutMultiplier = 0;
		timeouts.WriteTotalTimeoutConstant = 0;
		timeouts.WriteTotalTimeoutMultiplier = 0;
	}

	if(!SetCommTimeouts(hSer, &timeouts)) {
		fprintf(stderr, "Error occurred setting timeouts\n");
		ERRBOX("Error occurred setting timeouts");
	}

	if(verb) {
		printf("Serial port opened\n"
				"Starting acquisition\n");
	}

	/***************************************************************************
	 *****    ACQUISITION    ***************************************************
	 **************************************************************************/

	if(acq) {
		printf("Starting acquisition\n");
		fflush(stdout);
		WARNBOX("Move after start");
		for(c=2; c!=0; c--) {
			printf("%d...\n", c);
			fflush(stdout);
#ifdef _WIN32
			Sleep(1000);
#else
			sleep(1);
#endif
		}
		printf("Start!\n");
		fflush(stdout);
		PurgeComm(hSer, PURGE_TXABORT | PURGE_RXABORT |
				PURGE_TXCLEAR | PURGE_RXCLEAR);

		while(sets < ACQ_SIZE) {
			ReadFile(hSer, rBuff, sizeof(rBuff), &bytesRead, NULL);
			// managing input
			parse(rBuff, &bytesRead, &sets, ch1, ch2, ch3, raw, &startedFlag, remBuff, &rem);
		}
		printf("Acquisition %d complete\n", seq);
		fflush(stdout);

	} else {
		while(ReadFile(hSer, rBuff, sizeof(rBuff), &bytesRead, NULL)) {

			// managing input
			parse(rBuff, &bytesRead, &sets, ch1, ch2, ch3, raw, &startedFlag, remBuff, &rem);

		}	// end parsing WHILE
	}


	// bye bye
	CloseHandle(hSer);
	fclose(ch1);
	fclose(ch2);
	fclose(ch3);
	fclose(raw);

	return 0;
}	// end MAIN


void parse(char buff[], DWORD* bRead, unsigned long* sets,
		FILE* ch1, FILE* ch2, FILE* ch3, FILE* raw,
		char *startedFlag, char remBuff[], int *rem) {

	int j, i=0;
	int v1, v2, v3;

#ifdef _PARSEDEBUG
	if(*bRead)
		printf("PARSE FUNCT: I'm alive! Bytes read: %d\n", (int)*bRead);
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
		sscanf(remBuff+2,"%d %d %d", &v1, &v2, &v3);

		// writing output

		if(ch1 && ch2 && ch3) {
			fprintf(ch1, "%d\n", v1);
			fprintf(ch2, "%d\n", v2);
			fprintf(ch3, "%d\n", v3);
			fprintf(raw, "D: %d %d %d\n", v1, v2, v3);
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
			sscanf(buff+i+2,"%d %d %d", &v1, &v2, &v3);

			// writing output
			if(ch1 && ch2 && ch3) {
				fprintf(ch1, "%d\n", v1);
				fprintf(ch2, "%d\n", v2);
				fprintf(ch3, "%d\n", v3);
				fprintf(raw, "D: %d %d %d\n", v1, v2, v3);
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
			//if ((int)(*bRead)!=N)	// if this error occurs, probably bRead was overwritten by an buffOverflow somewhere
			//	ERRBOX("DAMN!");
			fflush(stdout);
#endif
			return;
		}
	}	// end WHILE(1)

}	// end parse FUNCTION
