/* ******************************************************
EracleFastICA.cpp:
 *
Open the files previously generated by the parser and :
- compute and subtract the average value of
each channel(remmean);
- compute the unmixing matrix;
- apply FastICA algorithm;
- Add the mean back to the data .
In the output result of ICA are corrected with
a mean calculation inspired from
MATLAB implementation of FastICA .
The output vectors are stored in three separated files
in Eracle_FastICA : three files for
each sampling(one per channel ).
 ******************************************************* */
#include "stdafx.h"
#include "Eracle.h"
#include <iostream>
#include <string>
#include <fstream>
#include <sstream>
#include "ltiVector.h"
#include "ltiMatrix.h"
#include "ltiFastICA.h"
#include "s2ws.h"

using namespace std;

#define MAX_LOADSTRING 100
// number of gesture repetitions

#define NUM_ACQ 10
// number of samples

#define DIM_CHANNEL 1010

void EracleFastICA(){
	MessageBox (NULL , TEXT("Begin of FastICA"),
			TEXT("EracleFastICA"), MB_OK);
	// variables for loop control and itoa conversion
	int indiceICA = 1;
	ostringstream ossICA;
	while(indiceICA <= NUM_ACQ ) {
		// stream for summary operations
		fstream fastica_stream;
		/* input files; one for each channel,
		 * these files are produced by EracleParser() function */
		FILE * Mazinga1;
		FILE * Mazinga2;
		FILE * Mazinga3;
		// FastICA path string input building
		string ICAInputfolderPrefix = "\\Storage Card\\Eracle_Parser\\Acq";
		ossICA << indiceICA;
		string ICANumFile = ossICA.str();
		string ICAinput1 = "\\Channel_1.txt";
		string ICAinput2 = "\\Channel_2.txt";
		string ICAinput3 = "\\Channel_3.txt";
		string ICAInputfile1Path = ICAInputfolderPrefix + ICANumFile + ICAinput1;
		string ICAInputfile2Path = ICAInputfolderPrefix + ICANumFile + ICAinput2;
		string ICAInputfile3Path = ICAInputfolderPrefix + ICANumFile + ICAinput3;
		/* it is not necessary to convert string to wstring,
		 * as fopen uses const char * to open file.
		 * String can be converted to const char * using data() method */
		// output folder creation
		string ICAOutputfolderPrefix = "\\Storage Card\\Eracle_FastICA\\Acq";
		string ICAOutputFolder = ICAOutputfolderPrefix + ICANumFile;
		std::wstring ICAtemp0 = s2ws(ICAOutputFolder);
		LPCWSTR ICAFolderResult = ICAtemp0.c_str();
		CreateDirectory(ICAFolderResult, NULL);
		// summary filestream string path
		string ICAOutputSuffix = "\\FastICA.txt";
		string ICAOutputSummary = ICAOutputFolder + ICAOutputSuffix;
		std::wstring ICAtemp = s2ws(ICAOutputSummary);
		LPCWSTR ICASummaryResult = ICAtemp.c_str();
		// Perform file and stream opening and check for errors
		// open summary filestream
		fastica_stream.open(ICASummaryResult, fstream::out);
		/* check for stream opening error */
		if(fastica_stream.fail()){
			MessageBox (NULL, TEXT("Error in opening filestream"),
					TEXT("EracleFastICA"), MB_OK);
			PostQuitMessage (0);
		}
		Mazinga1 = fopen(ICAInputfile1Path.data(), "r");
		Mazinga2 = fopen(ICAInputfile2Path.data(), "r");
		Mazinga3 = fopen(ICAInputfile3Path.data(), "r");
		if ((Mazinga1 == NULL)||
				(Mazinga2 == NULL)||
				(Mazinga3 == NULL)) {/* check for files opening error */
			MessageBox (NULL, TEXT("Error in opening input files"),
					TEXT("EracleFastICA"), MB_OK);
			exit(0);
		}
		/* data array declarations - one per channel
		 * - and the " global " array tot */
		double ch1_data[DIM_CHANNEL];
		double ch2_data[DIM_CHANNEL];
		double ch3_data[DIM_CHANNEL];
		double tot[DIM_CHANNEL*3];
		// copy data from files to vectors
		for(int k=0; k<DIM_CHANNEL; k++){
			fscanf(Mazinga1, "%lf", &ch1_data[k]);
			fscanf(Mazinga2, "%lf", &ch2_data[k]);
			fscanf(Mazinga3, "%lf", &ch3_data[k]);
		}
		/* check equal and fixed number of data acquired,
		 * exit if different */
		if ((sizeof(ch1_data)/sizeof(double)!= DIM_CHANNEL ) ||
				(sizeof(ch2_data)/sizeof(double)!= DIM_CHANNEL ) ||
				(sizeof(ch3_data)/sizeof(double)!= DIM_CHANNEL )) {
			MessageBox (NULL , TEXT("Array size error"),
					TEXT("EracleFastICA"), MB_OK);
			exit(0);
		}
		// fill the tot vector
		int i;
		for (i=0; i<DIM_CHANNEL; i++){
			tot[i] = ch1_data[i];
		}
		for (i=DIM_CHANNEL; i<DIM_CHANNEL*2; i++){
			tot[i] = ch2_data[i-DIM_CHANNEL];
		}
		for (i=DIM_CHANNEL*2; i < DIM_CHANNEL*3; i++){
			tot[i] = ch3_data[i-DIM_CHANNEL*2];
		}
		/* matrix constructor : 3 rows(one per source )
		 * and DIM_CHANNEL columns */
		lti::matrix <double> source(3, DIM_CHANNEL, tot), W, clean;
		// for fastICA rows and cols must be transposed:

		/* after transpose each ROW is an acquisition(input vector ),
		 * so it contains one sample for each source each COL is the set of
		 * data acquired by a single channel
		 * CH1|CH2 |CH3|
		 * iV1|    |   |
		 * iV2|    |   |
		 *  . |    |   | -->>> this is sourceT !!!
		 *  . |    |   |
		 *  . |    |   |
		 * */
		lti::matrix <double> sourceT;
		sourceT.transpose(source);
		//+++++++++++++++++++++++++++++++++++++++++++++++++++++
		//* REMMEAN:
		// compute the mean of each channel(column) and subtract
		// it from the data
		// before passing them to fastica */
		double mean[3];
		double temporale =0;
		for(int j =0; j<3; j++){
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
		matmedia.multiply (ones, media);
		sourceT.subtract(matmedia);
		//+++++++++++++++++++++++++++++++++++++++++++++++++
		lti::fastICA <double> pippo;
		lti::matrix <double> constTransfMatrix;
		pippo.apply(sourceT, clean);
		pippo.getTransformMatrix(constTransfMatrix);
		lti::vector <double> vec;
		pippo.getOffsetVector(vec);
		/* ***********************************************
		 * mean correction of FastICA output
		 * (inspired by MATLAB FastICA package)
		 * uscita = W * unmixedsig + (W*mixedmean)
		 * ones(1, NumOfSampl);
		 ************************************************ */
		lti::matrix <double> primoMembro;
		/* primoMembro = W*unmixedsig
		 * unmixedsig is FastICA output,
		 * it must be transposed in cleanT to be multiplied */
		lti::matrix <double> cleanT;
		cleanT.transpose(clean);
		primoMembro.multiply(constTransfMatrix, cleanT);
		/*v=W* mixedmean:
		 * before multiply b v contains the mean of
		 * the input data(mixedmean);
		 * after multilply b is the result of the operation */
		lti::vector <double> v;
		pippo.getOffsetVector(v);
		constTransfMatrix.multiply(v);
		/*v must be transposed to compute
		 * the last multiply (but there �s no tranpose method
		 * for vectors in LTILIB)*/
		double appoggio[3];
		for(int h=0; h<3; h++){ //" homemade " transpose
			appoggio[h] = v.at(h);
		}
		/* as in LTILIB doesn �t exists a column vector,
		 * a 3x1 matrix is used appoggioMatrice = (W*mixedmean )*/
		lti::matrix <double> appoggioMatrice (3, 1, appoggio);
		/* a matrix full of ones , in MATLAB it would be:
		 * unii = ones(1, DIM_CHANNEL) */
		const double inival =1;
		lti::matrix <double> unii(1, DIM_CHANNEL, inival);
		// secondoMembro = appoggioMatrice*unii
		lti::matrix <double> secondoMembro;
		secondoMembro.multiply(appoggioMatrice, unii);
		// uscita = primoMembro + secondoMembro
		lti::matrix <double> uscita, uscitaT;
		uscita = primoMembro + secondoMembro;
		// transposing matrix uscita, just for reading purpose
		uscitaT.transpose(uscita);
		/* ******************************************************* */
		// FastICA output file path string building
		string IcaOutput1 = "\\Clean1_ICA.txt";
		string IcaOutput2 = "\\Clean2_ICA.txt";
		string IcaOutput3 = "\\Clean3_ICA.txt";
		string ICAInputFile1Path = ICAOutputFolder + IcaOutput1;
		string ICAInputFile2Path = ICAOutputFolder + IcaOutput2;
		string ICAInputFile3Path = ICAOutputFolder + IcaOutput3;
		std::wstring ICAtemp1 = s2ws(ICAInputFile1Path);
		std::wstring ICAtemp2 = s2ws(ICAInputFile2Path);
		std::wstring ICAtemp3 = s2ws(ICAInputFile3Path);
		LPCWSTR ICAInputFile1Result = ICAtemp1.c_str();
		LPCWSTR ICAInputFile2Result = ICAtemp2.c_str();
		LPCWSTR ICAInputFile3Result = ICAtemp3.c_str();
		// files for EracleFastICA output
		fstream clean1, clean2, clean3;
		clean1.open(ICAInputFile1Result, fstream::out);
		clean2.open(ICAInputFile2Result, fstream::out);
		clean3.open(ICAInputFile3Result , fstream::out);
		// check for opening file errors
		if ((clean1.fail()) || ( clean2.fail()) || ( clean3.fail())) {
			MessageBox(NULL, TEXT("Error in opening OUTPUT file"),
					TEXT("EracleFastICA"), MB_OK);
		}
		/* split the clean matrix in 3 different file,
		 * that will be opened by EracleRMS,
		 * each sample is separated by a white space.
		 * If input matrix is uscitaT -->>>>
		 * the " mean corrected " values are printed
		 * If input matrix is clean -->>>>
		 * the raw values returned by apply are printed */
		for(int r =0; r < DIM_CHANNEL; r++){
			clean1 << uscitaT.at(r ,0);
			clean1 << " ";
			clean2 << uscitaT.at(r ,1);
			clean2 << " ";
			clean3 << uscitaT.at(r ,2);
			clean3 << " ";
		}
		/* close files and streams */
		clean1.close();
		clean2.close();
		clean3.close();
		fastica_stream.close();
		fclose(Mazinga1);
		fclose(Mazinga2);
		fclose(Mazinga3);
		// flush of ostringstream
		ossICA.str("");
		ossICA.clear();
		indiceICA++; // loop variable++
		pippo.~fastICA();
		constTransfMatrix.~matrix();
		sourceT.~matrix();
		source.~matrix();
		cleanT.~matrix();
		clean.~matrix();
		uscita.~matrix();
		uscitaT.~matrix();
	}
	MessageBox (NULL , TEXT("End of FastICA"),
			TEXT("EracleFastICA"), MB_OK);
	return;
}
