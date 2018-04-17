% Paper: On the Use of Computable features for film Classification
% Implemented by Aditee 08/31/2017

function [shot_boundary, key_frame]=shotDetection(video)

tic;

% %How many bins for the HSV histogram
% h_bins=16;
% s_bins=4;
% v_bins=4;
% number_of_bins=h_bins+s_bins+v_bins;
% 
%threshold=.05; %Adjust to get more/less frames
%N=100;  %window size
%will read in 500 frames at a time
% start_index=1;
% 
% first_iteration=1;
% stop_flag=0;
% iteration=0;
% 
% S = zeros(1,1);
% %make HSV histograms for every image   
% histograms=zeros(2, number_of_bins); % just need to remember the current and the previous histogram
% %% Calculate the histogram and the intersection values
% while(~stop_flag)    
%     %Read in movie
%     iteration=iteration+1
%     movie=mmread(video, [start_index: start_index+499], [], false, true);
%     start_index=start_index+500;
%     frames=movie.frames;
%     
%     clear movie; %for memory management
%     
%     number_of_frames=length(frames);
%     if(number_of_frames<500) %then we've reached the end of the video
%         stop_flag=1;
%     end
% 
%     % the previous frame histogram is stored as histogram(1,:) and current is
%     % histogram(2,:)
%     S_tmp = zeros(number_of_frames,1); % tmp store for intersection values of the histogram
%     
%     for i=1:number_of_frames
%         hsv_image=rgb2hsv(frames(i).cdata);
%         h=hsv_image(:,:,1);
%         s=hsv_image(:,:,2);
%         v=hsv_image(:,:,3);
%         h_hist = imhist(h,h_bins);
%         h_hist = h_hist./sum(h_hist);
%         s_hist = imhist(s,s_bins);
%         s_hist = s_hist./sum(s_hist);
%         v_hist = imhist(v,v_bins);
%         v_hist = v_hist./sum(v_hist);
%         histograms(2,:)=[h_hist', s_hist', v_hist'];
%         % Find the intersection of the histograms for (i)th and (i-1)th frame
% %         s = sum(min(histograms)); 
%         s = sum(sum(sum(sqrt(histograms(1,:)).*sqrt(histograms(2,:)))));
%         if (iteration==1 && i > 1) % for first iter ignore the 0th frame
%             S_tmp(i) = s;
%         elseif (iteration > 1) % for next 500 frames, use the previous iteration as well
%             S_tmp(i) = s;
%         end
%         % copy the current histogram as previous for next iteration
%         histograms(1,:) = histograms(2,:);  
%     end
%     if (iteration==1)
%         S = S_tmp;
% %         first_iteration = 0;
%     else
%         S = [S;S_tmp];
%     end
% end 
[~, name, ~] = fileparts(video);
filename = ['S_' name '.mat'];
% save(filename,'S');
S = load(filename);
S = S.S;

%% Filter/ Smooth S values
nIters = 100;
S_t = zeros(length(S), nIters); % each col stores the new values
S_t(:,1) = S;
lambda = 0.1;
k = 0.1;
for t = 2:nIters % for now considering 5 iterations
    % find the gradients for the pervious iteration
    de_S = zeros(length(S), 1);
    dw_S = zeros(length(S), 1);
    ce = zeros(length(S), 1);
    cw = zeros(length(S), 1);
    for i = 2:(length(S)-1)
        de_S(i) = S_t(i+1,t-1) - S_t(i,t-1);
        dw_S(i) = S_t(i-1,t-1) - S_t(i,t-1);
    end
    ce = exp(-(abs(de_S)./k).^2);
    cw = exp(-(abs(dw_S)./k).^2);
    S_t(:,t) = S_t(:,t-1) + repmat(lambda,length(S),1) .* ((ce.*de_S) + (cw.*dw_S));
%     figure; plot(S_t(:,t));
end
% figure; plot(S); title('S-before smoothing');
% figure; plot(S_t(:,nIters)); title('S-after smoothing');
%% End
sprintf('Time to compute keyframes: %d', toc)

[pks, shot_boundary] = findpeaks(-S_t(:,nIters),'MinPeakHeight',-3+0.01); 
figure; plot(S_t(:,nIters)); hold on;
plot(shot_boundary,-pks,'o'); hold off








