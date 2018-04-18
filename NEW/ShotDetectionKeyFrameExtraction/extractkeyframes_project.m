function [indices] = extractkeyframes_project(video)
 % create histograms
 %How many bins for the HSV histogram
h_bins=16;
s_bins=4;
v_bins=4;
number_of_bins=h_bins+s_bins+v_bins;
threshold=.05; %Adjust to get more/less frames
N=100;  %window size
frameNumber = 0;
a=1;

% read in video
inputv = VideoReader(video);   % take in inputs
expectedNumberOfFrames = int32(inputv.duration * inputv.framerate);
totalFramesRead = 0;

for i = 1:int32(expectedNumberOfFrames/500)
    % Read frames until the end of the video, 500 at a time. 
    framesLeft = expectedNumberOfFrames - totalFramesRead;
    if framesLeft > 500
        frames = read(inputv, [totalFramesRead+1 ((totalFramesRead+1)+499)]);
    else
        frames = read(inputv, [(totalFramesRead+1) Inf]);
    end
    numberOfFramesRead = length(frames(1,1,1,:));
    totalFramesRead = totalFramesRead + numberOfFramesRead;
    
    % Process this set of images.


    if i == 1
        cd ('KeyFrameExtraction/colorspace');
        histograms = zeros(expectedNumberOfFrames, number_of_bins);
    end
    
    frameStart = (500 * (i - 1)) + 1;
    for j = frameStart:totalFramesRead
            hsv_image=colorspace('RGB->HSV', frames(:,:,:,j - frameStart + 1));
            h=hsv_image(:,:,1);
            s=hsv_image(:, :,2);
            v=hsv_image(:,:,3);
            histograms(j,:)=[imhist(h, h_bins)', imhist(s, s_bins)', imhist(v, v_bins)'];
    end
    
    if(i == 1)
        %matrix for time N, where N is the window size
        S=svd(histograms( 1 : N, : ) );
        previous_rank=length(find( S/S(1)>threshold ));
        
        %Matrix for time N+1
        S=svd(histograms( 2 : (N+1), : ));
        next_rank=length(find( S/S(1)>threshold));
        
        indices=[];
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
                possibility=0;
                a=a+1;
            end
            %sprintf('Frame Number=%d', frameNumber)
            frameNumber=frameNumber+1;
            previous_rank=rank;
        end
    else %not the first iteration through the while loop
        for t = 1 : numberOfFramesRead
            rank=next_rank;     
            S=svd(histograms(t:t+N-1, :));
            next_rank=length(find( S/S(1)>threshold));
            
            if( (rank>previous_rank))
                possibility=frameNumber;
                
            end
            
            if(rank<next_rank && possibility~=0)
                indices(a)=possibility;
                possibility=0;
                a=a+1;
            end
            frameNumber=frameNumber+1;
            previous_rank=rank;
        end
    end
end

%disp("Expected number of frames: " + expectedNumberOfFrames + ...
%    " Actual number of frames: " + numberOfFrames);
cd('../..');
end
