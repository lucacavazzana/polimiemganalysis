/* *******************************************************
EracleNeuralNetworkTRAIN.cpp:
*
Open the ( number of movement , actually 6)
files in Eracle_NN
containing eachNUM_ACQ*3 root mean square .
These values are employed to train an Artificial
Neural Network that will be used to recognize the user ’s movement.
The NN is saved in EracleNN in TrainedNN.dat
 ******************************************************* */
# include "stdafx.h"
# include "Eracle.h"
# include <iostream>
# include <string>
# include <fstream>
# include <sstream>
# include <ltiMLP.h>
# include <ltiLispStreamHandler.h>
# include "ltiRbf.h"

using namespace std ;

#define MAX_LOADSTRING 100
// number of repetitions

#define NUM_ACQ 10
// number of samples

#define DIM_CHANNEL 1010

void EracleNeuralNetworkTRAIN (){
	fstream nnTrain ;
	nnTrain.open ("\\Storage Card\\Eracle_NN\\nnTrain.txt ", fstream::out);

	/* (((1)))
	 * open the 6 files with the movement RMS :*/
	FILE * mov0 ;
	FILE * mov1 ;
	FILE * mov2 ;
	FILE * mov3 ;
	FILE * mov4 ;

	mov0 = fopen ("\\Storage card\\Eracle_NN\\RMSmov0.txt","r");
	mov1 = fopen ("\\Storage card\\Eracle_NN\\RMSmov1.txt","r");
	mov2 = fopen ("\\Storage card\\Eracle_NN\\RMSmov2.txt","r");
	mov3 = fopen ("\\Storage card\\Eracle_NN\\RMSmov3.txt","r");
	mov4 = fopen ("\\Storage card\\Eracle_NN\\RMSmov4.txt","r");
	/* (((2)))
	 * fill the global array reading from each file */

	// examples data array for training
	double RMSglobal [((NUM_ACQ)*3)*5];

	// answer data array for training
	int RMSanswer [NUM_ACQ *5];

	// fill each input vector with data from corresponding file
	// ((NUM_ACQ)*3) RMS for mov0
	for ( int k =0;k <((NUM_ACQ)*3); k ++){
		fscanf(mov0, "%lf", &RMSglobal[k]);
	}

	// ((NUM_ACQ)*3) RMS for mov1
	for (int k = ((NUM_ACQ)*3); k < (((NUM_ACQ)*3)*2); k++){
		fscanf(mov1, "%lf", &RMSglobal[k]);
	}
	// ((NUM_ACQ)*3) RMS for mov2
	for (int k =(((NUM_ACQ)*3)*2); k < (((NUM_ACQ)*3)*3); k++){
		fscanf(mov2 , "%lf", &RMSglobal[k]);
	}
	// ((NUM_ACQ)*3) RMS for mov3
	for ( int k =(((NUM_ACQ)*3)*3); k <(((NUM_ACQ)*3)*4); k ++){
		fscanf (mov3 , "%lf", &RMSglobal[k]);
	}
	// ((NUM_ACQ)*3) RMS for mov4
	for ( int k =(((NUM_ACQ)*3)*4); k <(((NUM_ACQ)*3)*5); k ++){
		fscanf (mov4 , "%lf", &RMSglobal[k]);
	}
	// examples matrix for training
	lti::dmatrix train_matrix (5*NUM_ACQ, 3 , RMSglobal );
	// fill the answer training vector
	int i;
	//NUM_ACQrms represent mov0
	for (i =0; i < NUM_ACQ; i++)
		RMSanswer[i]=0;
	//NUM_ACQrms represent mov1
	for (i = NUM_ACQ; i < NUM_ACQ*2; i++)
		RMSanswer[i]=1;
	//NUM_ACQrms represent mov2
	for (i = NUM_ACQ*2; i < NUM_ACQ*3; i++)
		RMSanswer[i]=2;
	//NUM_ACQrms represent mov3
	for (i = NUM_ACQ*3; i < NUM_ACQ*4; i++)
		RMSanswer[i]=3;
	//NUM_ACQrms represent mov4
	for (i = NUM_ACQ*4; i < NUM_ACQ*5; i++)
		RMSanswer[i]=4;
	// answer vector for training
	lti::ivector train_results_vector(NUM_ACQ*5, RMSanswer);
	// object NN
	lti::MLP ann ;
	// NN parametersss
	lti::MLP::parameters param ;
	lti::MLP::sigmoidFunctor sigmoid(1);
	param.setLayers(12, sigmoid);
	param.trainingMode = lti::MLP::parameters::SteepestDescent ;
	param.maxNumberOfEpochs = 2000;
	param.learnrate = 0.01;
	// param.momentum = 1.0;
	// param.stopError = 0.002;
	ann.setParameters (param);
	MessageBox (NULL, TEXT ("Begin of training"),
			TEXT("EracleNeuralNetworkTRAIN"), MB_OK );

	ann.train( train_matrix , train_results_vector );
	MessageBox(NULL, TEXT ("End of training"),
			TEXT (" EracleNeuralNetworkTRAIN"), MB_OK );
	ofstream recNN("\\Storage Card\\Eracle_NN\\TrainedNN.dat");
	lti::lispStreamHandler lsh ( recNN );

	ann.write(lsh);
	recNN.close();
	MessageBox (NULL, TEXT(" Trained NN saved "),
			TEXT (" EracleNeuralNetworkTRAIN "), MB_OK );
	fclose(mov0);
	fclose(mov1);
	fclose(mov2);
	fclose(mov3);
	fclose(mov4);
	// fclose(mov5);
	return;
}
