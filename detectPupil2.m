function  detectIris()
%detectIris detect iris with Hough transform
%   goes through all pics in folder with test_num number
%   goes through all radius from 20-60 to 350-390
%   computes centers and retains them with metrics associated
%   gets the circle with the max metric (from all radius)
%   prints picture with associated max circle in 'results' folder
test_num = '7';
names_list = dir(['./test' test_num]);
for i = 1:size(names_list,1)
    %     orig_file_name = 'C10_S2_I2.tiff';
    orig_file_name = names_list(i).name;
    if (orig_file_name(1) == '.' || names_list(i).isdir())
        continue;
    end
    I = imread(['./test' test_num '/' orig_file_name]);
    I = imadjust(rgb2gray(im2double(I)),[0 0.1], [0 1]);
    figure;  imshow(I);
    I = imcomplement(I);
    figure;  imshow(I);
    I = I*255;
    Rmin = 20;
    Rmax = 30;
    I(I>200) = 255;
    I(I<=220) = 0;
    %I = im2bw( I, .9 );
    figure;  imshow(I);
    centers = [];
    radii = [];
    metric = [];
    %imshow(I);
    while (Rmin <= 50)
        %[centers, radii, metric] = imfindcircles(BW, [Rmin Rmax]);
        %stats = [regionprops(BW); regionprops(not(BW))];
        [centersDark, radiiDark, metricDark] = imfindcircles(I, [Rmin Rmax], 'ObjectPolarity','bright','sensitivity', .93, ...
            'EdgeThreshold', .06);
        Rmin = Rmin + 10;
        Rmax = Rmax + 10;
        if (size(centersDark,1) > 0)
            centers = [centers ; centersDark(1,:)];
            radii = [radii ; radiiDark(1,:)];
            metric = [metric ; metricDark(1,:)];
        end
        
    end
    [maxim idx] = max(metric);
    viscircles(centers(idx,:), radii(idx,:),'EdgeColor','r');
    %     segmented_image=getframe(gca);
    %     imwrite(segmented_image.cdata, ['./results' '10' '/' orig_file_name(1:(size(orig_file_name,2)-5)) '_pupil.png']);
    %     close all;
end



