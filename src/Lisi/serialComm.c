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
#include <unistd.h>

#ifdef _WIN32
#include <windows.h>
#else
// linux headers here
#endif

#define HELPTXT "help text\n    -v:		verbose\n"

#define APPNAME "serialManager"
#define MBOX(txt) MessageBox(NULL, TEXT(txt), TEXT(APPNAME), MB_OK );
#define N_ACQ 10	// #acquisitions
#define N 100

int main (int argc, char *argv[]){

	HANDLE hSer;	// handle serial port
	char rBuff[N + 1] = {'0'};
	DWORD dwBytesRead = 0;

	// options
	char verb = 0;	// verbose


	// options parsing
	int c;
	while ((c = getopt (argc, argv, "hv")) != -1) {
		switch(c) {
		case 'h':
			printf(HELPTXT);
			return 0;
		case 'v':
			verb = 1;
			break;
		case '?':
			printf(HELPTXT);
			return 0;
		}
	}



	// opening port
	hSer = CreateFile("COM6",	//FIXME: find right port
			GENERIC_READ | GENERIC_WRITE,
			0,
			0,
			OPEN_EXISTING,
			FILE_ATTRIBUTE_NORMAL,
			0);

	if(hSer == INVALID_HANDLE_VALUE) {
		if(GetLastError() == ERROR_FILE_NOT_FOUND) {
			MBOX("Wrong Port");
			fprintf(stderr, "Wrong Port");
		}
		else {
			MBOX("An error occurred");
			fprintf(stderr, "An error occurred");
		}
		exit(-1);
	}

	DCB dcbPars = {0};
	dcbPars.DCBlength = sizeof(dcbPars);

	if (!GetCommState(hSer, &dcbPars)) {
		MBOX("error getting state");
		fprintf(stderr, "error getting state");
	}

	dcbPars.BaudRate = CBR_57600;
	//dcbPars.ByteSize = 8;
	//dcbPars.StopBits = ONESTOPBIT;
	//dcbPars.Parity = NOPARITY;

	if(!SetCommState(hSer, &dcbPars)) {
		MBOX("Error setting serial port state");
		fprintf(stderr, "Error setting serial port state");
	}

	COMMTIMEOUTS timeouts={0};
	timeouts.ReadIntervalTimeout=50;
	timeouts.ReadTotalTimeoutConstant=50;
	timeouts.ReadTotalTimeoutMultiplier=10;
	timeouts.WriteTotalTimeoutConstant=50;
	timeouts.WriteTotalTimeoutMultiplier=10;

	if(!SetCommTimeouts(hSer, &timeouts)) {
		MBOX("Error occurred setting timeouts");
		fprintf(stderr, "Error occurred setting timeouts");
	}

	if(verb)
		printf("Serial port opened\n");

	PurgeComm(hSer,
			PURGE_TXABORT | PURGE_RXABORT | PURGE_TXCLEAR | PURGE_RXCLEAR);

// ******************** acquisition part ********************
	while(ReadFile(hSer, rBuff, sizeof(rBuff), &dwBytesRead, NULL))	// FIXME: eventually use N instead of sizeof()
		printf("%s",rBuff);

	fprintf(stderr, "Error occurred reading");

	/*
	 * - fare test per vedere se è più veloce il programma a leggere o la board a
	 * scrivere (stempa BytesRead)
	 * - Vedere come funziona la board, in modo da capire un po' come va fatto il
	 * parsing.
	 */

	CloseHandle(hSer);
	return 0;
}
