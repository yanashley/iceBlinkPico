import numpy as np

# adjusted to capture just 1/4 of sine wave, with sample values scaled to 9-bits
x = np.array(range(128))
y = list(np.round(511 * 0.5 * (1. + np.sin(2. * np.pi * x / 512.))))
y = [int(v) for v in y]

f = open('sine.txt', 'w')
for v in y:
    f.write(f'{v:03x}\n')
f.close()

# Assuming your y values are in the range of 0 to 1, to get 9-bit sample values, you would multiply by 511 rather than 1023. 
# You would still use the 03x format specifier in the f-string, as you need three hex digits to represent 9-bit or 10-bit numbers.
