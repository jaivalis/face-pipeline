function image = stitch(img, actor, angle, bck, l, color)
%STITCH Summary of this function goes here

if l == 1 || l == 0
    % resize img so it fits on bck
    res_img = imresize(img, [480, 640]);

    % place image on background:
    bck( 11:490, 11:650, :) = res_img;
else
    bck = img;
end

% place actor on background
top_h    = 80;

if l ~= 0
    rep = actor.get_representative( angle );
    res_rep = imresize( rep, [60, 40] );
    start_h = top_h * l + (l-1)*20;

    bck( start_h:start_h + 59, 801:840, : ) = res_rep;
    
    % draw rectangle around actor rep
    for i = start_h-1:start_h + 60
        bck(i, 800, :) = color;
        bck(i, 841, :) = color;
    end
    for i = 800:841
        bck(start_h-1, i, :) = color;
        bck(start_h+60, i, :) = color;
    end

    % draw two more reps on the sides
    if angle ~= 90 && angle ~= -90
        index = actor.get_index(angle);

        % fetch & output right rep
        for i = index+1 : length(actor.pconf_angles)
            if actor.pconf_angles(i) ~= -200
                right = actor.get_representative( actor.get_angles(i) );

                res_rep = imresize( right, [60, 40] );
                start_h = top_h * l + (l-1)*20;

                bck( start_h:start_h + 59, 861:900, : ) = res_rep;
                break;
            end
        end

        % fetch & output left rep
        for i = index-1 : -1 : 1
            if actor.pconf_angles(i) ~= -200
                left = actor.get_representative( actor.get_angles(i) );

                res_rep = imresize( left, [60, 40] );
                start_h = top_h * l + (l-1)*20;

                bck( start_h:start_h + 59, 741:780, : ) = res_rep;
                break;
            end
        end
    end

end

image = bck;

end