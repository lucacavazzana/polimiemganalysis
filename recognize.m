1 %% Recognize
2 % this script recognizes new movements, acquired at the moment.
3 % It uses a trained ANN
4 %
5 % By Giuseppe Lisi for Politecnico di Milano
6 % beppelisi@gmail.com
7 % 8 June 2010
8
9 %% Inputs
10 % net: is the trained ANN used for the recognition
11 %
12 % mov: is the number of movement types on which the ANN has
13 % been trained.
14
15 %% Outputs
16 %%
17 function recognize(net,ch2,ch3,mov)
18
19 close all;
20 comm=['./serialComm recognize 1 1 1']
21 [status,result] = unix(comm,'-echo');
22 c = cell(1, 4);
23
24 file=['/Users/giuseppelisi/University/Thesis/Matlab/'...
25 'FilesNewEmg/serial/recognize/ch1/1-1-1.txt'];
26
27 fid = fopen(file);
28 c{1,1} = fscanf(fid, '%d', [1 inf])';
29
30 fclose(fid);
31
32
33 file=['/Users/giuseppelisi/University/Thesis/Matlab/'...
34 'FilesNewEmg/serial/recognize/ch2/1-1-1.txt'];
35
36 fid = fopen(file);
37 c{1,2} = fscanf(fid, '%d', [1 inf])';
38
39 fclose(fid);
40
41
42 file=['/Users/giuseppelisi/University/Thesis/Matlab/'...
43 'FilesNewEmg/serial/recognize/ch3/1-1-1.txt'];
44
45 fid = fopen(file);
46 c{1,3} = fscanf(fid, '%d', [1 inf])';
47
48 fclose(fid);
49
50 c{1,4}=0;
51
52 % extract the feature vectors from the burst contained in the
53 % single signal
54 f=splitFilter(c,1,0,0,1,'recognize',ch2,ch3)'
55
56 % uses the ANN to reognize the movement performed.
57 if(¬isempty(f))
58 out = sim(net,f);
59
60
61 % performance evaluation, depending on the number of movements
62 % on which the ANN is trained
63 lout=length(out(1,:));
64 if mov==7
65 for i=1:lout
66 y= ismember(out(:,i),max(out(:,i)))'
67 if(eq(y,[1 0 0 0 0 0 0]))
68 [status,result] = unix('say close hand','-echo');
69 elseif (eq(y,[0 1 0 0 0 0 0]))
70 [status,result] = unix('say open hand','-echo');
71 elseif (eq(y,[0 0 1 0 0 0 0]))
72 [status,result] = unix('say wrist extension','-echo');
73 elseif (eq(y,[0 0 0 1 0 0 0]))
74 [status,result] = unix('say wrist flexion','-echo');
75 elseif (eq(y,[0 0 0 0 1 0 0]))
76 [status,result] = unix('say thumb abduction','-echo');
77 elseif (eq(y,[0 0 0 0 0 1 0]))
78 [status,result] = unix('say thumb opposition','-echo');
79 elseif (eq(y,[0 0 0 0 0 0 1]))
80 [status,result] = unix('say index extension','-echo');
81 end
82 endA.3. Motion Recognition xxv
83 end
84
85
86 if mov==6
87 for i=1:lout
88 y= ismember(out(:,i),max(out(:,i)))'
89 if(eq(y,[1 0 0 0 0 0]))
90 [status,result] = unix('say close hand','-echo');
91 elseif (eq(y,[0 1 0 0 0 0]))
92 [status,result] = unix('say open hand','-echo');
93 elseif (eq(y,[0 0 1 0 0 0]))
94 [status,result] = unix('say wrist extension','-echo');
95 elseif (eq(y,[0 0 0 1 0 0]))
96 [status,result] = unix('say wrist flexion','-echo');
97 elseif (eq(y,[0 0 0 0 1 0]))
98 [status,result] = unix('say thumb abduction','-echo');
99 elseif (eq(y,[0 0 0 0 0 1]))
100 [status,result] = unix('say thumb opposition','-echo');
101 end
102 end
103 end
104
105 if mov==5
106 for i=1:lout
107 y= ismember(out(:,i),max(out(:,i)))'
108 if(eq(y,[1 0 0 0 0]))
109 [status,result] = unix('say close hand','-echo');
110 elseif (eq(y,[0 1 0 0 0]))
111 [status,result] = unix('say open hand','-echo');
112 elseif (eq(y,[0 0 1 0 0]))
113 [status,result] = unix('say wrist extension','-echo');
114 elseif (eq(y,[0 0 0 1 0]))
115 [status,result] = unix('say wrist flexion','-echo');
116 elseif (eq(y,[0 0 0 0 1]))
117 [status,result] = unix('say thumb abduction','-echo');
118 end
119 end
120 end
121
122 if mov==4
123 for i=1:lout
124 y= ismember(out(:,i),max(out(:,i)))'
125 if(eq(y,[1 0 0 0]))
126 [status,result] = unix('say close hand','-echo');
127 elseif (eq(y,[0 1 0 0]))
128 [status,result] = unix('say open hand','-echo');
129 elseif (eq(y,[0 0 1 0]))
130 [status,result] = unix('say wrist extension','-echo');
131 elseif (eq(y,[0 0 0 1]))
132 [status,result] = unix('say wrist flexion','-echo');
133 end
134 end
135 end
136
137 if mov==3
138 for i=1:lout
139 y= ismember(out(:,i),max(out(:,i)))'
140 if(eq(y,[1 0 0]))
141 [status,result] = unix('say close hand','-echo');
142 elseif (eq(y,[0 1 0]))
143 [status,result] = unix('say open hand','-echo');
144 elseif (eq(y,[0 0 1]))
145 [status,result] = unix('say wrist extension','-echo');
146
147 end
148 end
149 end
150
151 if mov==2
152 for i=1:lout
153 y= ismember(out(:,i),max(out(:,i)))'
154 if(eq(y,[1 0]))
155 [status,result] = unix('say close hand','-echo');
156 elseif (eq(y,[0 1]))
157 [status,result] = unix('say open hand','-echo');
158 end
159 end
160 end
161
162 end
163 end