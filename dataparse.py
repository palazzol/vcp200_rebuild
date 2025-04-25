import os, sys

with open('datarom.bin','rb') as f:
    x = f.read()

addr = 0x18
h = (x[addr] & 0xf0) >> 4
l = x[addr] & 0x0f
while l != 0x0f:
    nextaddr = addr + l + 1
    print(f'{addr:02x}: ',end='')
    for i in range(addr,nextaddr):
        print(f'{x[i]:02x} ',end='')
    print()
    addr = nextaddr
    h = (x[addr] & 0xf0) >> 4
    l = x[addr] & 0x0f
