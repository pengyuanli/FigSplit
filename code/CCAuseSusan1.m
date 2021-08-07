%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Rotated Histogram                   %
%                                                        %
%                       Pengyuan Li                      %
%                                                        %
%                       12/19/2015                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pfs=CCAuseSusan1(Susanim)



global panelsnum;
global storepanels;
storepanels=[];
[height,width]=size(Susanim);
[Gmag,Gdir] = imgradient(Susanim);
widtharea=sum(max(Gmag, [], 1)<0.05);
heightarea=sum(max(Gmag, [], 2)<0.05);

if widtharea+heightarea>20
    [height,width]=size(Susanim);
    im1=Susanim(10:height-10,10:width-10);
    
    im1=1-im1;
    se = strel('line',7,90);% Need to try 7, 5, 3, 9
    se1 = strel('line',7,0);%
    BW2 = imdilate(im1,se);
    BW2 = imdilate(BW2,se1);
    %     BW2=im2bw(BW2);
    BW2=1-BW2;
    display_flag=0;
    [panelsnum,storepanels]=white_margin_detection(BW2, display_flag);
    storepanels=evaluation(storepanels,Susanim);
    
    
end

% storepanels=evaluation(storepanels,BW2);
%
panelsnum=size(storepanels,1);

if panelsnum<2 % && sum(sum(im0>0.85))/(height*width)<0.4
    
    %  For stitched image
    
    BW=im2bw(Susanim);
    [height, width]=size(BW);
    
    BW=1-BW;
    
    
    [height, width]=size(BW);
    wholearea=height*width;
    
    hist0degree=zeros(width,1);
    hist90degree=zeros(height,1);
    
    for i=1:width
        hist0degree(i)=sum(BW(:,i));
    end
    
    pks=findpeaks(hist0degree);
    if isempty(pks)
        pks=height;
    end
    
    %[pks0, locs0, w0, p0]=findpeaks(hist0degree,'MinPeakHeight',0.85*height,'MinPeakDistance',width/20);
    
    [pks0, locs0, w0, p0]=findpeaks(hist0degree,'MinPeakHeight',0.85*height,'MinPeakDistance',width/10);
    if length(locs0)>7
        [pks0, locs0, w0, p0]=findpeaks(hist0degree,'MinPeakHeight',0.9*height,'MinPeakDistance',width/10);
        
    end
    if length(locs0)>7
        [pks0, locs0, w0, p0]=findpeaks(hist0degree,'MinPeakHeight',0.95*height,'MinPeakDistance',width/10);
    end
    
    if isempty(locs0)
        [pks0, locs0, w0, p0]=findpeaks(hist0degree,'MinPeakHeight',0.7*max(max(pks),0.7*height),'MinPeakDistance',width/10);
        if length(locs0)>7
            [pks0, locs0, w0, p0]=findpeaks(hist0degree,'MinPeakHeight',0.8*max(max(pks),0.7*height),'MinPeakDistance',width/10);
            
        end
    end
    if ~isempty(locs0)
        maxhorizontal=max(hist0degree(locs0))/height;
    else
        maxhorizontal=0;
    end
    
    if isempty(locs0)
        locs0=[5;locs0];
    end
    if locs0(1)>(width/min(10,3*length(locs0)))
        locs0=[5;locs0];
        
    end
    if locs0(length(locs0))<(width-width/min(10,3*length(locs0)))
        locs0=[locs0;width-5];
    end
    
    for i=1:height
        hist90degree(i)=sum(BW(i,:));
    end
    
    pks=findpeaks(hist90degree);
    
    if isempty(pks)
        pks=width;
    end
    
    [pks90, locs90, w90, p90]=findpeaks(hist90degree,'MinPeakHeight',0.85*width,'MinPeakDistance',height/10);
    if length(locs90)>7
        
        [pks90, locs90, w90, p90]=findpeaks(hist90degree,'MinPeakHeight',0.9*width,'MinPeakDistance',height/10);
        
    end
    if length(locs90)>7
        [pks90, locs90, w90, p90]=findpeaks(hist90degree,'MinPeakHeight',0.95*width,'MinPeakDistance',height/10);
    end
    
    if isempty(locs90)
        [pks90, locs90, w90, p90]=findpeaks(hist90degree,'MinPeakHeight',0.7*max(max(pks),0.7*width),'MinPeakDistance',height/10);
        if length(locs90)>7
            
            [pks90, locs90, w90, p90]=findpeaks(hist90degree,'MinPeakHeight',0.8*max(max(pks),0.7*width),'MinPeakDistance',height/10);
            
        end
    end
    if ~isempty(locs90)
        maxvertical=max(hist90degree(locs90))/width;
    else
        maxvertical=0;
    end
    if isempty(locs90)
        locs90=[5;locs90];
    end
    if locs90(1)>(height/min(10,3*length(locs90)))
        locs90=[5;locs90];
        
    end
    if locs90(length(locs90))<(height-height/min(10,3*length(locs90)))
        locs90=[locs90;height-5];
    end
    
    
    
    panelsnum=0;
    storepanels=[];
    locs0backup=locs0;
    locs90backup=locs90;
    
    
    if length(locs0)>2 || length(locs90)>2
        
        if maxvertical> maxhorizontal
            
            for l=1:(length(locs90)-1)
                if (locs90(l+1)-locs90(l))*width>wholearea/20 % Need to change,
                    panels=[];
                    panels=BW(locs90(l):locs90(l+1),1:width-1);
                    %                     close all
                    %                     imshow(panels);
                    %                     pause;
                    
                    
                    separateit_second(panels, locs90(l), locs90(l+1),1,width-1,height,width);
                else if (locs90(l+1)-locs90(l))>height/10
                        
                        addflag=1;
                        for p=1:size(storepanels,1)
                            overlapratio= bboxOverlapRatio(storepanels(p,:),[1, locs90(l), width-1, locs90(l+1)-locs90(l)],'Min');
                            if overlapratio>0.1
                                addflag=0;
                                
                            end
                        end
                        if addflag==1
                            storepanels=[storepanels;1, locs90(l), width-1, locs90(l+1)-locs90(l)];
                            panelsnum=panelsnum+1;
                            worknum=1;
                        end
                        
                        
                        
                    end
                end
            end
            
        else
            for i=1:(length(locs0)-1)
                
                if height*(locs0(i+1)-locs0(i))>wholearea/20 % Need to change,
                    panels=[];
                    panels=BW(1:height-1,locs0(i):locs0(i+1));
                    %                     close all
                    %                     imshow(panels);
                    %                     pause;
                    
                    
                    separateit_second(panels, 1, height-1,locs0(i),locs0(i+1),height,width);
                else if (locs0(i+1)-locs0(i))>width/10
                        
                        addflag=1;
                        for p=1:size(storepanels,1)
                            overlapratio= bboxOverlapRatio(storepanels(p,:),[locs0(i), 1, locs0(i+1)-locs0(i), height-1],'Min');
                            if overlapratio>0.1
                                addflag=0;
                                
                            end
                        end
                        if addflag==1
                            storepanels=[storepanels;locs0(i), 1, locs0(i+1)-locs0(i), height-1];
                            panelsnum=panelsnum+1;
                            worknum=1;
                        end
                        
                        
                        
                    end
                end
                
            end
            
            
            
        end
        
    end
    
    storepanels=evaluation(storepanels,im0);
    panelsnum=size(storepanels,1);
    
end


if panelsnum<2
    panelsnum=1;
    storepanels=[1, 1, width-1, height-1];
end

pfs=storepanels;




% close all;
% imshow(Susanim);
% hold on
% for i=1:size(pointsforseparation, 1)
%
%     rectangle('Position',pointsforseparation(i,:),'EdgeColor','b','LineWidth',5);
%
% end
% pause(.5);





