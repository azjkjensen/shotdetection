%in
function [indices] = extractkeyframes_project(video)
 % create histograms
 %How many bins for the HSV histogram
h_bins=16;
s_bins=4;
v_bins=4;
number_of_bins=h_bins+s_bins+v_bins;
threshold=.05; %Adjust to get more/less frames
N=100;  %window size

%
start_index=1;
stop_flag=0;
j=1;
iteration=0;
frame_number=N+1;

% read in video
 inputv = VideoReader(video);   % take in inputs
 while(~stop_flag)
     %Read in movie
    iteration=iteration+1;
    start_index=start_index+500;
    %
    frames = zeros(inputv.height,inputv.width,3,500); % 1 x 500 array
    for i = 1:499
        if hasFrame(inputv)
            frames(1:inputv.height,1:inputv.width,1:3,i) = readFrame(inputv); %
            imshow([frames(:,:,1,i) frames(:,:,2,i) frames(:,:,3,i)],[]);
            %imshow(rgb2gray(readFrame(inputv)));
            if i == 400
                disp("here");
            end
        else
            stop_flag = 1;
        end
    end
%     numberofframes = length(frames);
%     if iteration == 1
%         cd ('KeyFrame\ Extraction/colorspace');
%     end
%     histograms = zeros(numberofframes, number_of_bins);
%     for i=1:number_of_frames
%             hsv_image=colorspace('RGB->HSV', frames(i).cdata);
%             h=hsv_image(:,:,1);
%             s=hsv_image(:, :,2);
%             v=hsv_image(:,:,3);
%             histograms(i,:)=[imhist(h, h_bins)', imhist(s, s_bins)', imhist(v, v_bins)'];
%     end
 end
%disp(numberofframes);


 
 


end