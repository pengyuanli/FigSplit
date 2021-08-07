function [figure_num, separationpoints]=black_margin_detection(im0, display_flag)
 
           [height, width]=size(im0);
%         im0=1-im0;
        
        white_area=(length(find(im0<=0.1)))/numel(im0);
 
        panel_sep_area_size=min(size(im0)/32);%18/2;%15;
        min_panel_size_ratio=0.1;
        
%         threshold=1-mean(max(im0));
%         if threshold<0.085
%             threshold=0.085
%         end
%         if threshold>0.15
%             threshold=0.15;
%         end
       % threshold=0.08;
%        bw = im0>threshold;
        bw=im0>0.085;
        
        bw = imfill(bw,'holes');
        h = fspecial('gaussian', 5, 5);
    %     bw = imfilter(bw,h,'replicate');
    %     figure
    %     imshow([bw,bw0])
 
        % bw = bwareaopen(bw,round(numel(im)/200));
        n1=round(panel_sep_area_size*white_area); 
        dilate_size=4;
        im3=imdilate(bw,ones(n1,n1));
        im3=bw;
    %     figure
    %     imshow([im3,bw])
 
    %     dilate_size=4;
        cc = bwconncomp(im3,dilate_size);
        rp = regionprops(cc,'BoundingBox','Centroid','Area');
    %     rp = regionprops(im3,'BoundingBox');
        max_area=max(cat(1,rp.Area));
        if isempty(rp)
               a_matrix=[a_matrix,1];
               figure_num=1;
               return; %continue;
               
        end
        rp(1);
        (rp(1).BoundingBox(3)-rp(1).BoundingBox(1))*(rp(1).BoundingBox(4)-rp(1).BoundingBox(2));
%       disp('haha')
%       pause
 
        min_panel_size_ratio=0.05;
        max_panel_size_ratio_lim=0.5;
    %     figure
    %     imshow(im,[]);
    %     hold on;
        t=0;
        separationpoints=[];
        for j=1:cc.NumObjects
            if rp(j).BoundingBox(3)*rp(j).BoundingBox(4)>height*width/100 %&& rp(j).Area>min_panel_size_ratio*max_area  %&& max_area>max_panel_size_ratio_lim* size(im3,1)*size(im3,2)
 
                t=t+1;
                separationpoints=[separationpoints;rp(j).BoundingBox];
            if display_flag==1
    %           t=t+1;
                rectangle('Position',rp(j).BoundingBox,'EdgeColor','b','LineWidth',5);
            end
    %             pause
            end
        end
        
        figure_num=t;
        
