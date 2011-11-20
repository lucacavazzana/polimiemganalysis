/* *********************************************************
EracleRecognizer.cpp :
 *
read the previous data acquired corresponding to a
single movement to be classified.
Data are splitted in three files: Parser_Ch1.txt,
Parser_Ch2.txt, Parser_Ch3.txt.
Then they are computed by fastica, the unmix matrix is
computed and directly used in fastica processing.
Fastica output vectors are used to calculate rms of the
input movement, then they are passed to the prevoiusly
trained NN, which classify the movement performed.
The ouput rms and the nn answer are saved in Rec.txt.
All handled files are stored in
\\Storage Card\\Eracle_Recognizer
 ********************************************************* */
# include "stdafx.h"
# include "s2ws.h"
# include <fstream>
# include "ltiVector.h"
# include "ltiMatrix.h"
# include "ltiFastICA.h"
# include <ltiMLP.h>
# include <ltiLispStreamHandler.h>
# include "ltiRbf.h"

# define MAX_LOADSTRING 100

# define DIM_CHANNEL 1010

using namespace std;
// variable for result index

int id;

void EracleRecognizer(){
	/* file stream for global function output */
	fstream recognizer;
	recognizer.open("\\Storage Card\\Eracle_Recognizer\\Rec.txt", fstream::out);
	if(recognizer.fail()){
		MessageBox(NULL, TEXT("Error in opening output file"),
				TEXT("eracleParser"), MB_OK);
		exit(0);
	}
	/*(((1))) Data parser ************************************** */
	int posD =0;
	fstream Channel_1, Channel_2, Channel_3;
	Channel_1.open("\\Storage Card\\Eracle_Recognizer\\Parser_Ch1.txt", fstream::out);
	Channel_2.open("\\ Storage Card\\Eracle_Recognizer\\Parser_Ch2.txt", fstream::out);
	Channel_3.open("\\Storage Card\\Eracle_Recognizer\\ Parser_Ch3.txt", fstream::out);
	if( Channel_1.fail()|| Channel_2.fail()|| Channel_3.fail()){
		MessageBox(NULL, TEXT("Error in opening parser output file"),
				TEXT("eracleParser"), MB_OK);
		exit(0);
	}
	// input stream to get data
	fstream input_data;
	/* the string that will contain all the emg
	 * board 's output(file DATA.txt )*/
	string tot = "";
	// open stream to read data file
	input_data.open("\\Storage Card\\Eracle_Recognizer\\DATI.txt", fstream::in);
	if( input_data.fail()){
		MessageBox(NULL, TEXT("Error in opening data input file"),
				TEXT("eracleParser"), MB_OK);
		exit(0);
	}
	/* read all the data in input stream
	 * and store them in string tot */
	while(input_data.good()){
		getline(input_data, tot);
	}
	/* ****************************************
	 * BEGIN OF PARSING ***********************
	 * **************************************** */
	/*(((1))) replace newline and carriage return with spaces */
	replace(tot.begin(), tot.end(), '\r', ' ');
	replace(tot.begin(), tot.end(), '\n', ' ');
	/*(((2))) find and erase spurious input
	 * vector at the begin of data */

	// find the position of the first D
	posD = tot.find("D");
	// if file doesn 't begin with D ...
	if( posD !=0){
		// ... erase alla charachters before D
		tot.erase(0, posD);
	}
	/*(((3))) delete the last input vector , to prevent
	 * spurious data at the end of stream */
	size_t ultimo;
	size_t fine;
	// get the position of last D ...
	ultimo = tot.rfind("D");
	// ... and the position of the terminator
	fine = tot.rfind("\0");
	// delete last row , but don 't erase "\0" charachter
	tot.erase(ultimo , fine-1);
	/*(((4))) count the number of D
	 * --> this is also the number of rows
	 * --> this is also the number of " good " data acquired */

	// numbers of " clean " data acquired
	int conteggio = count(tot.begin(), tot.end(), 'D');
	if( conteggio < 1010) {
		MessageBox(NULL, TEXT("Pochi campioni"),
				TEXT("eracleParser"), MB_OK);
		exit(0);
	}
	/*(((5))) split string tot in three files,
	 * each column to a file , each data separated
	 * by a blank spaces (included the last one) */
	size_t begin, end;

	// get the indeces of the first number in first row
	begin = tot.find("D");
	end = tot.find(" ");
	int index;
	int row_count =0;
	// run until 1010 lines have been parsed
	while(row_count < DIM_CHANNEL){
		// for the first number indeces have already been acquired
		if(row_count > 0){
			begin = tot.find("D",end);
			end = tot.find(" ", begin+1);
		}
		// first number of the triple --> to file Channel_1
		for(index = static_cast <int >(begin)+2;
				index < static_cast <int>(end); index++){
			Channel_1 << tot[index];
		}
		Channel_1 <<" ";
		// adjust indeces
		begin = tot.find(" ", end);
		end = tot.find(" ", begin+1);
		// second number of the triple --> to file Channel_2
		for(index = static_cast <int>(begin)+1;
				index < static_cast <int>(end); index++){
			Channel_2 << tot[index];
		}
		Channel_2 << " ";
		// adjust indeces
		begin = tot.find(" ", end);
		end = tot.find(" ", begin+1);
		// last number of the triple --> to file Channel_3
		for(index = static_cast <int>(begin)+1;
				index < static_cast <int>(end); index++){
			Channel_3 << tot[index];
		}
		Channel_3 << " ";
		row_count++;
	}
	/* close all streams */
	input_data.close();
	Channel_1.close();
	Channel_2.close();
	Channel_3.close();
	/*(((2))) FASTICA *************************************** */
	/* unmix matrix is computed on the(unique ) movement
	 * acquired and it is applied to the same set of data */
	lti::matrix <double> constTransfMatrix;
	lti::fastICA <double> pippo;
	fstream fastica_stream; // stream for summary operations
	/* input files; one for each channel,
	 * these files are produced by EracleParser() function */
	FILE * Mazinga1;
	FILE * Mazinga2;
	FILE * Mazinga3;
	// open summary filestream
	fastica_stream.open("\\Storage Card\\Eracle_Recognizer\\FastICA.txt", fstream::out);
	/* check for stream opening error */
	if(fastica_stream.fail()){
		MessageBox(NULL, TEXT("Error in opening filestream"),
				TEXT("EracleFastICA"), MB_OK);
		exit(0);
	}
	Mazinga1 = fopen("\\Storage Card\\Eracle_Recognizer\\Parser_Ch1.txt", "r");
	Mazinga2 = fopen("\\Storage Card\\Eracle_Recognizer\\Parser_Ch2.txt", "r");
	Mazinga3 = fopen("\\Storage Card\\Eracle_Recognizer\\Parser_Ch3.txt", "r");
			if((Mazinga1 == NULL) || (Mazinga2 == NULL) || ( Mazinga3 == NULL)) {/* check for files opening error */
				MessageBox(NULL, TEXT("Error in opening Fastica input file"),
						TEXT("EracleFastICA"), MB_OK);
				exit(0);
			}
	/* data array declarations - one per channel - and the " global " array tot */
	double ch1_data[ DIM_CHANNEL];
	double ch2_data[ DIM_CHANNEL];
	double ch3_data[ DIM_CHANNEL];
	double ICAtot[DIM_CHANNEL*3];
	// copy data from files to vectors
	for(int k=0; k<DIM_CHANNEL; k++){
		fscanf(Mazinga1, "%lf", &ch1_data[k]);
		fscanf(Mazinga2, "%lf", &ch2_data[k]);
		fscanf(Mazinga3, "%lf", &ch3_data[k]);
	}
	/* check equal and fixed number
	 * of data acquired , exit if different */
	if((sizeof(ch1_data)/sizeof(double) != DIM_CHANNEL ) ||
			(sizeof(ch2_data)/sizeof(double) != DIM_CHANNEL) ||
			(sizeof(ch3_data)/sizeof(double) != DIM_CHANNEL)) {
		MessageBox(NULL, TEXT("Array size error"),
				TEXT("EracleFastICA"), MB_OK);
		exit(0);
	}
	// fill the tot vector
	int i;
	for(i =0; i<DIM_CHANNEL; i++){
		ICAtot[i]= ch1_data[i];
	}
	for(i= DIM_CHANNEL; i<DIM_CHANNEL*2; i++){
		ICAtot[i]= ch2_data[i-DIM_CHANNEL];
	}
	for(i=DIM_CHANNEL*2;i< DIM_CHANNEL*3; i++){
		ICAtot[i]= ch3_data[i-DIM_CHANNEL*2];
	}
	/* matrix creation: 3 rows(one per source)
	 * and DIM_CHANNEL columns */
	lti::matrix <double> source(3, DIM_CHANNEL, ICAtot);
	lti::matrixi <double> W, clean;
	// for fastICA rows and cols must be transposed:
	/* after transpose
	 * each ROW is an acquisition(input vector),
	 * so it contains one sample for each source
	 * each COL is the set of data acquired
	 * by a single channel
	 * CH1|CH2|CH3|
	 * iV1|   |   |
	 * iV2|   |   |
	 *  . |   |   |
	 *  . |   |   |
	 *  . |   |   |
	 * 	 */
	lti::matrix <double> sourceT;
	sourceT.transpose(source);
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//* REMMEAN:
	// compute the mean of each channel(column )
	// and subtract it from the data
	// before passing them to fastica */
	double mean[3];
	double temporale = 0;
	for(int j=0; j<3; j++){
		for(int i=0; i<DIM_CHANNEL; i++){
			temporale = temporale + sourceT.at(i,j);
		}
		mean[j]= temporale/DIM_CHANNEL;
		temporale = 0;
	}
	lti::matrix <double> media(1, 3, mean);
	const double init = 1;
	lti::matrix <double> ones(DIM_CHANNEL, 1, init);
	lti::matrix <double> matmedia;
	matmedia.multiply(ones, media);
	sourceT.subtract(matmedia);
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	/* getOffsetVector returns the mean
	 * of each channel of the input data */
	lti::vector <double> vec;
	pippo.getOffsetVector(vec);
	/* compute the transformation matrix
	 * and apply it to the same set of data */
	if(!( pippo.apply(sourceT, clean ))){
		MessageBox(NULL, TEXT("Impossibile eseguire FASTICA"),
				TEXT("Eracle REC"), MB_OK);
		return;
	}
	pippo.getTransformMatrix(constTransfMatrix);
	/* ****************************************************
	 * uscita = W * unmixedsig + (W * mixedmean) * ones(1, NumOfSamples);
	 **************************************************** */
	lti::matrix <double> primoMembro;
	lti::matrix <double> cleanT;
	cleanT.transpose(clean);
	primoMembro.multiply(constTransfMatrix, cleanT);
	lti::vector <double> v;
	pippo.getOffsetVector(v);
	constTransfMatrix.multiply(v);
	double appoggio[3];
	for(int h=0; h<3; h++){ // traposta " casereccia "
		appoggio[h]=v.at(h);
	}
	lti::matrix <double> appoggioMatrice(3, 1, appoggio);
	// unii = ones(1, DIM_CHANNEL )
	const double inival = 1;
	lti::matrix <double> unii(1, DIM_CHANNEL, inival);
	lti::matrix <double> secondoMembro;
	secondoMembro.multiply(appoggioMatrice, unii);
	// uscita = primoMembro + secondoMembro
	lti::matrix <double> uscita, uscitaT;
	uscita = primoMembro + secondoMembro;
	uscitaT.transpose(uscita);
	/* ****************************************************** */
	fastica_stream.close();
	fclose(Mazinga1);
	fclose(Mazinga2);
	fclose(Mazinga3);
	/*(((4))) RMS dati ******************************************* */
	/* apply the formula:
	 * sqrt((1/ DIM_CHANNEL)* SUM(i=0, i=DIM_CHANNEL)[Si ^2])
	 * for each column of the matrix generated by EracleFastICA function.
	 * The value of RMS are stored in a file, separated by a blank spaces */
	/* RMS is computed on the MEAN CORRECTED data, if you want to use the output
	 * fastica data just swap uscita with clean */
	double RMS;
	double sumOfSquare =0;
	double NN_class_data[3];
	for(int ch =0; ch<3; ch++){
		for(int k=0; k< DIM_CHANNEL; k++){
			sumOfSquare = sumOfSquare + pow(uscita.at(ch, k),2);
		}
		RMS = sqrt(sumOfSquare/DIM_CHANNEL);
		NN_class_data[ch]= RMS*100;
		RMS = 0;
		sumOfSquare =0;
	}
	//  MessageBox(NULL, TEXT("End of RMS calculation"), TEXT("EracleRMS"), MB_OK);
	//  MessageBox(NULL, TEXT("EracleRMS \ nTUTTO OK"), TEXT("EracleFastICA"), MB_OK);
	/*(((4))) NN classify **************************************** */
	/* acquire the info of the previously trained NN */
	lti::MLP annc;
	std::ifstream inNN("\\Storage Card\\Eracle_NN\\TrainedNN.dat");
	lti::lispStreamHandler lsh_c(inNN);
	if(!( annc.read(lsh_c ))){
		MessageBox(NULL, TEXT("Error opening NN"), TEXT("Eracle NN"), MB_OK);
		exit(0);
	}
	inNN.close();
	// result generated by NN
	lti::MLP::outputVector risultato;
	// vector containing the feature to classify
	lti::dvector feature_to_classify(3, NN_class_data);
	recognizer << feature_to_classify;
	// classification with NN
	if(!( annc.classify(feature_to_classify , risultato ))){
		MessageBox(NULL, TEXT("Impossibile classificare"), TEXT("Eracle REC"), MB_OK);
	}
	recognizer << risultato;
	risultato.getId(risultato.getWinnerUnit(), id);
	recognizer <<id;
	/* switch between possible classification results */
	switch(id ){
	case 0:
		MessageBox(NULL, TEXT("Chiusura"), TEXT("Eracle REC"), MB_OK);
		break;
	case 1:
		MessageBox(NULL, TEXT("Dorsi"), TEXT("Eracle REC"), MB_OK);
		break;
	case 2:
		MessageBox(NULL, TEXT("Palm") TEXT("Eracle REC"), MB_OK);
		break;
	case 3:
		MessageBox(NULL, TEXT("Apertura"), TEXT("Eracle REC"), MB_OK);
		break;
	case 4:
		MessageBox(NULL, TEXT("Pointer"), TEXT("Eracle REC"), MB_OK);
		break;
	}
	recognizer.close();
	id =0; // reset result index
	annc.~MLP(); // destruct NN
	feature_to_classify.~vector();
	lsh_c.~lispStreamHandler();
	return;
}
