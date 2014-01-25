function generate_output( actors, dump_string, result_dir )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    shotpath = fullfile(result_dir, 'shots.txt' );
    shots = read_shots(shotpath);
    figure(2);
    
    for i = 1 : size(shots, 2)
        s1 = shots(1, i);
        s2 = shots(2, i);
        
        facedetfname = sprintf( '%09d_%09d_facedets.mat' ,s1, s2);
        if ~exist(fullfile(result_dir, facedetfname), 'file')
            continue;
        end

        facedets = load(sprintf('results/%09d_%09d_facedets.mat' ,s1, s2));
        facedets = facedets.facedets;
        frames = cat(1, facedets.frame);
        uframes = unique( frames );
        
        for j = 1 : length(uframes)
            a = get_actors( actors, uframes(j) );
            if isempty(a)   % discarded actor
                continue;
            end
            img = imread(sprintf('dump/%09d.jpg', uframes(j)));
            imshow(img);
            for l = 1 : length(a)
                actor = a(l);
                
                shots_           = actor.track_id(:, 1);
                ind              = find( shots_ == i );
                actr_track       = actor.track_id( ind, 2 );
                tmp              = find(frames == uframes(j));
                fds              = facedets(tmp);
                trs              = cat(1, fds.track);
                fd_trck          = fds(find(trs == actr_track));
                angle            = fd_trck.head_pose;
                rep              = actor.get_representative( angle );
                face_rect(:, l)  = fd_trck.rect;
                img = stitch(img, actor, rep, face_rect, l, length(a));
            end
            imshow(img);
            hold on;
            for k = 1 : size(face_rect, 2)
                rectangle('Position', [face_rect(1, k) face_rect(3, k) face_rect(2, k) ...
                    - face_rect(1, k) face_rect(4, k) - face_rect(3, k)] );
            end
            hold off;
            % pause(1/48);
        end
        
    end

end

