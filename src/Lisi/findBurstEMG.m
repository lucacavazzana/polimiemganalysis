1 %% FindBurstEMG
2 % Function to find the edges of each burst
3 %
4 % By Giuseppe Lisi for Politecnico di Milano
5 % beppelisi@gmail.com
6 % 8 June 2010
7 %% Inputs
8 % signal1: is the liear envelope of the signal coming from
9 % Channel 1.
10 %
11 % signal2: is the liear envelope of the signal coming from
12 % Channel 2.
13 %
14 % signal3: is the liear envelope of the signal coming from
15 % Channel 3.
16 %
17 % debug=1: to pause the segmentation phase and plot the figures
18 % of each segemented signal. Debug mode
19 %
20 % ch2=1: if the second channel is used.
21 %
22 % ch3=1: if the third channel is used.
23 %% Outputs
24 % secondDivision: vector containing all the ending edges of the
25 % bursts
26 %xiv Appendix A. The Implementation of the Project
27 % firstDivision: vector conaining all the starting edges of the
28 % bursts
29 %%
30 function [firstDivision,secondDivision]=...
31 findBurstEMG(signal1,signal2,signal3,debug,ch2,ch3)
32
33 ls=length(signal1); %length of the signal
34 firstDivision=[];
35 secondDivision=[];
36
37 %54 samples correspond to 0.2 seconds of signal(sampling rate
38 % 270Samp/Sec) normal burst duration corresponding to 1second
39 sampleDur=54*5;
40
41 %normal movement
42 delay=40;
43
44 %short movement
45 %delay=20;
46
47 %the lower level under which it is impossible to start a burst
48 cost=10;
49
50 %factor for which the initial part of the moving average is
51 %computed in order to avoid fake initial bursts
52 mult=30;
53
54
55 %once the burst has been detected its edges have to be shifted
56 %back of this value
57 back=100;
58
59 % contain the value of the next ending edge. Equal to 1 if the
60 % start still have to be found
61 next1=1;
62 next2=1;
63 next3=1;
64
65 %sum for the threshold computation.
66 sum1=signal1(1)*mult;
67 sum2=signal2(1)*mult;
68 sum3=signal3(1)*mult;
69
70 %threshold for the three channels
71 thr1(1)=sum1;
72 thr2(1)=sum2;
73 thr3(1)=sum3;
74
75 % records the highest value found so far in all the threeA.2. Arti?cial Neural Network Training xv
76 % channels
77 max=0;
78
79 %1 if first channel, 2 if second 3 if third
80 choice=0;
81
82 %restart=1 if the system is ready to detect a new burst
83 restart=0;
84
85 % empiric values for the decision to take about the burst
86 % start.
87 perc=22/100;
88 clos=1/20;
89
90 % burst edges detection
91 for i=2:ls
92
93 sum1=sum1+signal1(i);
94 thr1(i)=sum1/i;
95 sum2=sum2+signal2(i);
96 thr2(i)=sum2/i;
97 sum3=sum3+signal3(i);
98 thr3(i)=sum3/i;
99
100 if(signal1(i)?thr1(i)+perc*thr1(i) &&...
101 next1==1 && i>restart && signal1(i)>cost)
102 % prev contains the starting point of the edge.
103 prev1=i;
104 if(prev1-back>1)
105 prev1=prev1-back;
106 if(prev1+sampleDur<ls)
107 next1=prev1+sampleDur;
108 else
109 next1=1;
110 end
111 else
112 prev1=1;
113 next1=1+sampleDur;
114 end
115 end
116
117 if(i==next1)
118 %if the signal is still high -> delay the closing
119 %of the burst
120 if(signal1(i)>thr1(i)-clos*thr1(i))
121 if(next1+delay<ls)
122 next1=next1+delay;
123 else
124 next1=ls;xvi Appendix A. The Implementation of the Project
125 end
126 else
127 if(choice==1)
128
129 firstDivision=[firstDivision prev1];
130 secondDivision=[secondDivision next1];
131 max=0;
132 choice1=0;
133 restart=next1+back;
134 next1=1;
135 next2=1;
136 next3=1;
137 end
138 end
139 end
140
141 if(ch2)
142 if(signal2(i)?thr2(i)+perc*thr2(i) && next2==1 &&...
143 i>restart && signal2(i)>cost)
144
145 prev2=i;
146 if(prev2-back>1)
147 prev2=prev2-back;
148
149 if(prev2+sampleDur<ls)
150 next2=prev2+sampleDur;
151 else
152 next2=1;
153 end
154 else
155 prev2=1;
156 next2=1+sampleDur;
157 end
158 end
159 if(i==next2)
160 %if the signal is still high delay -> the closing
161 %of the burst
162 if(signal2(i)>thr2(i)-clos*thr2(i))
163 if(next2+delay<ls)
164 next2=next2+delay;
165 else
166 next2=ls;
167 end
168 else
169
170 if(choice==2)
171 firstDivision=[firstDivision prev2];
172 secondDivision=[secondDivision next2];
173 max=0;A.2. Arti?cial Neural Network Training xvii
174 choice2=0;
175 restart=next2+back;
176 next1=1;
177 next2=1;
178 next3=1;
179 end
180 end
181 end
182 end
183
184 if(ch3)
185 if(signal3(i)?thr3(i)+perc*thr3(i) && next3==1 &&...
186 i>restart && signal3(i)>cost)
187
188 prev3=i;
189
190 if(prev3-back>1)
191 prev3=prev3-back;
192 if(prev3+sampleDur<ls)
193 next3=prev3+sampleDur;
194 else
195 next3=1;
196 end
197 else
198 prev3=1;
199 next3=1+sampleDur;
200 end
201 end
202
203 if(i==next3)
204 %if the signal is still high -> delay the
205 %closing of the burst
206 if(signal3(i)>thr3(i)-clos*thr3(i))
207 if(next3+delay<ls)
208 next3=next3+delay;
209 else
210 next3=ls;
211 end
212 else
213
214 if(choice==3)
215 firstDivision=[firstDivision prev3];
216 secondDivision=[secondDivision next3];
217 max=0;
218 choice3=0;
219 restart=next3+back;
220 next1=1;
221 next2=1;
222 next3=1;xviii Appendix A. The Implementation of the Project
223 end
224 end
225 end
226 end
227
228 if signal1(i)>max && signal1(i)?thr1(i)+perc*thr1(i)
229 max=signal1(i);
230 choice=1;
231 end
232 if signal2(i)>max && ch2 && signal2(i)?thr2(i)+...
233 perc*thr2(i)
234 max=signal2(i);
235 choice=2;
236 end
237 if signal3(i)>max && ch3 && signal3(i)?thr3(i)+...
238 perc*thr3(i)
239 max=signal3(i);
240 choice=3;
241 end
242 end
243
244
245 % if there a burst start has been detected, but not the end,
246 % eliminate the
247 % burst
248 if(¬isempty(firstDivision) && ...
249 length(firstDivision)>length(secondDivision))
250 firstDivision=firstDivision(1:length(secondDivision));
251 end