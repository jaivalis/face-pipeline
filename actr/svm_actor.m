classdef svm_actor < actor
    %SVM_ACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        classifier1       % frontal view classifier 
        classifier2       % side view classifier
    end
    
    methods
        function obj = svm_actor( track_facedets )
            obj@actor();
        end
        
        function train( obj, other )
            training_samples
        end
        
        function conf = get_confidence( obj, other )
        %GET_RESEMBLANCE Returns the score the actor's classifier returns
        %for the given facedet
            conf = 0;
            switch ( facedet.pose )
                case 1
                    % train frontal classifier


                case 2
                case 3
                    % train classifier 2
                    

            end
        end
    end
    
end

