# generate_bitstream.py

# Map similar to your Dart byteMap
byte_map = {}

# Numbers 0-9
for i in range(48, 58):
    byte_map[i] = chr(i)

# Uppercase letters A-Z
for i in range(65, 91):
    byte_map[i] = chr(i)

# Lowercase letters a-z
for i in range(97, 123):
    byte_map[i] = chr(i)

# Common symbols
symbols = {
    32: ' ', 33: '!', 34: '"', 35: '#', 36: '$', 37: '%', 38: '&',
    39: "'", 40: '(', 41: ')', 42: '*', 43: '+', 44: ',', 45: '-',
    46: '.', 47: '/', 58: ':', 59: ';', 60: '<', 61: '=', 62: '>',
    63: '?', 64: '@', 91: '[', 92: '\\', 93: ']', 94: '^', 95: '_',
    96: '`', 123: '{', 124: '|', 125: '}', 126: '~'
}
byte_map.update(symbols)

# Function to convert string to bitstream
def string_to_bitstream(s):
    bitstream = []
    for ch in s:
        byte = ord(ch)
        if byte not in byte_map:
            raise ValueError(f"Character {ch} (ASCII {byte}) not in byte_map")
        bits = [(byte >> i) & 1 for i in reversed(range(8))]
        bitstream.extend(bits)
    return bitstream

# Example usage
if __name__ == "__main__":
    import json

    json_data = {"question": "What is the name of the 5th planet in the solar system"}

    json_str = json.dumps(json_data)
    bits = string_to_bitstream(json_str)

    print("bitstream = [")
    for i, bit in enumerate(bits):
        print(bit, end=", " if (i + 1) % 8 != 0 else ",  # next byte\n")
    print("]")
