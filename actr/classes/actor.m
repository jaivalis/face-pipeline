classdef actor
%ACTOR
%
    properties (Abstract, Access = public)
        appearance_time   % expressed in frame count
        faces
        pconf_avg % average pconf of track
        pconf_angles   % vector per face confidence
        dsifts
    end
    
    methods (Abstract)
        train( obj, other )
        %TRAIN Trains the classifier on the given track
        % INPUT
        % + obj  : this
        % + other: track to train from
        
        get_min_min_diff( obj, other )
        %GET_CONFIDENCE returns the score a given track receives for
        %resemblance to this actor [0, 1]
        % INPUT
        % + obj  : this
        % + other: actor to compare with
        
        get_average_diff( obj, other )
        %GET_CONFIDENCE returns the score a given track receives for
        %resemblance to this actor [0, 1]
        % INPUT
        % + obj  : this
        % + other: actor to compare with
        
        merge( obj, other )
        %MERGE Merges two actors to a new actor object
        % INPUT
        % + obj  : this
        % + other: actors to compare with
    end
    
    methods (Access = public)
        function show_faces( obj )
        %SHOW_FACES Plot the faces used for training the actor classifier
           for i = 1:length(obj.faces)
               face_rect = obj.faces(1:4, i);
               image_num = obj.faces(5, i);
              if image_num == 0
                   continue;
               end
               img = imread(sprintf('./dump/%09d.jpg', image_num));
               face = imcrop(img, [face_rect(1) face_rect(3) face_rect(2) ...
                    - face_rect(1) face_rect(4) - face_rect(3)] );
               subplot(3 , 5, i);
               imshow(face);
               title(num2str(obj.get_angles(i)));
           end
        end

        function [faces, dsifts, pconf_avg, pconf_angles] ...
                = get_face_details( obj, track_facedets )
            pconf = cat(1, track_facedets.pconf);
            pconf_avg = sum(pconf) / length(pconf);
            
            pconf_angles = zeros(13, 1);
            faces = zeros(5, 13);
            dsifts = zeros(3072, 13);
            
            max_confs_ind =  obj.get_max_confs_indexes( track_facedets );

            for i = 1:length( max_confs_ind )
                max_ind = max_confs_ind( i );
                if max_ind == -1 % this angle was not found
                    continue;
                end
                faces(1:4, i) = track_facedets( max_ind ).rect;
                faces(5, i) = track_facedets( max_ind ).frame;
                pconf_angles(i) = track_facedets( max_ind ).pconf;
                % if profile, concat zeros
                if length(track_facedets( max_ind ).dSIFT) == 1792
                    dsifts(:, i)      = cat(1, track_facedets( max_ind ).dSIFT, ...
                        zeros(1280, 1));
                else
                    dsifts(:, i)      = track_facedets( max_ind ).dSIFT;
                end
            end
        end

        function indexes = get_max_confs_indexes( obj, track_facedets )
        % index to track_facedets with the highest confidence per angle
            max_confs = zeros(1, 13) - 200;
            indexes   = zeros(1, 13) - 1;

            for i = 1 : length(track_facedets)
                index = obj.get_index( track_facedets(i, 1).head_pose );

                if max_confs( index ) < track_facedets(i, 1).pconf
                    max_confs( index ) = track_facedets(i, 1).pconf;
                    indexes( index )   = i;
                end
            end
        end

        function index = get_index(obj, head_pose)
            switch head_pose
                case -90
                    index = 1;
                case -75
                    index = 2;
                case -60
                    index = 3;
                case -45
                    index = 4;
                case -30
                    index = 5;
                case -15
                    index = 6;
                case 0
                    index = 7;
                case 15
                    index = 8;
                case 30
                    index = 9;
                case 45
                    index = 10;
                case 60
                    index = 11;
                case 75
                    index = 12;
                case 90
                    index = 13;
                otherwise
                index = -1;
            end
        end
        
        function head_pose = get_angles(obj, index)
            switch index
                case 1,      head_pose = -90;
                case 2,      head_pose = -75;
                case 3,      head_pose = -60;
                case 4,      head_pose = -45;
                case 5,      head_pose = -30;
                case 6,      head_pose = -15;
                case 7,      head_pose = 0;
                case 8,      head_pose = 15;
                case 9,      head_pose = 30;
                case 10,     head_pose = 45;
                case 11,     head_pose = 60;
                case 12,     head_pose = 75;
                case 13,     head_pose = 90;
                otherwise,   head_pose = -1;
            end
        end

    end
    
end