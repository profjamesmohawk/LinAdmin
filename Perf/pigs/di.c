#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>

#include <errno.h>


/*
 * Simple program to create large files in /tmp
 *
 *	James Long, August 2015
 */

int nNumFiles = 0;
int nIOPS = 3;
int nFileSize = 100;

#define BS 8192


void usage(char *strName)
{
	fprintf(stderr,"\nUsage: %s -n <NumFiles>\n",strName); 
	fprintf(stderr,"\t Open <NumFiles> in /tmp\n");
	fprintf(stderr,"\t\t <NumFiles> must be between 1 and 100 \n");
	fprintf(stderr,"\t Slowly grow the size of each opened file to a max of aprox 2GB\n");
	fprintf(stderr,"\t Env Var PIG_IOPS is approx IOPS\n");
	fprintf(stderr,"\t Env Var PIG_SIZE is approx size of each file in MB\n");
}

scan_args(int argc, char * argv[]){
	char *string;
	int counter;
	char *strPigIOPS;
	char *strPigSize;
	
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

	// process env args
	//

	nIOPS=10;
	strPigIOPS = getenv("PIG_IOPS");
        if(strPigIOPS){
                nIOPS = atoi(strPigIOPS);
                if (nIOPS < 1 ) nIOPS = 10;
                if (nIOPS > 100 ) nIOPS = 100;
        }
		
	nFileSize=100;
	strPigSize = getenv("PIG_SIZE");
        if(strPigSize){
                nFileSize = atoi(strPigSize);
                if (nFileSize < 1 ) nFileSize = 10;
                if (nIOPS > 1000 ) nFileSize = 1000;
		nFileSize = (int)(((float) nFileSize * (float)1000000)/(float)BS);
        }
}


main(int argc, char *argv[])
{
	char Data[BS];
	char strFileName[1024];
	int i;
	int j;
	int aFiles[100];
	int nWritesPerSecond;
	int nPigRate;
	char* strPigRate;
	int blnWriteError=0;
	int nBytesWritten;
	int nTotalBytesWritten=0;
	int foo;

	scan_args(argc, argv);

	// initialze the data
	memset(Data,'j',BS);

	// open and init the files
	//
	for(i=0;i<nNumFiles; i++){
		sprintf(strFileName,"/tmp/pig_%d",i+1000);
		//aFiles[i] = open(strFileName,O_CREAT|O_SYNC|O_TRUNC|O_RDWR);
		aFiles[i] = open(strFileName,O_CREAT|O_TRUNC|O_RDWR);
		if(aFiles[i] == -1){
			fprintf(stderr,"Error opening %s, %s\n",strFileName, strerror(errno));
			exit(1);
		}
		if( fchmod(aFiles[i],00666)){
			fprintf(stderr,"Error changing permissions.\n");
			exit(1);
		}

		for(j=0;j<nFileSize;j++){
			nBytesWritten = write(aFiles[i],Data,BS);		
			if(nBytesWritten == -1){
				fprintf(stderr,"Write Error %d:%s, %s\n",aFiles[i],strFileName, strerror(errno));
				exit(1);
			}
		}
	}

	// do some random reads and writes
	//
	while(1){
		for(i=0;i<nNumFiles;i++){
			for(j=0;j<nIOPS;j++){

				// seek to a random spot in the file
				(void) lseek (	aFiles[i],
						(rand()*nFileSize)/RAND_MAX * BS,
						SEEK_SET);
				// do a read
				read( aFiles[i],Data,BS);

				// seek to a random spot in the file
				(void) lseek (	aFiles[i],
						(rand()*nFileSize)/RAND_MAX * BS,
						SEEK_SET);
				// do a write
				write( aFiles[i],Data,BS);
//printf("%f\n", ((float)rand()*(float)nFileSize)/(float)RAND_MAX * (float)BS);
foo = ((float)rand()*(float)10)/(float)RAND_MAX;
printf("%d\n",foo);

			}
		}
		sleep(1);
	}

#ifdef NEVER_WILL_BE	

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
#endif	
}
