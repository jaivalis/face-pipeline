classdef actor
    %ACTOR
    %
    
    properties
        classifier1       % classifier pose: frontal view
        classifier2       % classifier pose: 
        
        appearance_time   % expressed in frame count
    end
    
    methods
        % default constructor
        function obj = actor()
            obj.appearance_time = 0;
            
        end
        
        function conf = get_resemblance( other )
        %GET_RESEMBLANCE Returns the score the actor's classifier returns
        %for the given facedet
            conf = 0;
            switch ( facedet.pose )
                case 1
                    % train frontal classifier

                    return classifier1.predict;

                case 2
                case 3
                    % train classifier 2
                    return classifier2.predict;

            end
        end
        
        function train( facedet )
        %TRAIN Trains the classifier on the given facedet
            switch ( facedet )
                case 1
                    % train frontal classifier
                    %classifier1.train;
                    break;

                case 2
                case 3
                    % train classifier 2
                    classifier2.train;
                    break;

            end
        end
    end
    
end

