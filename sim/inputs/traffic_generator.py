#! /bin/env python3

import random as rm
import math

##### Uniform Distribution #####
size      = 32    # Packet Size
bandwidth = 32    # Bandwidth
rate      = 1     # Rate 
amount    = 16     # Amount of Packets
x_total   = 4     # X Noc Size
y_total   = 4     # Y Noc Size

def xy():
    while True:
        x = math.floor(rm.uniform( 0 , x_total ))
        y = math.floor(rm.uniform( 0 , y_total ))
        if str(x)+str(y) != router:
            break
    return(x,y)

for i in range(math.floor(x_total)):
    for j in range(math.floor(y_total)):

        router = str(i) + str(j)
        t = 1024 
        with open(str(router)+".txt", "w") as output:
            for k in range(amount):
                x, y = xy()
                output.write(str(t) + '\t' + str(x) + '\t' +  str(y) + '\t' + str(size) + ('\n' if k != amount - 1 else ''))
                t += int((bandwidth * size)/ rate)
