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

#ifdef _WIN32
#include <windows.h>
#else
// linux headers here
#endif

#define _PARSEDEBUG

#define APPNAME "serialManager"
#define ERRBOX(txt) MessageBox(NULL, TEXT(txt), TEXT(APPNAME), MB_ICONERROR | MB_OK )	// find a way to make this box non-blocking
#define WARNBOX(txt) MessageBox(NULL, TEXT(txt), TEXT(APPNAME), MB_ICONWARNING | MB_OK )
#define N_ACQ 10	// #acquisitions
#define N 500
#define N_WARN N*4/5

void parse(char buff[], DWORD* bRead, char ch1[], char ch2[], char ch3[], DWORD* pars, char *startedFlag, char remBuff[], int *rem);

int main (int argc, char *argv[]){

	char HELPTXT[] =  "help text\n"
			"	-h:		print help"
			"	-v:		verbose\n"
			"	-d: 	input port (default: COM6 of TTY...)\n"
			"	-n:		# of interactive acquisitions\n"
			"	-p:		root path to save data files\n";

	HANDLE hSer;	// handle serial port
	char rBuff[N] = {'0'};	// read buffer
	DWORD bytesRead = 0;

	// usually 17 chars are enough for a complete data. Make it 25 to be sure.
	char remBuff[25];
	int rem = 0;	// #char of incomplete data set left from last scan

	char startedFlag;

	char ch1[N+1] = {'0'};
	char ch2[N+1] = {'0'};
	char ch3[N+1] = {'0'};
	DWORD parsed = 0;	// # parsed bytes


	// options
	char verb = 0;	// verbose
	char *port = "COM6";	// FIXME: default port name (my default port is COM6)
	int nAcq = 0;


	// options parsing
	int c;
	while ((c = getopt (argc, argv, "dhv")) != -1) {
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
		case 'n':
			nAcq = (int)*optarg;
			break;
		case '?':
			printf("Unknown option '-%c'\nSee help for more info\n", optopt);
			return 0;
		default:
			abort();
		}
	}



	// opening port
	hSer = CreateFile(port,
			GENERIC_READ | GENERIC_WRITE,
			0,
			NULL,
			OPEN_EXISTING,
			0, //FILE_ATTRIBUTE_NORMAL,
			NULL);

	if(hSer == INVALID_HANDLE_VALUE) {
		if(GetLastError() == ERROR_FILE_NOT_FOUND) {
			printf("Wrong Port");
			//ERRBOX("Wrong Port");
		}
		else {
			printf("An error occurred");
			//ERRBOX("An error occurred");
		}
		exit(-1);
	}

	DCB dcbPars;// = {0};
	dcbPars.DCBlength = sizeof(dcbPars);

	if (!GetCommState(hSer, &dcbPars)) {
		fprintf(stderr, "error getting state");
		ERRBOX("error getting state");
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
	timeouts.ReadIntervalTimeout = 50;
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

	PurgeComm(hSer, PURGE_TXABORT | PURGE_RXABORT |
			PURGE_TXCLEAR | PURGE_RXCLEAR);

	// ******************** acquisition part ********************
	while(ReadFile(hSer, rBuff, sizeof(rBuff), &bytesRead, NULL)) {	// FIXME: eventually use N instead of sizeof()?
#ifdef _PARSEDEBUG
		printf("\n---\nBYTES RED: %d\n---\n", (int)bytesRead);
#endif

		// managing input
		parse(rBuff, &bytesRead, ch1, ch2, ch3, &parsed, &startedFlag, remBuff, &rem);

		if(bytesRead == N_WARN) { // EMGBoard outputs almost 8KB/sec
			printf(	"------------------------------------"
					"-----------------------------------\n"
					"WARNING: application too slow or buffer"
					" size too small for the EMGBoard\n"
					"------------------------------------"
					"-----------------------------------\n");
			fflush(stdout);

		}
	}	// end parsing WHILE

	CloseHandle(hSer);
	return 0;
}	// end MAIN


void parse(char buff[], DWORD* bRead, char ch1[], char ch2[], char ch3[], DWORD* pars, char *startedFlag, char remBuff[], int *rem){
	int j, i=0;

	int v1, v2, v3;

#ifdef _PARSEDEBUG
	printf("PARSE FUNCT: I'm alive!\n");
#endif

	while(i<(int)(*bRead) && buff[i]!='D' && buff[i]!='I'){i++;};

	if(i==(int)(*bRead)) {	// add to remBuffer
		memcpy(remBuff+(*rem), buff, (int)(*bRead));
		*rem += (int)(*bRead);
		return;
	}

	if(*rem) {	// managing remaining chunk from previous acq
		memcpy(remBuff+(*rem), buff, i);

		// TODO: do stuff
		v1 = atoi(remBuff+2);	// pointing to the first number
		j=3;
		while(remBuff[j++]!=' '); // looking for second number
		v2 = atoi(remBuff+j);
		while(remBuff[j++]!=' '); // looking for third number
		v3 = atoi(remBuff+j);

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
		printf(" this D in %d, next in %d (%d)\n", i, j, (int)(*bRead));
#endif

		if(j<((int)(*bRead))){	// found next 'D'

			i = i+2;	// pointing to the first number
			v1 = atoi(buff+i);
			while(buff[i++]!=' '); // looking for second number
			v2 = atoi(buff+i);
			while(buff[i++]!=' '); // looking for third number
			v3 = atoi(buff+i);

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
			if ((int)(*bRead)!=N)	// if this error occurs, probably bRead was overwritten by an buffOverflow somewhere
				ERRBOX("DAMN!");
			fflush(stdout);
#endif
			return;
		}
	}	// end WHILE(1)

}	// end parse FUNCTION
