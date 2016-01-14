all:
	gcc AM2302.c -lbcm2835 -lrt -o AM2302
clean:
	rm -rf *.o AM2302
