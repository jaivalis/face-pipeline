function a = get_actors( actors, frame )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    index = 1;
    for i = 1 : length(actors)
        if ~ isempty(find(actors(i).appearing_frames == frame))
            a(index) = actors(i);
            index = index + 1;
        end
    end
    
    if index == 1
        a = [];
    end
            
        
end

