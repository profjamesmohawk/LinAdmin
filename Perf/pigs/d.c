#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int nNumFiles = 0;

#define MAX_WRITES 1


void usage(char *strName)
{
	fprintf(stderr,"\nUsage: %s -n <NumFiles>\n",strName); 
	fprintf(stderr,"\t Open <NumFiles> in /tmp\n");
	fprintf(stderr,"\t\t <NumFiles> must be between 1 and 100 \n");
	fprintf(stderr,"\t Slowly grow the size of each opened file to a max of aprox 2GB\n");
	fprintf(stderr,"\t Env Var PIG_RATE is approx rate of growth in MB/s per file in range (defaults to 10)\n");
}

scan_args(int argc, char * argv[]){
	char *string;
	int counter;
	
	// we need exactly two command line args
	if ( argc != 3 ){
		usage(argv[0]);
		exit(2);
	}

	for(counter=1;counter < argc;counter++){
		string = argv[counter];


		// -n <NumFiles>
		if ( strcmp("-n",string) == 0) {
				counter++;
				if(counter >= argc) {usage(argv[0]);exit(1);} // do we have enough args?
				nNumFiles = atoi(argv[counter]);
				if(nNumFiles < 1 || nNumFiles > 100)
				{
					usage(argv[0]);
					exit(1);
				}
				continue;
		}
	}
}


main(int argc, char *argv[])
{
	char Data[1024];
	char strFileName[1024];
	int i;
	int j;
	FILE *aFiles[100];
	int nWritesPerSecond;
	int nPigRate;
	char* strPigRate;
	int blnWriteError=0;
	int nBytesWritten;
	int nTotalBytesWritten=0;

	scan_args(argc, argv);

	// initialze the data
	sprintf(Data,"Oink! Oink! Oink! Oink! Oink! Oink! Oink! Oink!\n");

	// open the files
	for(i=0;i<nNumFiles; i++){
		sprintf(strFileName,"/tmp/pig_%d",i);
		aFiles[i] = fopen(strFileName,"a");
	}

	// calculate how many writes we should do per second (actually per one sec rest)
	//
	//

	// set default nPigRate
	nPigRate = 10;
	// check for a PIG_RATE env var
	strPigRate = getenv("PIG_RATE");
	if(strPigRate){
		nPigRate = atoi(strPigRate);	
		if (nPigRate < 1 ) nPigRate = 10;
		if (nPigRate > 1000 ) nPigRate = 1000;
	}

	// do the math to convert nPigRate in MB/sec to nWritesPerSecond
	nWritesPerSecond = (nPigRate * 1000000) / strlen(Data);
	
	// do the writes, sleeping 1 second between efforts
	//
	while(1){
		sleep(1);

		// if we have experienced even one write error, stop writing, just loop
		if(blnWriteError) continue;

		// if we have written about 2GB, stop writing
		if(nTotalBytesWritten > 2000000000){
			blnWriteError = 1;
		}

		for(j=0;j<nNumFiles;j++){
			for(i=0;i<nWritesPerSecond;i++){
				nBytesWritten = fprintf(aFiles[j],Data);
				if(nBytesWritten == 0){
					blnWriteError = 1;
				}
				nTotalBytesWritten += nBytesWritten;
			}
			if( fflush(aFiles[j]) == EOF){
				blnWriteError = 1;
			}
		}
		
	}
	
}
