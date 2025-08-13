import numpy as np
from scipy.io.wavfile import write

sample_rate = 44100
bit_duration = 0.04  # 40 ms per bit
f0 = 8000  # freq for bit 0
f1 = 10000  # freq for bit 1

# Bitstream example: preamble (0xAA 0xAA) + payload bits
bitstream = [
  1, 0, 1, 0, 1, 0, 1, 0,  # preamble byte 1 (0xAA)
  1, 0, 1, 0, 1, 0, 1, 0,  # preamble byte 2 (0xAA)
  0, 1, 1, 1, 1, 0, 1, 1,  # next byte
  0, 0, 1, 0, 0, 0, 1, 0,  # next byte
  0, 1, 1, 1, 0, 0, 0, 1,  # next byte
  0, 1, 1, 1, 0, 1, 0, 1,  # next byte
  0, 1, 1, 0, 0, 1, 0, 1,  # next byte
  0, 1, 1, 1, 0, 0, 1, 1,  # next byte
  0, 1, 1, 1, 0, 1, 0, 0,  # next byte
  0, 1, 1, 0, 1, 0, 0, 1,  # next byte
  0, 1, 1, 0, 1, 1, 1, 1,  # next byte
  0, 1, 1, 0, 1, 1, 1, 0,  # next byte
  0, 0, 1, 0, 0, 0, 1, 0,  # next byte
  0, 0, 1, 1, 1, 0, 1, 0,  # next byte
  0, 0, 1, 0, 0, 0, 0, 0,  # next byte
  0, 0, 1, 0, 0, 0, 1, 0,  # next byte
  0, 1, 0, 1, 0, 1, 1, 1,  # next byte
  0, 1, 1, 0, 1, 0, 0, 0,  # next byte
  0, 1, 1, 0, 0, 0, 0, 1,  # next byte
  0, 1, 1, 1, 0, 1, 0, 0,  # next byte
  0, 0, 1, 0, 0, 0, 0, 0,  # next byte
  0, 1, 1, 0, 1, 0, 0, 1,  # next byte
  0, 1, 1, 1, 0, 0, 1, 1,  # next byte
  0, 0, 1, 0, 0, 0, 0, 0,  # next byte
  0, 1, 1, 1, 0, 1, 0, 0,  # next byte
  0, 1, 1, 0, 1, 0, 0, 0,  # next byte
  0, 1, 1, 0, 0, 1, 0, 1,  # next byte
  0, 0, 1, 0, 0, 0, 0, 0,  # next byte
  0, 1, 1, 0, 1, 1, 1, 0,  # next byte
  0, 1, 1, 0, 0, 0, 0, 1,  # next byte
  0, 1, 1, 0, 1, 1, 0, 1,  # next byte
  0, 1, 1, 0, 0, 1, 0, 1,  # next byte
  0, 0, 1, 0, 0, 0, 0, 0,  # next byte
  0, 1, 1, 0, 1, 1, 1, 1,  # next byte
  0, 1, 1, 0, 0, 1, 1, 0,  # next byte
  0, 0, 1, 0, 0, 0, 0, 0,  # next byte
  0, 1, 1, 1, 0, 1, 0, 0,  # next byte
  0, 1, 1, 0, 1, 0, 0, 0,  # next byte
  0, 1, 1, 0, 0, 1, 0, 1,  # next byte
  0, 0, 1, 0, 0, 0, 0, 0,  # next byte
  0, 0, 1, 1, 0, 1, 0, 1,  # next byte
  0, 1, 1, 1, 0, 1, 0, 0,  # next byte
  0, 1, 1, 0, 1, 0, 0, 0,  # next byte
  0, 0, 1, 0, 0, 0, 0, 0,  # next byte
  0, 1, 1, 1, 0, 0, 0, 0,  # next byte
  0, 1, 1, 0, 1, 1, 0, 0,  # next byte
  0, 1, 1, 0, 0, 0, 0, 1,  # next byte
  0, 1, 1, 0, 1, 1, 1, 0,  # next byte
  0, 1, 1, 0, 0, 1, 0, 1,  # next byte
  0, 1, 1, 1, 0, 1, 0, 0,  # next byte
  0, 0, 1, 0, 0, 0, 0, 0,  # next byte
  0, 1, 1, 0, 1, 0, 0, 1,  # next byte
  0, 1, 1, 0, 1, 1, 1, 0,  # next byte
  0, 0, 1, 0, 0, 0, 0, 0,  # next byte
  0, 1, 1, 1, 0, 1, 0, 0,  # next byte
  0, 1, 1, 0, 1, 0, 0, 0,  # next byte
  0, 1, 1, 0, 0, 1, 0, 1,  # next byte
  0, 0, 1, 0, 0, 0, 0, 0,  # next byte
  0, 1, 1, 1, 0, 0, 1, 1,  # next byte
  0, 1, 1, 0, 1, 1, 1, 1,  # next byte
  0, 1, 1, 0, 1, 1, 0, 0,  # next byte
  0, 1, 1, 0, 0, 0, 0, 1,  # next byte
  0, 1, 1, 1, 0, 0, 1, 0,  # next byte
  0, 0, 1, 0, 0, 0, 0, 0,  # next byte
  0, 1, 1, 1, 0, 0, 1, 1,  # next byte
  0, 1, 1, 1, 1, 0, 0, 1,  # next byte
  0, 1, 1, 1, 0, 0, 1, 1,  # next byte
  0, 1, 1, 1, 0, 1, 0, 0,  # next byte
  0, 1, 1, 0, 0, 1, 0, 1,  # next byte
  0, 1, 1, 0, 1, 1, 0, 1,  # next byte
  0, 0, 1, 0, 0, 0, 1, 0,  # next byte
  0, 1, 1, 1, 1, 1, 0, 1,  # next byte
  0, 0, 1, 0, 0, 0, 1, 0,  # next byte
  0, 1, 1, 1, 1, 1, 0, 1,  # next byte
  ]


def tone(frequency, duration, sample_rate):
  t = np.linspace(0, duration, int(sample_rate * duration), False)
  tone = np.sin(frequency * 2 * np.pi * t)
  return 0.9 * tone  # Increase amplitude for better SNR

audio = np.array([], dtype=np.float32)
for bit in bitstream:
    freq = f1 if bit == 1 else f0
    audio = np.concatenate((audio, tone(freq, bit_duration, sample_rate)))

# Normalize to 16-bit range
audio_int16 = np.int16(audio / np.max(np.abs(audio)) * 32767)

write('fsk_test.wav', sample_rate, audio_int16)
print("Generated fsk_test.wav")
