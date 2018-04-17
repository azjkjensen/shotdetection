function [frames] = readFrames(srcFolder,filePrefix,ext,range)
% Reads the frame sequence from a folder
% Inargs:
%   1. srcFolder - path to the source folder
%   2. filePrefix - prefix of the images to be read
%   3. ext - file extension
%   4. range - [start frame, end frame]

n=1;
frames = cell(range(2)-range(1)+1, 1);
for i=range(1):range(2)
    filename = [srcFolder, sprintf('%s%05d',filePrefix,i), ext];
    frames{n} = imread(filename);
    n=n+1;
end

end