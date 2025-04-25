import os, sys

# Assemble
if os.system('tools\\as6804.exe -o -p -s -l vcp200.asm') != 0:
    print('Error during Assembly')
    sys.exit(-1)
# Link
if os.system('tools\\aslink.exe -n -m -u -s vcp200.rel') != 0:
    print('Error during Linking')
    sys.exit(-1)
# Generate Binary
if os.system('tools\\srec2bin.exe -q -o 0x800 -a 0x0800 -f 00 vcp200.s19 vcp200.bin') != 0:
    print('Error during Binary Generation')
    sys.exit(-1)
# Compare with reference
with open('vcp200_program_rom.bin', 'rb') as forig:
    with open('vcp200.bin', 'rb') as fnew:
        # 4k address space is really 2k
        # first 0x800 are "reserved", read back as
        # the same as the last half
        x = forig.read(0x800)
        x = forig.read(0x800)
        y = fnew.read(0x800)
for i in range(0,0x800):
    if x[i] != y[i]:
        print(f'Mismatch at 0x{i+0x800:x}')
        sys.exit(-1)

print('Rebuild complete!')
sys.exit(0)