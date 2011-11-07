1 /*
2 % By Giuseppe Lisi for Politecnico di Milano
3 % beppelisi@gmail.com
4 % 8 June 2010
5 */
6
7 #include <sys/time.h>
8 #include <sys/types.h>
9 #include <stdio.h>   /* Standard input/output definitions */
10 #include <string.h>  /* String function definitions */
11 #include <unistd.h>  /* UNIX standard function definitions */
12 #include <fcntl.h>   /* File control definitions */
13 #include <errno.h>   /* Error number definitions */
14 #include <termios.h> /* POSIX terminal control definitions*/
15 #include <stdlib.h>A.5. Serial Communication with the EMG Board xxxi
16 #include <string.h>
17 #include <sys/types.h>
18 #include <sys/dir.h>
19
20 int open input source(char *);
21
22 void handle input from source(int,FILE*,FILE*,FILE*,
23 FILE*,int*,int*,int*,char*);
24
25 void handle input from source2(int,int,FILE*,FILE*,FILE*,
26 FILE*);
27
28 int MAX(int, int);
29
30 main(int argc, char* argv[]){
31
32 if (argc == 5) {
33
34 /*
35 fd1: input source 1 is for the standard input
36 fd2: input source 2 is for the EMG channel input
37 */
38 int    fd1, fd2;
39
40 /*destination files*/
41 FILE *df,*df1,*df2,*df3;
42
43 /* file descriptor set */
44 fd set readfs;
45
46 /* maximum file desciptor used */
47 int    maxfd;
48
49 /* loop while TRUE */
50 int    loop=1;
51
52 int    res;
53 struct timeval Timeout;
54
55 /*line started*/
56 int ls=0;
57
58 int current=0;
59 char line[800];
60 int flagStart=0;
61 char * file;
62 int result code;
63
64xxxii Appendix A. The Implementation of the Project
65 chdir("serial");
66
67 mode t process mask = umask(0);
68
69 result code = mkdir(argv[1], S IRWXU | S IRWXG |
70 S IRWXO);
71
72 chdir(argv[1]);
73 umask(process mask);
74
75 file = malloc(sizeof(char) *
76 ((strlen(argv[2])+strlen(argv[4])) + 6));
77
78 strcpy(file,argv[3]);
79 strcat(file,"-");
80 strcat(file,argv[4]);
81 strcat(file,"-");
82 strcat(file,argv[2]);
83 strcat(file,".txt");
84
85 /*
86 Creates the directories ch1, ch2 and ch3 with the
87 relative img folders
88 */
89
90 result code =
91 mkdir("ch1", S IRWXU | S IRWXG | S IRWXO);
92
93 chdir("ch1");
94
95 result code =
96 mkdir("img", S IRWXU | S IRWXG | S IRWXO);
97
98 umask(process mask);
99 df1 = fopen(file, "w");
100
101 if(df1==NULL) {
102 printf
103 ("Error: can't create file for writing first channel.\n");
104 exit(0);
105 }
106
107 chdir("..");
108
109 result code =
110 mkdir("ch2", S IRWXU | S IRWXG | S IRWXO);
111
112 chdir("ch2");
113A.5. Serial Communication with the EMG Board xxxiii
114 result code =
115 mkdir("img", S IRWXU | S IRWXG | S IRWXO);
116
117 umask(process mask);
118 df2 = fopen(file, "w");
119
120 if(df2==NULL) {
121 printf
122 ("Error: can't create file for writing second channel.\n");
123 exit(0);
124 }
125
126 chdir("..");
127
128 result code =
129 mkdir("ch3", S IRWXU | S IRWXG | S IRWXO);
130
131 chdir("ch3");
132
133 result code =
134 mkdir("img", S IRWXU | S IRWXG | S IRWXO);
135
136 umask(process mask);
137 df3 = fopen(file, "w");
138
139 if(df3==NULL) {
140 printf
141 ("Error: can't create file for writing third channe.\n");
142 exit(0);
143 }
144
145 /* SERIAL */
146 fd1 = open input source("/dev/tty.usbserial-A2003H2n");
147 if (fd1<0) exit(0);
148 fcntl(fd1, F SETFL, 0);
149 struct termios options;
150
151 /*
152 * Get the current options for the port
153 */
154
155 tcgetattr(fd1, &options);
156
157 /*
158 * Set the baud rates
159 */
160
161 cfsetispeed(&options, B57600);
162 cfsetospeed(&options, B57600);xxxiv Appendix A. The Implementation of the Project
163
164 /*
165 * Enable the receiver and set local mode
166 */
167
168 options.c cflag |= (CLOCAL | CREAD);
169
170 /*
171 * Set the new options for the port
172 */
173
174 tcsetattr(fd1, TCSANOW, &options);
175
176 /* STANDARD INPUT */
177 fd2 =0;
178 if (fd2<0) exit(0);
179
180 /* maximum bit entry (fd) to test */
181 maxfd = max (fd1, fd2)+1;
182
183
184 /* loop for input */
185 while (loop) {
186
187 // set timeout value within input loop
188 Timeout.tv usec = 0;  // milliseconds
189 Timeout.tv sec  = 3;  // seconds
190
191 /* set testing for source 1 */
192 FD SET(fd1, &readfs);
193
194 /* set testing for source 2 */
195 FD SET(fd2, &readfs);
196
197 /* block until input becomes available */
198 res = select(maxfd, &readfs, NULL, NULL, &Timeout);
199
200 //number of file descriptors with input = 0,
201 //timeout occurred.
202 if (res == 0) {
203 printf("Timeout occured\n");
204 exit(1);
205 }
206 /* input from source 1 available */
207 if (FD ISSET(fd1, &readfs))
208 handle input from source
209 (fd1,df,df1,df2,df3,&flagStart,&ls,&current,line);
210
211 /* input from source 2 available */A.5. Serial Communication with the EMG Board xxxv
212 if (FD ISSET(fd2, &readfs))
213 handle input from source2(fd1,fd2,df,df1,df2,df3);
214 }
215 }
216
217 else{
218 printf("Provide in order:\n");
219 printf("1) the name of the person \n");
220 printf("2) the movement done \n");
221 printf("3) the wanted movement identificator(int)\n");
222 printf("4) the progressive number of the movement\n");
223
224 }
225 }
226
227 /*
228 */
229 int open input source(char * port)
230 {
231 int fd = 0;
232
233 /* open the device to be non-blocking (read will
234 return immediatly) */
235 fd = open(port, O RDWR | O NOCTTY | O NONBLOCK);
236 if (fd <0) {
237 perror(port);
238 return -1;
239 }
240 else
241 return fd;
242 }
243
244 void handle input from source(int fd,FILE *df,FILE *df1,
245 FILE *df2,FILE *df3,int *flagStart,int *ls,int *current,
246 char *line)
247 {
248 int res = 0, i;
249 char buf[255];
250 char ret='\r';
251 int d1,d2,d3;
252 res = read(fd,buf,255);
253 buf[res]=0;
254
255 /*Parsing of the data coming from the EMG board*/
256
257 for (i = 0; i < res; i++){
258
259 if(*flagStart==0 && buf[i]=='I'){
260 *flagStart=1;xxxvi Appendix A. The Implementation of the Project
261 }
262
263 if(*flagStart==1){
264 if(buf[i]=='D' && *ls==0){
265 *ls=1;
266 *current=0;
267
268 }
269 else if(*ls==1){
270 line[*current]=buf[i];
271 *current=*current+1;
272 }
273 if(buf[i]=='\r' && *ls==1){
274 *ls=0;
275 *current=0;
276
277 sscanf(line,":%d %d %d",&d1,&d2,&d3);
278 printf("%d %d %d\n",d1,d2,d3);
279
280
281 fprintf(df1,"%d\r",d1);
282 fprintf(df2,"%d\r",d2);
283 fprintf(df3,"%d\r",d3);
284 }
285 }
286 }
287 }
288
289 void handle input from source2
290 (int fd1,int fd2, FILE *df,FILE *df1,FILE *df2,FILE *df3)
291 {
292 fclose(df1);
293 fclose(df2);
294 fclose(df3);
295 close(fd1);
296 close(fd2);
297 exit(0);
298 }
299
300 int max(int i1, int i2)
301 {
302 if (i1 > i2)
303 return i1;
304 else
305 return i2;
306 }