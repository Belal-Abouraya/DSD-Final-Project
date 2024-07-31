
clear
% Read the text file as bytes
filePath = "Image/Path/image.coe"; 

lines = readlines(filePath);
lines(end) = [];
lines_dec = bin2dec(lines);
s = serialport("COM6",4800);

for i=1:length(lines_dec)
   write(s, lines_dec(i),"uint8"); 
end