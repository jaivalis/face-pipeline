function generate_output( actors, dump_string, result_dir )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    shotpath = fullfile(result_dir, 'shots.txt' );
    bck = imread('res/demo_dashboard.png');
    shots = read_shots(shotpath);
    f = figure(2);
    counter = 1;
    colors = ['r', 'g', 'm', 'y', 'b'];
    col = [[256,0,0]; [0,256,0]; [256,0,256]; [256,256,0]; [0,0,256]];
    text_box_pos = [916, 105;
                    916, 208;
                    916, 309];
    
    for i = 1 : size(shots, 2)
        s1 = shots(1, i);
        s2 = shots(2, i);
        
        facedetfname = sprintf( '%09d_%09d_facedets.mat' ,s1, s2);
        if ~exist(fullfile(result_dir, facedetfname), 'file')
            for z = counter : s2
                img = imread(sprintf('dump/%09d.jpg', counter));
                img = stitch(img, 0, 0, bck, 0, 0);
                counter = counter + 1;
                cla;
                imshow(img);
                %title(rtzhn);
            end
            continue;
        end

        facedets = load(sprintf('results/%09d_%09d_facedets.mat' ,s1, s2));
        facedets = facedets.facedets;
        frames = cat(1, facedets.frame);
        
        for frame = s1 : s2
            frame
            a = get_actors( actors, frame );
%             if length(a) < 2
%                 continue;
%             end
%             if frame < 386
%                 continue;
%             end
            if isempty(a)   % discarded actor
                img = imread(sprintf('dump/%09d.jpg', frame));
                img = stitch(img, 0, 0, bck, 0, 0);
                cla;
                imshow(img);
                title(num2str(frame));
                %saveas(f, sprintf('video/%09d.jpg', frame));
                pause(0.05);
                continue;
            end
            img = imread(sprintf('dump/%09d.jpg', frame));
            [h, w, ~] = size(img);
            for l = 1 : length(a)
                actor = a(l);
                
                shots_           = actor.track_id(:, 1);
                ind              = find( shots_ == i );
                actr_track       = actor.track_id( ind, 2 );
                tmp              = find(frames == frame);
                fds              = facedets(tmp);
                trs              = cat(1, fds.track);
                fd_trck          = fds(find(trs == actr_track));
                angle            = fd_trck.head_pose;
                face_rect(:, l)  = fd_trck.rect;
                
                img = stitch(img, actor, angle, bck, l, col(l,:));
            end
            cla;
            imshow(img);
            hold on;                
            h_ratio = 480 / h;
            w_ratio = 640 / w;
            
            for k = 1 : size(face_rect, 2)
                new_1 = floor(face_rect(1, k)*w_ratio) + 11;
                new_2 = floor(face_rect(2, k)*w_ratio) + 11;
                new_3 = floor(face_rect(3, k)*h_ratio) + 11;
                new_4 = floor(face_rect(4, k)*h_ratio) + 11;
                width  = new_2 - new_1;
                height = new_4 - new_3;
                
                r = rectangle('Position', [new_1, new_3, width, height]);
                set(r,'edgecolor', colors(k));
                
                box = text(text_box_pos(k, 1), text_box_pos(k, 2), a(k).name);
                set(box, 'FontSize', 10);
            end
            set(gca, 'position', [0 0 1 1], 'units', 'normalized');
            %saveas(f, sprintf('video/%09d.jpg', frame));
            pause(0.05);
            clear face_rect;
            
        end
        
    end

end

