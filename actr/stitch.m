function image = stitch(img, actor, rep, face_rect, l, num_a)
%STITCH Summary of this function goes here
%   Detailed explanation goes here

if l == 1
    bck = imread('res/demo_dashboard.png');
    % resize img so it fits on bck
    res_img = imresize(img, [480, 640]);

    % place image on background:
    bck( 11:490, 11:650, :) = res_img;
else
    bck = img;
end

% place actor on background
top_h    = 80;

res_rep = imresize( rep, [60, 40] );
start_h = top_h * l + (l-1)*20;

part = bck( start_h:start_h + 59, 801:840, : );
bck( start_h:start_h + 59, 801:840, : ) = res_rep;


%     [ rh, rw, ~ ] = size(rep);
%     scale         = extend / rw;
%     rep           = imresize(rep, scale);
%     [ ende, a, b ] = size(rep);
%     segm = h / num_a;
%     
%     up = segm * (l - 1) + 1;
%     
%     image(up:up + ende - 1, w + 1 : w + a, :) = rep;
image = bck;

end