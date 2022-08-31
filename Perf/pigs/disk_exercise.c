#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <time.h>
#include <signal.h>
#include "stop_watch.h"
#include <errno.h>

/* globals */
int sync_flag = 0;
int fsize = 10;
int bsize = 1024;
int read_flag = 0;
int write_flag = 0;
int init = 0;
int seq = 0;
int rand_flag = 1;
int no_loops = 10;
int verbose = 0;
char * filename = '\0';
int off_set = 0;
int no_ios = 0;
int test_time = 10;
int fd;
int test_time_flag = 0;
int no_loops_flag = 0;
/* end globals */


usage(char * name){
	fprintf(stderr,"\n Usage %s : -sync|-async \n",name);
	fprintf(stderr,"\t\t -seq|-rand , rand is default\n");
	fprintf(stderr,"\t\t -read|-write|-init \n");
	fprintf(stderr,"\t\t -bsize N, size of read/write in bytes\n");
	fprintf(stderr,"\t\t -fsize N, size of file in bsize blocks\n");
	fprintf(stderr,"\t\t -n N, number of read/write,default 10,loop 0\n");
	fprintf(stderr,"\t\t -T T, length of test in seconds\n");
	fprintf(stderr,"\t\t -t , print timing information to stderr UNDER CONSTRUCTION\n");
	fprintf(stderr,"\t\t -v , print verbose information to stderr UNDER CONSTRUCTION\n");
	fprintf(stderr,"\t\t -f FILENAME , file to read/write\n");
}

scan_args(int argc, char * argv[]){
   char * string;
   int counter;
   if(1 == argc){
	usage(argv[0]);
	exit(1);
   }


   for(counter=1;counter < argc;counter++){
	string = argv[counter];


	/* -sync or -async */
	if ( strcmp("-sync",string) == 0) sync_flag = 1;
	if ( strcmp("-async",string) == 0) sync_flag = 0;

	/* -read -write -init */
	if ( strcmp("-read",string) == 0) read_flag = 1;
	if ( strcmp("-write",string) == 0) write_flag = 1;
	if ( strcmp("-init",string) == 0) init = 1;

	/* -rand -seq */
	if ( strcmp("-rand",string) == 0) rand_flag = 1;
	if ( strcmp("-seq",string) == 0) {seq = 1;rand_flag=0;}

	/* -v */
	if ( strcmp("-v",string) == 0) verbose = 1;

	/* file size */
	if ( strcmp("-fsize",string) == 0) {
		fsize = atoi(argv[counter + 1]);
	}

	/* block size */
	if ( strcmp("-bsize",string) == 0) {
		bsize = atoi(argv[counter + 1]);
	}

	/* no write */
	if ( strcmp("-n",string) == 0) {
		no_loops = atoi(argv[counter + 1]);
		no_loops_flag = 1;
	}

	/* time */
	if ( strcmp("-T",string) == 0) {
		test_time = atoi(argv[counter + 1]);
		test_time_flag = 1;
	}

	/* filename */
	if ( strcmp("-f",string) == 0) {
		filename = argv[counter + 1];
	}
   }

   if ( verbose ) {
	fprintf(stderr,"verbose invocation information goes here\n");
   }
}

int open_file(){
	int fd,flag;

	flag = O_RDWR;
	if ( init ) flag += O_CREAT;
	if ( sync_flag ) flag += O_SYNC;

	fd = open (filename,flag);
	
	if ( fd < 0 ){
        	fprintf(stderr,"Open error\n");
        	exit(1);
	}

	if ( 0 != fchmod(fd, 00666)){
		fprintf(stderr,"Open error - changing permisions.\n");
                exit(1);
	}
	return fd;
}

read_write(int fd,char * buffer){
        int no_read_written;

	if ( rand_flag ){
        	off_set = ((rand()*fsize)/32768) * bsize;
        	(void) lseek(fd, off_set, SEEK_SET);
	} else {
		off_set += bsize;
		if (off_set > bsize * fsize){
			off_set = 0;
		}
	}

	if ( write_flag ) {
        	no_read_written =  write(fd,buffer,bsize);
	} else {
        	no_read_written =  read(fd,buffer,bsize);
	}

        if ( no_read_written != bsize ) {
                fprintf(stderr,"Read/Write error ! (%s)\n",strerror(errno));
                fprintf(stderr,"%d\n",no_read_written);
                exit(1);
        }
	no_ios++;
}

file_init(int fd,char * buffer){
        int no_read_written;

	for(off_set = 0; off_set < fsize * bsize; off_set += bsize){
       		(void) lseek(fd, off_set, SEEK_SET);
        	no_read_written =  write(fd,buffer,bsize);

        	if ( no_read_written != bsize ) {
                	fprintf(stderr,"Read/Write error !\n");
                	exit(1);
		}
        }
}

void calc_stats(){
	float e_time;

	/* close file */
	close(fd);
	e_time = stop_watch(SW_READ);
	printf("\t\t%d IOs in %.2f seconds\n",no_ios,e_time); 
	printf("\t\tIOs/sec : %.0f\n", (float)no_ios/e_time);
	printf("\t\tThrough-put : %.0f KB/sec \n" ,(float)no_ios * (float)bsize / ( (float)1024 * e_time));


	exit(0);
}

SIGALRM_handler(int signal_no){
	calc_stats();
}


main(int argc,char * argv[]){
	char * buffer;
	int i,toggle;
 	struct itimerval rttimer;
        struct itimerval old_rttimer;

	scan_args(argc,argv);
	if ( read_flag == 0 && write_flag == 0 && init == 0){
		fprintf(stderr,"  -read -write or -init must be specified \n");
		exit(1);
	}
	if ( filename == '\0' ){
		fprintf(stderr,"  A filename must be specified \n");
		exit(1);
	}

	buffer = malloc(bsize);
	toggle = 0;
	for (i=0;i<bsize;i++){
		if( toggle ){
			buffer[i] = 'p';
			toggle = 0;
		}
		else{
			buffer[i] = 'h';
			toggle = 1;
		}
	}

	fd = open_file();

	if ( init ) {
		file_init(fd,buffer);
		close(fd);
		exit(0);
	}

	if ( test_time_flag && no_loops_flag ){
		fprintf(stderr,"\n Specify only one of -n of -T \n");
		exit(1);
	}

	/* time based test */
	if ( test_time_flag ){
		/* set-up and install a signal handler to catch the SIGALRM
		 * generated by the timer 
		 */
		{
			struct sigaction act,oact;
			sigset_t set;

			/* set up the signal set */
			if( sigemptyset(&set) ){ printf("sigemptyset error\n");exit(1);}
			if( sigaddset(&set, SIGALRM) ){ printf("sigemptyset error\n");exit(1);} 

			act.sa_handler = (void(*)(int)) SIGALRM_handler;
			act.sa_mask = set;
			act.sa_flags = NULL;
	
			(void) sigaction ( SIGALRM,&act,&oact);
		}

        	/* Set up timer to pop once in test_time seconds */
        	rttimer.it_value.tv_sec     = test_time; 
        	rttimer.it_value.tv_usec    = 0;
        	rttimer.it_interval.tv_sec  = 0;
        	rttimer.it_interval.tv_usec = 0;

        	setitimer (ITIMER_REAL, &rttimer, &old_rttimer);

		stop_watch(SW_START);

		while(1){
			read_write(fd,buffer);
		}
	}
	/* end time based test */

	/* number of IOs based test */
	if ( no_loops_flag ){
		stop_watch(SW_START);
		for(i=0;i<no_loops;i++){
			read_write(fd,buffer);
		}
		calc_stats();
	}
}
