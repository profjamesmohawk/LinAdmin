#include <stdio.h>
#include <stdlib.h>


/*
 * A simple program to eat up CPU cycles
 *
 *	James Long, August 2015
 */

#define ARRAY_LEN 20

main(int argc, char *argv[])
{
	char *ptrA;
	float  Data[ARRAY_LEN];
	int i;

	// initialize the data
	for( i=0;i< ARRAY_LEN; i++){
		Data[i] = 9317;
	}

	// Walk the data doing silly things

	while(1){

		for( i=1;i< ARRAY_LEN; i++){
			Data[i] = Data[i-1]/Data[i];
		}
	}
}
