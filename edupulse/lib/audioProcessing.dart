import 'dart:math';

class AudioProcessing {
  // Constructor
  AudioProcessing();

  final int sampleRate = 44100;
  final int symbolSamples = 441; // 10ms per symbol
  final double f0 = 1200; 
  final double f1 = 2200; 
  List<int> decodedBits = [];
  List<double> buffer = [];

  Map<int, String> byteMap = {
    // Numbers 0-9
    for (int i = 48; i <= 57; i++) i: String.fromCharCode(i),

    // Uppercase letters A-Z
    for (int i = 65; i <= 90; i++) i: String.fromCharCode(i),

    // Lowercase letters a-z
    for (int i = 97; i <= 122; i++) i: String.fromCharCode(i),

    // Common symbols (space, punctuation, etc)
    32: ' ', 33: '!', 34: '"', 35: '#', 36: r'$', 37: '%', 38: '&',
    39: "'", 40: '(', 41: ')', 42: '*', 43: '+', 44: ',', 45: '-',
    46: '.', 47: '/', 58: ':', 59: ';', 60: '<', 61: '=', 62: '>',
    63: '?', 64: '@', 91: '[', 92: r'\\', 93: ']', 94: '^', 95: '_',
    96: '`', 123: '{', 124: '|', 125: '}', 126: '~',
  };


  double goertzel(List<double> samples, int sampleRate, double targetFreq) {
    int n = samples.length;
    double s_prev = 0.0;
    double s_prev2 = 0.0;
    double normalizedFreq = 2 * 3.141592653589793 * targetFreq / sampleRate;
    double coeff = 2 * cos(normalizedFreq);

    for (int i = 0; i < n; i++) {
      double s = samples[i] + coeff * s_prev - s_prev2;
      s_prev2 = s_prev;
      s_prev = s;
    }

    return s_prev2 * s_prev2 + s_prev * s_prev - coeff * s_prev * s_prev2;
  }

  List<int> bitsToBytes(List<int> bits) {
    List<int> bytes = [];
    for (int i = 0; i + 7 < bits.length; i += 8) {
      int byte = 0;
      for (int j = 0; j < 8; j++) {
        byte = (byte << 1) | bits[i + j];  // MSB first
      }
      bytes.add(byte);
    }
    return bytes;
  }

  bool checkPreamble(List<int> bits, int startIndex) {
    List<int> preambleBits = [
      1,0,1,0,1,0,1,0,  
      1,0,1,0,1,0,1,0   
    ];

    if (startIndex + preambleBits.length > bits.length) {
      return false;
    }

    for (int i = 0; i < preambleBits.length; i++) {
      if (bits[startIndex + i] != preambleBits[i]) {
        return false;
      }
    }
    return true;
  }

  int findPreambleIndex(List<int> bits) {
    for (int i = 0; i < bits.length - 15; i++) {  // 16 bits preamble length
      if (checkPreamble(bits, i)) {
        print("🟢");
        return i;  // Found preamble starting at index i
      }
    }
    return -1;  // Not found
  }

  void processBuffer(List<double>? newSamples) {
    if (newSamples == null) return; // Prevents null errors
    buffer.addAll(newSamples);

    while (buffer.length >= symbolSamples) {
      List<double> symbolChunk = buffer.sublist(0, symbolSamples);
      buffer = buffer.sublist(symbolSamples);

      double mag0 = goertzel(symbolChunk, sampleRate, f0);
      double mag1 = goertzel(symbolChunk, sampleRate, f1);

      int bit = mag1 > mag0 ? 1 : 0;
      decodedBits.add(bit);
      print(decodedBits);
    }
    
    if (findPreambleIndex(decodedBits) != -1) {
      int payloadStartIndex = findPreambleIndex(decodedBits) + 16;
      int bitsToExtract = 256 + 16;  // payload + crc

      if (payloadStartIndex + bitsToExtract <= decodedBits.length) {
        List<int> frameBits = decodedBits.sublist(payloadStartIndex, payloadStartIndex + bitsToExtract);
        List<int> frameBytes = bitsToBytes(frameBits);
        List<int> payload = frameBytes.sublist(0, 32);  
        List<int> crc = frameBytes.sublist(32, 34);      
        print("🔵");
        print(payload);

        for (int byte in payload) {
          if (byteMap.containsKey(byte)) {
            print("Decoded byte: ${byteMap[byte]}");
          } else {
            print("Unknown byte: $byte");
          }
        }

      } else {
        print("Not enough bits");
      }
    }
  }
}