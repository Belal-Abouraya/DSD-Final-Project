from PIL import Image
# Load the image
image = Image.open(r"image/path")
# Resize the image to 50x50
image = image.resize((50, 50))
# Convert image to RGB mode (if not already in RGB)
image = image.convert("RGB")
# Get the pixel data
pixel_data = list(image.getdata())
# Function to convert RGB values to 12-bit representation
def convert_to_12_bit(pixel):
    # Extract RGB values
    r, g, b = pixel
    # Convert each channel to 4-bit representation
    r_4bit = (r >> 4) & 0b1111
    g_4bit = (g >> 4) & 0b1111
    b_4bit = (b >> 4) & 0b1111
   # Combine channels into a single 12-bit representation
    return (r_4bit << 8) | (g_4bit << 4) | b_4bit

# Convert each pixel to 12-bit representation
lines = [convert_to_12_bit(pixel) for pixel in pixel_data]

print(len(lines))
lines_to_write = []

# convert each two pixels to 3 bytes
for i in range(0, len(lines), 2):
    line1 = format(lines[i], '012b')
    line2 = format(lines[i], '012b')
    while(len(line1) < 12):
        line1 = "0" + line1
    while(len(line2) < 12):
        line1 = "0" + line2
    to_write1 = line1[0:8]
    to_write2 = line1[8:12] + line2[0:4]
    to_write3 = line2[4:12]
    lines_to_write.append(to_write1)
    lines_to_write.append(to_write2)
    lines_to_write.append(to_write3)
        

lines_to_write.reverse()
print(len(lines_to_write))
with open("image.coe", "w") as new_file:
        for line in lines_to_write:
        # Write the modified line to the new file
            new_file.write(line + '\n')
