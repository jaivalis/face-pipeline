classdef actor
%ACTOR
%

    properties (Abstract)
        appearance_time   % expressed in frame count
    end
    
    methods 

    end
    
    methods (Abstract)
        train( obj, other )
        %TRAIN Trains the classifier on the given track
        % INPUT
        % + obj  : this
        % + other: track to train from
        
        get_model_diff( obj, other )
        %GET_CONFIDENCE returns the score a given track receives for
        %resemblance to this actor [0, 1]
        % INPUT
        % + obj  : this
        % + other: actor to compare with
    end
    
end