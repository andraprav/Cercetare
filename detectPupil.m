function detectPupil()
%detectPupil detects pupil from picture
%
%
%
%
test_num = '7';
names_list = dir(['./test' '6']);
th = [0.03:0.005:0.115];
thc = 50;%threshold for connected components
i = 3;
for i = 1:size(names_list,1)
    orig_file_name = names_list(i).name;
    if (orig_file_name(1) == '.')
        continue;
    end
    
    I = imread(['./test' '6' '/' orig_file_name]);
    
    
    height = size(I,1);
    width = size(I,2);
    L = [];
    BW = rgb2gray(im2double(I));
    I = imadjust(rgb2gray(im2double(I)),[0 0.2], [0 0.8]);
    
    %BW = imadjust(BW);
    %BW = im2bw(I,0.4);
    BW = I;
    BW2 = zeros(size(I));
    
    %for j = 1:size(th,2)
    edges = edge(I, 'canny');
    %figure; imshow(edges)
    CC = bwconncomp (edges);
    PixId = CC.PixelIdxList;
    numPixels = cellfun(@numel,CC.PixelIdxList); % the number of pixels in each connected component
    n = size(numPixels,2);
    for k=1:n
        if numPixels(k) > thc
            L = [L PixId(k)];
        end
    end
    %end
    %show all conected components
    %         for j=1:size(L,2)
    %              BW(L{j}) = 1;
    %         end
    %         BW = im2bw(BW, .1);
    %         figure; subplot(1,2,1);
    %         imshow(BW)
    L2 = [];
    separ_homogen = [];
    allPars = [];
    
%         figure('units','normalized','position',[0 0 1 1]);
%         subplot(1,3,1); imshow(I); hold on;
    for j=1:size(L,2)
        vector = L{j};
        vector2 = zeros(size(vector,1),2);
        for k = 1:size(vector,1)
            vector2(k,:) = [vector(k)/height rem(vector(k),height)];
        end
        par = CircleFitByTaubin(vector2);
        th = 0:pi/180:2*pi;
        centerX = par(1);
        centerY = par(2);
        radius = par(3);
        %remove compoents that have big radius...
        
        % remove components that corespond to circles outside picture
        if (centerX < 0 || centerX > width)
            continue;
        end
        if (centerY < 0 || centerY > height)
            continue;
        end
        if (centerX - radius < 0 || centerX + radius > width || centerY - radius < 0 || centerY + radius > height)
            continue;
        end
%                 xunit = par(3) * cos(th) + par(1);
%                 yunit = par(3) * sin(th) + par(2);
%                 plot(xunit, yunit);
%                 plot(par(1), par(2), '*r');
        L2 = [L2 L(j)];
        allPars = [allPars;par];
        % compute homogeneity
        
        [columnsInImage rowsInImage] = meshgrid(1:width, 1:height);
        circlePixels = (rowsInImage - centerY).^2 + (columnsInImage - centerX).^2 <= radius.^2;
        imageCirclePixels = BW(circlePixels);
        
        sh = (1 - max(imhist(imageCirclePixels)))/size(imageCirclePixels,1);
        %compute separability
        radius1 = 0.9 * radius;
        radius2 = 1.1 * radius;
        theta = [0:pi/180:2*pi];
        [xc1 yc1] = pol2cart(theta,radius1);
        xc1 = xc1 + centerX;
        yc1 = yc1 + centerY;
        [xc2 yc2] = pol2cart(theta,radius2);
        xc2 = xc2 + centerX;
        yc2 = yc2 + centerY;
        D = zeros(size(xc1,2),1);
        for k = 1:size(xc1,2)
            if isValid(int64(xc1(k)), int64(yc1(k)),int64(xc2(k)), int64(yc2(k)))
                D(k) = BW(int64(xc2(k)),int64(yc2(k))) - BW(int64(xc1(k)),int64(yc1(k)));
            end
        end
        %         if (sum(D~=0) == 0)
        %             mean_value = 0;
        %         else mean_value = sum(D) ./ sum(D~=0);
        %         end
%         if (mean(D) > 0.4)
%             sd = 0;
%         else
        sd = mean(D)/(var(double(D)) + 1);
%         end
        s = sh + sd;
        separ_homogen = [separ_homogen s];
        
    end
%              figure('units','normalized','position',[0 0 1 1]);
%     subplot(1,3,1); imshow(BW)
%         for j=1:size(L2,2)
%             BW2(L2{j}) = 1;
%         end
%         BW2 = im2bw(BW2, .1);
%         subplot(1,3,2); imshow(BW2)
    
    [maxim idx] = max(separ_homogen);
%         subplot(1,3,3);
        %I(L2{idx}) = 1;
    
%     imshow(BW); hold on;
imshow(imread(['./test' '6' '/' orig_file_name])); hold on;
    xunit = allPars(idx,3) * cos(th) + allPars(idx,1);
    yunit = allPars(idx,3) * sin(th) + allPars(idx,2);
    plot(xunit, yunit);
    plot(allPars(idx,1), allPars(idx,2), '*r');
    segmented_image=getframe(gca);
    imwrite(segmented_image.cdata, ['./results' test_num '/' orig_file_name(1:(size(orig_file_name,2)-5)) '_segment.png']);
    close all;
end



end
function result = isValid(x,y,z,t)
result = true;
if (x <= 0 || y <= 0 || z<=0 || t<=0)
    result = false;
end
if (x > 300 || y > 300 || z > 300 || t > 300)
    result = false;
end
end
