#include <stdio.h>
#include <bcm2835.h>

//#define DEBUG 1

#define MAXTIMINGS 88
#define MAXDATA 5
#define DHT22 22
#define DELAY 1024

#ifdef DEBUG
#define MAXSTREAM 42
#endif

int readAM2302(int type, int pin);

int main(int argc, char **argv)
{
	int type = 0;
	int dhtpin = atoi(argv[2]);
	int error=0;
	int i=0;
	
	if (!bcm2835_init()) return 1;
/*
	if (argc != 3) {
		printf("usage: %s [22] GPIOpin#\n", argv[0]);
		printf("example: %s 22 17 - Read from an DHT22 connected to GPIO #17\n", argv[0]);
		return 2;
	}
*/
	if (argc != 3) {
		type = DHT22;
		dhtpin = 17;
	}else{
		dhtpin = atoi(argv[2]);
		if (strcmp(argv[1], "22") == 0) type = DHT22;
	}
	
	if (type == 0) {
		printf("Select 22 as type!\n");
		return 3;
	}
	
	if (dhtpin <= 0) {
		printf("Please select a valid GPIO pin #\n");
		return 3;
	}

#ifdef DEBUG
	printf("Reading from DHT%d Using pin #%d\n", type, dhtpin);
#endif
	
while(1){
	error=readAM2302(type, dhtpin);
#ifdef DEBUG
	if ( error ) printf("[error code = %i]\n",error);
#endif
	if ((i>DELAY)||(!(error))) break;
	i++;
}
	return 0;
}

int readAM2302(int type, int pin) {
	int counter = 0;
	int i=0;
	int j=0;
	int k=0;
	int state=1;
	int tmap[MAXTIMINGS]={0};
	int data[MAXDATA]={0};
	float temp=0;
	float hum=0;
#ifdef DEBUG
	int stream[MAXSTREAM]={0};
#endif
        unsigned char CRC8=0;
        
	// Set GPIO pin to output
	bcm2835_gpio_fsel(pin, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_write(pin, HIGH);
	usleep(100);//master bus
	bcm2835_gpio_write(pin, LOW);
	usleep(500);//hold start signal 1 ms
	bcm2835_gpio_write(pin, HIGH);
	bcm2835_gpio_fsel(pin, BCM2835_GPIO_FSEL_INPT);

	if (bcm2835_gpio_lev(pin) == HIGH) {
		for (i=0;i<MAXTIMINGS;i++){
			counter=0;
			if (state==1){
				while(bcm2835_gpio_lev(pin) != LOW){
					counter++;
					if (counter == 1400) break;
				}
			}else{
				while(bcm2835_gpio_lev(pin) != HIGH){
					counter++;
					if (counter == 1400) break;
				}
			}
			state = !state;
			tmap[i]=counter;
		}
	}
#ifdef DEBUG
	for (i=0,j=0;i<MAXTIMINGS;i++,j++){
		if (j==7) {
			printf("%i \n",tmap[i]);
			j=-1;
		}else{
			printf("%i ",tmap[i]);
		}
	}
	printf("\n");
	for (i=4,j=0;i<MAXTIMINGS;i=i+2,j++){
		if(tmap[i]<150) stream[j]=0;
		else stream[j]=1;
		printf("%i ",tmap[i]);
	}
	printf("\n");
	for (i=0,j=0;i<MAXSTREAM;i++,j++){
		if (j==7) {
			printf("%i\n",stream[i]);
			j=-1;
		}else{
			printf("%i",stream[i]);
		}
	}
#endif

	for (i=4,j=7,k=0;i<MAXTIMINGS;i=i+2,j--){
		if(tmap[i]>150) {data[k]=data[k]|(1<<j);}
		if (j==0) {j=8;k++;}
	}

	CRC8=(0xff&(data[0]+data[1]+data[2]+data[3]));
	
	hum=(float)((((data[0]<<8)|data[1])))/10;
	if ((data[2]&(1<<7))) {
		data[2]=data[2]&0x7F;
		temp=(float)((((data[2]<<8)|data[3])))/10;
		temp=-temp;
	} else {
		temp=(float)((((data[2]<<8)|data[3])))/10;
	}

	if (CRC8==data[4]){
#ifdef DEBUG
		printf("0x%X\n",data[0]);
		printf("0x%X\n",data[1]);
		printf("0x%X\n",data[2]);
		printf("0x%X\n",data[3]);
		printf("0x%X\n",data[4]);
#endif
		printf("temperature=%0.2f C humidity=%0.2f %RH\n",temp,hum);
	}else{
#ifdef DEBUG
		printf("0x%X\n",data[0]);
		printf("0x%X\n",data[1]);
		printf("0x%X\n",data[2]);
		printf("0x%X\n",data[3]);
		printf("0x%X\n",data[4]);
		printf("temperature=%0.2f C humidity=%0.2f %RH parity bit error\n",temp,hum);
#endif
		return 1;
	}

return 0;
}
