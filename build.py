import os, sys
import platform

PLATFORM = platform.system()

# Assemble
cmd = os.path.join('tools',PLATFORM,'as6804 -o -p -s -l vcp200.asm')
if os.system(cmd) != 0:
    print('Error during Assembly')
    sys.exit(-1)
# Link
cmd = os.path.join('tools',PLATFORM,'aslink -n -m -u -s vcp200.rel')
if os.system(cmd) != 0:
    print('Error during Linking')
    sys.exit(-1)
# Generate Binary
cmd = os.path.join('tools',PLATFORM,'srec2bin -q -o 0x800 -a 0x0800 -f 00 vcp200.s19 vcp200.bin')
if os.system(cmd) != 0:
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
