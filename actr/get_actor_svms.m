function svms = get_actor_svms( input_args )
%GET_ACTOR_SVMS Summary of this function goes here
%   Detailed explanation goes here
%
% INPUT
%
%
%
% OUTPUT
% - svms : array of 1 svm per actor found.

svms = [];

%% Find longest continouous track throughout the whole movie.
%  The longest 
processedFacedets = [];


load( fullfile(result_dir, 'facedets.mat'));
%pose = cat(1, facedets.pose);


% extract all frontal views
%frontal = pose==1;

%idx_f = (frontal > 0);
facedets_f = facedets(idx_f);
numFrontal = length(facedets_f);
facesActorA = track == 1;
facesActorB = track == 2;
idx = track == 1;
facedets_A = facedets_f(idx);
idx = track == 2;
facedets_B = facedets_f(idx);
length(facedets_B)
length(facedets_A)
% find frontal face with the highest confidence for both actors
%  conf_facedets_A = cat(1, facedets_A.pconf);
%  conf_facedets_B = cat(1, facedets_B.pconf);
%  bestFaceActorA =  find(conf_facedets_A==max(conf_facedets_A));
%  bestFaceActorB =  find(conf_facedets_B==max(conf_facedets_B));
%  dSift_bestFaceActorA = facedets_A.dSIFT;
%  dSift_bestFaceActorB = facedets_B.dSIFT;

%   prediction_Frontal = zeros(numFrontal, 1);
%  for i=1:numFrontal,
%      diffA = facedets_f(i).dSIFT - dSift_bestFaceActorA;
%      diffB = facedets_f(i).dSIFT - dSift_bestFaceActorB;
%      if sum(diffA) < sum(diffB)
%         prediction_Frontal(i) = 1;
%      else
%         prediction_Frontal(i) = 2;
%      end
%  end



end

