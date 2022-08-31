#include <stdio.h>
#include <stdlib.h>


int nArrayLen = 0;

void usage(char *strName)
{
	fprintf(stderr,"\nUsage: %s -n <ArraySize in MB>\n",strName); 
	fprintf(stderr,"\t Allocate an array of <ArraySize> MB and then use\n");
	fprintf(stderr,"\t that array so that is stays \"active\" in memory\n");
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


		// -n <ArraySize>
		if ( strcmp("-n",string) == 0) {
				counter++;
				if(counter >= argc) {usage(argv[0]);exit(1);} // do we have enough args?
				nArrayLen = atoi(argv[counter]);
				if(nArrayLen < 1 || nArrayLen > 2000)
				{
					usage(argv[0]);
					exit(1);
				}
				nArrayLen = (nArrayLen * 1000000) / sizeof(int);
				continue;
		}
	}
}


main(int argc, char *argv[])
{
	char *ptrA;
	int *Data;
	int i;

	//nArrayLen = nSize * BLK_SIZE;

	scan_args(argc, argv);

	// allocate the data buffer
	//printf("Allocating %d bytes\n",nArrayLen * sizeof(int));
	Data = (int*) malloc( nArrayLen * sizeof(int));
	if( ! Data){
		fprintf(stderr,"Error allocating memory, try a smaller <ArraySize>\n");
		exit(2);
	}



	// Walk the data doing silly things


	while(1){

		for( i=0;i< nArrayLen; i++){
			Data[i] = 9317;
		}
		// take a little break
		sleep(1);
	}
}
