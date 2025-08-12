import numpy as np
from scipy.io.wavfile import write

sample_rate = 44100
bit_duration = 0.01  # 10 ms per bit
f0 = 1200  # freq for bit 0
f1 = 2200  # freq for bit 1

# Bitstream example: preamble (0xAA 0xAA) + payload bits
bitstream = [
  1,0,1,0,1,0,1,0,  # 0xAA
  1,0,1,0,1,0,1,0,  # 0xAA
  0,1,1,1,0,0,1,0,  # r (114)
  0,1,1,0,0,0,0,1,  # a (97)
  0,1,1,1,0,0,0,0,  # p (112)
  0,1,1,0,1,0,1,1,  # k (107)
  0,1,1,1,1,0,0,0,  # x (120)
  0,1,1,1,0,1,0,0,  # t (116)
  0,1,1,0,1,0,0,0,  # h (104)
  0,1,1,0,1,1,0,0,  # l (108)
  0,1,1,0,0,0,1,1,  # c (99)
  0,1,1,1,1,0,1,0,  # z (122)
  0,1,1,0,0,1,1,0,  # f (102)
  0,1,1,1,0,1,1,1,  # w (119)
  0,1,1,1,0,1,1,0,  # v (118)
  0,1,1,0,1,1,0,1,  # m (109)
  0,1,1,0,1,0,1,0,  # j (106)
  0,1,1,1,0,0,0,1,  # q (113)
  0,1,1,1,0,0,1,1,  # s (115)
  0,1,1,0,1,1,1,0,  # n (110)
  0,1,1,0,0,1,0,1,  # e (101)
  0,1,1,1,0,1,0,1,  # u (117)
  0,1,1,0,0,1,0,0,  # d (100)
  0,1,1,0,0,1,1,1,  # g (103)
  0,1,1,0,1,1,1,1,  # o (111)
  0,1,1,0,0,0,1,0,  # b (98)
  0,1,1,0,1,0,0,1,  # i (105)
  0,1,1,1,1,0,0,1,  # y (121)
  0,1,1,1,0,0,1,0,  # r (114)
  0,1,1,0,0,0,0,1,  # a (97)
  0,1,1,1,0,0,0,0,  # p (112)
  0,1,1,0,1,0,1,1,  # k (107)
  0,1,1,1,1,0,0,0,  # x (120)
  0,1,1,1,0,1,0,0,  # t (116)
]

def tone(frequency, duration, sample_rate):
    t = np.linspace(0, duration, int(sample_rate * duration), False)
    tone = np.sin(frequency * 2 * np.pi * t)
    return tone

audio = np.array([], dtype=np.float32)
for bit in bitstream:
    freq = f1 if bit == 1 else f0
    audio = np.concatenate((audio, tone(freq, bit_duration, sample_rate)))

# Normalize to 16-bit range
audio_int16 = np.int16(audio / np.max(np.abs(audio)) * 32767)

write('fsk_test.wav', sample_rate, audio_int16)
print("Generated fsk_test.wav")
