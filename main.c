#include <bcm2835.h>
//#include <time.h>
#define PIN RPI_GPIO_P1_11
int main(int argc, char **argv)
{
    if (!bcm2835_init())
    return 1;
// Set the pin to be an output
bcm2835_gpio_fsel(PIN, BCM2835_GPIO_FSEL_OUTP);
//struct timespec tw = {0,0};
//struct timespec tw = {0,0};		1,3 0.1 ms		0.13 ms	0.00013 s
//struct timespec tr;
// Blink
while (1){
	//Turn it on
	bcm2835_gpio_write(PIN, HIGH);
	//wait
	//usleep(1000000);//	10.2 200 ms		2040 ms	2.04 s		0.49 hz
	//usleep(100000);//	4 50 ms			200 ms	0.2 s		5 hz
	//usleep(10000);//	2,1 10 ms		21 ms	0.021 s		47.6 hz
	usleep(1000);//		2,1 1 ms		2.1 ms	0.0021 s	467.2 hz
	//usleep(100)//;		0,2 1 ms		0.2 ms	0.0002 s	5000 hz
	//usleep(10);//		1,4 0.1 ms		0.14 ms	0.00014 s	7142 hz
	//usleep(1);//		1,3 0.1 ms		0.13 ms	0.00013 s	7692 hz
//	nanosleep(&tw, &tr);
//	usleep(500);
	// turn it off
	bcm2835_gpio_write(PIN, LOW);
	//wait
	usleep(1000);
//	nanosleep(&tw, &tr);
//	nanosleep(1);
}
bcm2835_close();
return 0;
}
