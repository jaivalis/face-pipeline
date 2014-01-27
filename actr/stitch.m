function image = stitch(img, actor, rep, face_rect, l, num_a)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    [ h, w, ~ ] = size(img);
    extend      = 100;
    if l == 1
        image = cat(2, img, zeros(h, extend, 3));
    else
        image = img;
        w = w - extend;
    end
    [ rh, rw, ~ ] = size(rep);
    scale         = extend / rw;
    rep           = imresize(rep, scale);
    [ ende, a, b ] = size(rep);
    segm = h / num_a;
    
    up = segm * (l - 1) + 1;
    
    image(up:up + ende - 1, w + 1 : w + a, :) = rep;
    

end

