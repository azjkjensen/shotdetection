function [indices, ranks] = extractkeyframes_project(video)
 % Number of bins for each component of the HSV histogram
h_bins=8;
s_bins=4;
v_bins=4;
number_of_bins=h_bins+s_bins+v_bins;

%Adjust to get more/less frames
threshold=.028; 
%window size
N=2;  
frameNumber = N+1;
a=1;

SAMPLE_SIZE = 500.0;

% read in video
inputv = VideoReader(video);   % take in inputs
expectedNumberOfFramesExact = inputv.duration * inputv.framerate;
expectedNumberOfFrames = int32(expectedNumberOfFramesExact);
totalFramesRead = 0;

for i = 1:int32(ceil(expectedNumberOfFramesExact/SAMPLE_SIZE))
    % Read frames until the end of the video, SAMPLE_SIZE at a time. 
    framesLeft = expectedNumberOfFrames - totalFramesRead;
    if framesLeft > SAMPLE_SIZE
        frames = read(inputv, [totalFramesRead+1 ((totalFramesRead)+SAMPLE_SIZE)]);
    else
        frames = read(inputv, [(totalFramesRead+1) Inf]);
    end
    numberOfFramesRead = length(frames(1,1,1,:));
    totalFramesRead = totalFramesRead + numberOfFramesRead;
    
    % Process this set of images.
    if i == 1 
        % If the first frame, prepare the histograms and cd into
        % the proper directory.
        cd ('KeyFrameExtraction/colorspace');
        histograms = zeros(expectedNumberOfFrames, number_of_bins);
    end
    
    % Assemble histograms for each component of the image.
    frameStart = (SAMPLE_SIZE * (i - 1)) + 1;
    for j = frameStart:totalFramesRead
            hsv_image=colorspace('RGB->HSV', frames(:,:,:,j - frameStart + 1));
            h=hsv_image(:,:,1);
            s=hsv_image(:, :,2);
            v=hsv_image(:,:,3);
            histograms(j,:)=[imhist(h, h_bins)', imhist(s, s_bins)', imhist(v, v_bins)'];
    end
    
    if(i == 1)
        % Matrix for time N, where N is the window size
        S=svd(histograms( 1 : N, : ) );
        previous_rank=length(find( S/S(1)>threshold ));
        
        % Matrix for time N+1
        S=svd(histograms( 2 : (N+1), : ));
        next_rank=length(find( S/S(1)>threshold));
        
        indices=[];
        ranks=[];
        possibility=0;
        for t = 3 : numberOfFramesRead-N+1
            rank=next_rank;
            
            S=svd(histograms(t:t+N-1, :));
            next_rank=length(find( S/S(1)>threshold));
            
            if( (rank>previous_rank))
                possibility=frameNumber;
                
            end
            
            if(rank<next_rank && possibility~=0)
                indices(a)=possibility;
                ranks(a)=rank;
                a=a+1;
            end
            frameNumber=frameNumber+1;
            previous_rank=rank;
        end
    else %not the first iteration through the loop
        disp("Working on frames " + (frameStart) + " to " + ...
            (frameStart + numberOfFramesRead -1));
        for t = frameStart : frameStart + numberOfFramesRead-1
            rank=next_rank;
            if (t+N-1) > expectedNumberOfFrames
                upperLimit = frameStart + numberOfFramesRead - 1;
            else
                upperLimit = t + N - 1;
            end
            
            S=svd(histograms(t:upperLimit, :));
            next_rank=length(find( S/S(1)>threshold));
            
            if( (rank>previous_rank))
                possibility=frameNumber;
                
            end
            
            if(rank<next_rank && possibility~=0)
                indices(a)=possibility;
                ranks(a)=rank;
                a=a+1;
            end
            frameNumber=frameNumber+1;
            previous_rank=rank;
        end
    end
end

indices = indices./(inputv.framerate);
disp("Expected number of frames: " + expectedNumberOfFrames + ...
   " Actual number of frames: " + totalFramesRead);
cd('../..');
end
% Returns indices, a vector of frame indices where keyframes are found, and
% ranks, a vector of the ranks corresponding to the given indices.
