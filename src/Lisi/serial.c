/*
 * % By Giuseppe Lisi for Politecnico di Milano
 * % beppelisi@gmail.com
 * % 8 June 2010
 */

#include <sys/time.h>
#include <sys/types.h>
#include <stdio.h>   /* Standard input/output definitions */
#include <string.h>  /* String function definitions */
#include <unistd.h>  /* UNIX standard function definitions */
#include <fcntl.h>   /* File control definitions */
#include <errno.h>   /* Error number definitions */
#include <termios.h> /* POSIX terminal control definitions*/
#include <stdlib.h>A.5. Serial Communication with the EMG Board xxxi
#include <string.h>
#include <sys/types.h>
#include <sys/dir.h>

int open input source(char *);

void handle input from source(int, FILE*, FILE*, FILE*,
        FILE*, int*, int*, int*, char*);

void handle input from source2(int, int, FILE*, FILE*, FILE*,
        FILE*);

int MAX(int, int);

main(int argc, char* argv[]){
    
    if (argc == 5) {
        
        /*
  fd1: input source 1 is for the standard input
  fd2: input source 2 is for the EMG channel input
         */
        int    fd1, fd2;
        
        /*destination files*/
        FILE *df, *df1, *df2, *df3;
        
        /* file descriptor set */
        fd set readfs;
        
        /* maximum file desciptor used */
        int    maxfd;
        
        /* loop while TRUE */
        int    loop=1;
        
        int    res;
        struct timeval Timeout;
        
        /*line started*/
        int ls=0;
        
        int current=0;
        char line[800];
        int flagStart=0;
        char * file;
        int result code;
        
        xxxii Appendix A. The Implementation of the Project
                chdir("serial");
        
        mode t process mask = umask(0);
        
        result code = mkdir(argv[1], S IRWXU | S IRWXG |
                S IRWXO);
        
        chdir(argv[1]);
        umask(process mask);
        
        file = malloc(sizeof(char) *
                ((strlen(argv[2])+strlen(argv[4])) + 6));
        
        strcpy(file, argv[3]);
        strcat(file, "-");
        strcat(file, argv[4]);
        strcat(file, "-");
        strcat(file, argv[2]);
        strcat(file, ".txt");
        
        /*
  Creates the directories ch1, ch2 and ch3 with the
  relative img folders
         */
        
        result code =
                mkdir("ch1", S IRWXU | S IRWXG | S IRWXO);
        
        chdir("ch1");
        
        result code =
                mkdir("img", S IRWXU | S IRWXG | S IRWXO);
        
        umask(process mask);
        df1 = fopen(file, "w");
        
        if(df1==NULL) {
            printf
                    ("Error: can't create file for writing first channel.\n");
            exit(0);
        }
        
        chdir("..");
        
        result code =
                mkdir("ch2", S IRWXU | S IRWXG | S IRWXO);
        
        chdir("ch2");
        A.5. Serial Communication with the EMG Board xxxiii
                result code =
                mkdir("img", S IRWXU | S IRWXG | S IRWXO);
        
        umask(process mask);
        df2 = fopen(file, "w");
        
        if(df2==NULL) {
            printf
                    ("Error: can't create file for writing second channel.\n");
            exit(0);
        }
        
        chdir("..");
        
        result code =
                mkdir("ch3", S IRWXU | S IRWXG | S IRWXO);
        
        chdir("ch3");
        
        result code =
                mkdir("img", S IRWXU | S IRWXG | S IRWXO);
        
        umask(process mask);
        df3 = fopen(file, "w");
        
        if(df3==NULL) {
            printf
                    ("Error: can't create file for writing third channe.\n");
            exit(0);
        }
        
        /* SERIAL */
        fd1 = open input source("/dev/tty.usbserial-A2003H2n");
        if (fd1<0) exit(0);
        fcntl(fd1, F SETFL, 0);
        struct termios options;
        
        /*
         * Get the current options for the port
         */
        
        tcgetattr(fd1, &options);
        
        /*
         * Set the baud rates
         */
        
        cfsetispeed(&options, B57600);
        cfsetospeed(&options, B57600);xxxiv Appendix A. The Implementation of the Project
                
                /*
                 * Enable the receiver and set local mode
                 */
                
                options.c cflag |= (CLOCAL | CREAD);
        
        /*
         * Set the new options for the port
         */
        
        tcsetattr(fd1, TCSANOW, &options);
        
        /* STANDARD INPUT */
        fd2 =0;
        if (fd2<0) exit(0);
        
        /* maximum bit entry (fd) to test */
        maxfd = max(fd1, fd2)+1;
        
        
        /* loop for input */
        while (loop) {
            
            // set timeout value within input loop
            Timeout.tv usec = 0;  // milliseconds
            Timeout.tv sec  = 3;  // seconds
            
            /* set testing for source 1 */
            FD SET(fd1, &readfs);
            
            /* set testing for source 2 */
            FD SET(fd2, &readfs);
            
            /* block until input becomes available */
            res = select(maxfd, &readfs, NULL, NULL, &Timeout);
            
            //number of file descriptors with input = 0,
            //timeout occurred.
            if (res == 0) {
                printf("Timeout occured\n");
                exit(1);
            }
            /* input from source 1 available */
            if (FD ISSET(fd1, &readfs))
                handle input from source
                        (fd1, df, df1, df2, df3, &flagStart, &ls, &current, line);
            
            /* input from source 2 available */A.5. Serial Communication with the EMG Board xxxv
                    if (FD ISSET(fd2, &readfs))
                        handle input from source2(fd1, fd2, df, df1, df2, df3);
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

/*
 */
int open input source(char * port) {
    int fd = 0;
    
    /* open the device to be non-blocking (read will
  return immediatly) */
    fd = open(port, O RDWR | O NOCTTY | O NONBLOCK);
    if (fd <0) {
        perror(port);
        return -1;
    }
    else
        return fd;
}

void handle input from source(int fd, FILE *df, FILE *df1,
        FILE *df2, FILE *df3, int *flagStart, int *ls, int *current,
        char *line) {
    int res = 0, i;
    char buf[255];
    char ret='\r';
    int d1, d2, d3;
    res = read(fd, buf, 255);
    buf[res]=0;
    
    /*Parsing of the data coming from the EMG board*/
    
    for (i = 0; i < res; i++){
        
        if(*flagStart==0 && buf[i]=='I'){
            *flagStart=1;xxxvi Appendix A. The Implementation of the Project
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

void handle input from source2
        (int fd1, int fd2, FILE *df, FILE *df1, FILE *df2, FILE *df3) {
    fclose(df1);
    fclose(df2);
    fclose(df3);
    close(fd1);
    close(fd2);
    exit(0);
}

int max(int i1, int i2) {
    if (i1 > i2)
        return i1;
    else
        return i2;
}
