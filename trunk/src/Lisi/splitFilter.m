1 %% Split Filter
2 % This script is used to split the incoming signal and to
3 % filter it.
4 %
5 % By Giuseppe Lisi for Politecnico di Milanoviii Appendix A. The Implementation of the Project
6 % beppelisi@gmail.com
7 % 8 June 2010
8 %% Inputs
9 % c: is the cell array containing all the signals in matlab
10 % format.
11 %
12 % debug=1: to pause the segmentation phase and plot the figures
13 % of each segemented signal. Debug mode
14 %
15 % acq=1: if the script is used during the acquisition phase
16 %
17 % np: (name of the person) is the name of the folder in which
18 % are contained the training data.
19 %
20 % i: is the index representing the current single signal to
21 % process.
22 %
23 % plotting=1: to save the figures of the segmented signals
24 % inside the 'img'folder contained inside the np folder.
25 % 'img' is automatically created.
26 %
27 % ch2=1: if the second channel is used.
28 %
29 % ch3=1: if the third channel is used.
30 %% Outputs
31 % f: is the cell array containing all the feature vector
32 % related to the signal contained in c at the position i.
33 %%
34 function f=splitFilter(c,debug,acq,plotting,i,np,ch2,ch3)
35
36 c1=c{i,1};
37 c2=c{i,2};
38 c3=c{i,3};
39 nsamp=c{i,4};
40
41 % Rectification
42 y1=abs(c1-512);
43 y2=abs(c2-512);
44 y3=abs(c3-512);
45
46 f=[];
47 f1=[];
48 f2=[];
49 f3=[];
50
51 %Linear envelope
52 if(length(y1)6= 1)
53
54 freqCamp=270; %sampling frequencyA.2. Arti?cial Neural Network Training ix
55 cutOffFreq=2; %cutoff frequency of the low-pass filter
56 nyquistFreq=cutOffFreq/(freqCamp/2);
57 [b,a]=butter(2,nyquistFreq);
58 %filt is the envelope of the rectified signal
59 filt1=filter(b,a,y1);
60 filt1=filt1(50:length(filt1));
61
62
63 filt2=filter(b,a,y2);
64 filt2=filt2(50:length(filt2));
65
66
67 filt3=filter(b,a,y3);
68 filt3=filt3(50:length(filt3));
69
70
71
72 % find the edges of each burst
73 [firstDiv,secondDiv]...
74 =findBurstEMG(filt1,filt2,filt3,debug,ch2,ch3);
75
76
77 %Filtering above 10 Hz
78 cutoffF1=10;
79 nyquistF=cutoffF1/(freqCamp/2);
80 [num,den] = butter(2,nyquistF,'high');
81 filtS=filter(num,den,c1);
82 filtSign=filtS(50:length(filtS));
83
84 filtS2=filter(num,den,c2);
85 filtSign2=filtS2(50:length(filtS2));
86
87 filtS3=filter(num,den,c3);
88 filtSign3=filtS3(50:length(filtS3));
89
90 % the feature extraction is not performed during the
91 % acquisition phase.
92 if(¬acq)
93
94 for j=1:length(firstDiv)
95 f1(j,:)=...
96 extractFeatures(filtSign(firstDiv(j):secondDiv(j)));
97 end
98
99
100 if ch2
101 for j=1:length(firstDiv)
102 f2(j,:)=...
103 extractFeatures(filtSign2(firstDiv(j):secondDiv(j)));x Appendix A. The Implementation of the Project
104 end
105 end
106
107 if ch3
108 for j=1:length(firstDiv)
109 f3(j,:)=...
110 extractFeatures(filtSign3(firstDiv(j):secondDiv(j)));
111 end
112 end
113
114 if(¬isempty(firstDiv))
115
116 f=[f1 f2 f3];
117 end
118
119 end
120
121 sum1=filt1(1)*100;
122 sum2=filt2(1)*100;
123 sum3=filt3(1)*100;
124 thr1(1)=sum1;
125 thr2(1)=sum2;
126 thr3(1)=sum3;
127 % computing the 'splitting threshold' in order to plot it
128 for i=2:length(filt1)
129 sum1=sum1+filt1(i);
130 thr1(i)=sum1/i;
131 sum2=sum2+filt2(i);
132 thr2(i)=sum2/i;
133 sum3=sum3+filt3(i);
134 thr3(i)=sum3/i;
135 end
136
137
138
139 if debug
140 % Plots the segmentation of the envelope of the first
141 % channel.
142 figure;
143 plot(1:length(filt1),filt1)
144 hold on;
145 plot(1:length(thr1),thr1,'y');
146 axis([1 length(filt1) 0 150]);
147 if(¬isempty(firstDiv))
148 vline(firstDiv,'g','');
149 vline(secondDiv,'r','');
150
151 end
152 % Plots the segmentation of the envelope of the secondA.2. Arti?cial Neural Network Training xi
153 % channel.
154 figure;
155 plot(1:length(filt2),filt2)
156 hold on;
157 plot(1:length(thr2),thr2,'y');
158 axis([0 length(filt2) 0 150]);
159 if(¬isempty(firstDiv))
160 vline(firstDiv,'g','');
161 vline(secondDiv,'r','');
162
163 end
164
165 % Plots the segmentation of the envelope of the third
166 % channel.
167 figure;
168 plot(1:length(filt3),filt3)
169 hold on;
170 plot(1:length(thr3),thr3,'y');
171 axis([0 length(filt3) 0 150]);
172 if(¬isempty(firstDiv))
173 vline(firstDiv,'g','');
174 vline(secondDiv,'r','');
175 end
176
177 % Plots the segmented and high-pass filtered signal of
178 % Channel 1.
179 figure;
180 plot(1:length(filtSign),filtSign);
181 axis([1 length(filtSign) -400 400]);
182 if(¬isempty(firstDiv))
183 vline(firstDiv,'g','');
184 vline(secondDiv,'r','');
185 end
186
187 % Plots the segmented and high-pass filtered signal of
188 % Channel 2.
189 if ch2
190 figure;
191 plot(1:length(filtSign2),filtSign2);
192 axis([0 length(filtSign2) -400 400]);
193 if(¬isempty(firstDiv))
194 vline(firstDiv,'g','');
195 vline(secondDiv,'r','');
196 end
197 end
198
199 % Plots the segmented and high-pass filtered signal of
200 % Channel 3.
201 if ch3xii Appendix A. The Implementation of the Project
202 figure;
203 plot(1:length(filtSign3),filtSign3);
204 axis([0 length(filtSign3) -400 400]);
205 if(¬isempty(firstDiv))
206 vline(firstDiv,'g','');
207 vline(secondDiv,'r','');
208 end
209 end
210 numberOFMovements=length(firstDiv)
211 if(¬acq)
212 ginput(1);
213 close all;
214 end
215
216
217 end
218
219 % saving the figures of the fitered and segmented signal
220 % into the 'img' folder
221 if plotting
222 file2save=['/Users/giuseppelisi/University/Thesis/'...
223 'Matlab/FilesNewEmg/serial/' np '/ch1/img/image'...
224 sprintf('%d',nsamp) ' ' sprintf('%d',i) '.eps'];
225 fig = figure('visible','off');
226 plot(1:length(filtSign),filtSign,'b');
227 axis([0 length(filtSign) -400 400]);
228 if(¬isempty(firstDiv))
229 vline(firstDiv,'g','');
230 vline(secondDiv,'r','');
231 end
232 saveas(fig,file2save,'eps');
233
234 if ch2
235 file2save=['/Users/giuseppelisi/University/Thesis/'...
236 'Matlab/FilesNewEmg/serial/' np '/ch2/img/image'...
237 sprintf('%d',nsamp) ' ' sprintf('%d',i) '.eps'];
238 fig = figure('visible','off');
239 plot(1:length(filtSign2),filtSign2,'b');
240 axis([0 length(filtSign2) -400 400]);
241 if(¬isempty(firstDiv))
242 vline(firstDiv,'g','');
243 vline(secondDiv,'r','');
244 end
245 saveas(fig,file2save,'eps');
246 end
247
248
249 if ch3
250 file2save=['/Users/giuseppelisi/University/Thesis/'...A.2. Arti?cial Neural Network Training xiii
251 'Matlab/FilesNewEmg/serial/' np '/ch3/img/image'...
252 sprintf('%d',nsamp) ' ' sprintf('%d',i) '.eps'];
253 fig = figure('visible','off');
254 plot(1:length(filtSign3),filtSign3);
255 axis([0 length(filtSign3) -400 400]);
256 if(¬isempty(firstDiv))
257 vline(firstDiv,'g','');
258 vline(secondDiv,'r','');
259 end
260 saveas(fig,file2save,'eps');
261 end
262 end
263
264
265
266 end
267 end