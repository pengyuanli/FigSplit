function resultpanels=evaluation(pointsforseparation,im)

pointsforseparation=floor(pointsforseparation);
if ndims(im)==3
    im=im2double(rgb2gray(im));
else
    im=im2double(im);
end

if  max(im(:))>200
    im=im/255;
end

[height, width]=size(im);
wholearea=height*width;

for i=1:size(pointsforseparation,1)
    
    pointsforseparation(i,1)=ceil(pointsforseparation(i,1));
    pointsforseparation(i,2)=ceil(pointsforseparation(i,2));
    pointsforseparation(i,3)=ceil(pointsforseparation(i,3));
    pointsforseparation(i,4)=ceil(pointsforseparation(i,4));
    
    if pointsforseparation(i,1)<=1
        pointsforseparation(i,1)=1;
    end
    if pointsforseparation(i,2)<=1
        pointsforseparation(i,2)=1;
    end
    if pointsforseparation(i,1)+pointsforseparation(i,3)>width-2
        pointsforseparation(i,3)=width-pointsforseparation(i,1)-3;
    end
    if pointsforseparation(i,3)<2
        pointsforseparation(i,3)=1;
    end
    if pointsforseparation(i,2)+pointsforseparation(i,4)>height-2
        pointsforseparation(i,4)=height-pointsforseparation(i,2)-3;
    end
    if pointsforseparation(i,4)<2
        pointsforseparation(i,4)=1;
    end
    
    
    
end


resultpanels=[];
%% Generate the vector for every candidate sub-panel


%% Check the overlap part
evaluationmatrix=zeros(size(pointsforseparation,1),1);
for i=1:size(pointsforseparation,1)
    if evaluationmatrix(i)==0
    findbigarea= pointsforseparation(i,3)*pointsforseparation(i,4)/wholearea;   
    if findbigarea>0.8
        evaluationmatrix(i)=1;
    end
    end
    
end

for i=1:size(pointsforseparation,1)
    for j=1:size(pointsforseparation,1)
        if  evaluationmatrix(i)==0 && evaluationmatrix(j)==0
            if i~=j
                
                overlapratio= bboxOverlapRatio(pointsforseparation(i,:),pointsforseparation(j,:),'Min');
                
                if (pointsforseparation(i,3)*pointsforseparation(i,4))>(pointsforseparation(j,3)*pointsforseparation(j,4))
                    overlapratio=overlapratio*pointsforseparation(j,3)*pointsforseparation(j,4)/pointsforseparation(i,3)/pointsforseparation(i,4);
                end
                if overlapratio>=0.95
                    evaluationmatrix(i)=1;
                end
                if overlapratio<0.95 && overlapratio>0.1%.05
                    pointAx=min(pointsforseparation(i,1),pointsforseparation(j,1));
                    pointAy=min(pointsforseparation(i,2),pointsforseparation(j,2));
                    pointBx=max(pointsforseparation(i,1)+pointsforseparation(i,3),pointsforseparation(j,1)+pointsforseparation(j,3));
                    pointCy=max(pointsforseparation(i,2)+pointsforseparation(i,4),pointsforseparation(j,2)+pointsforseparation(j,4));
                    % Merge these two
                    evaluationmatrix(i)=1;
                    
                    pointsforseparation(j,:)=[pointAx,pointAy,pointBx-pointAx,pointCy-pointAy];
                end
            end
        end
    end
end

%% Threshold for the sub-panels
for i=1:size(pointsforseparation,1)
    if evaluationmatrix(i)==0
        
       
        if pointsforseparation(i,1)<=1
            pointsforseparation(i,1)=1;
        end
        if pointsforseparation(i,2)<=1
            pointsforseparation(i,2)=1;
        end
        if pointsforseparation(i,1)+pointsforseparation(i,3)>width-2
            pointsforseparation(i,3)=width-pointsforseparation(i,1)-3;
        end
        if pointsforseparation(i,3)<2
            pointsforseparation(i,3)=1;
        end
        if pointsforseparation(i,2)+pointsforseparation(i,4)>height-2
            pointsforseparation(i,4)=height-pointsforseparation(i,2)-3;
        end
        if pointsforseparation(i,4)<2
            pointsforseparation(i,4)=1;
        end
        
        
        if pointsforseparation(i,3)<(width/20)
            
            evaluationmatrix(i)=1;
        end
        if pointsforseparation(i,4)<(height/20)
            
            evaluationmatrix(i)=1;
        end
        
        if pointsforseparation(i,3)*pointsforseparation(i,4)<width*height/100
           
            evaluationmatrix(i)=1;
        end
        
        if evaluationmatrix(i)==0
            panels=im(pointsforseparation(i,2):pointsforseparation(i,2)+pointsforseparation(i,4),pointsforseparation(i,1):pointsforseparation(i,1)+pointsforseparation(i,3));
            enscore=entropy(panels);
            darkarearatio=sum(sum(panels<0.9))/numel(panels);
            if enscore<0.6
                evaluationmatrix(i)=1;
              
%                 display('method to evaluate blank imaage is wrong');
            end
            if darkarearatio<0.01
                evaluationmatrix(i)=1;
            end
        end
       
    end
end



% to find similar panel in the image
if size(pointsforseparation,1)>0
    maxwidth=max(pointsforseparation(:,3));
    maxheight=max(pointsforseparation(:,4));
end

countarea=0;
averagedarkarea=0;
for i=1:size(pointsforseparation,1)
    if evaluationmatrix(i)==0
        countarea=pointsforseparation(i,3)*pointsforseparation(i,4)+countarea;
        resultpanels=[resultpanels;pointsforseparation(i,:)];
        panels=im(pointsforseparation(i,2):pointsforseparation(i,2)+pointsforseparation(i,4),pointsforseparation(i,1):pointsforseparation(i,1)+pointsforseparation(i,3));
        averagedarkarea=averagedarkarea+sum(sum(panels<0.9));
        
    end
end

if sum(sum(im<0.1))/numel(im)<0.5
if averagedarkarea<0.45*sum(sum(im<0.9))
    resultpanels=[1,1,width-1,height-1];
end
end
averagedarkarea=min(averagedarkarea/size(resultpanels,1),0.5);


pointsforseparation=resultpanels;
resultpanels=[];
if size(pointsforseparation,1)>0
    maxwidth=max(pointsforseparation(:,3));
    maxheight=max(pointsforseparation(:,4));
    
end

for i=1:size(pointsforseparation,1)
    if ((pointsforseparation(i,3)<maxwidth/6 ||pointsforseparation(i,4)<maxheight/6) )% && ((pointsforseparation(i,3)/pointsforseparation(i,4)>2 || pointsforseparation(i,4)/pointsforseparation(i,3)>2))
        panels=im(pointsforseparation(i,2):pointsforseparation(i,2)+pointsforseparation(i,4),pointsforseparation(i,1):pointsforseparation(i,1)+pointsforseparation(i,3));
        iswords=sum(sum(panels<0.9))/numel(panels);
        if iswords>0.6
            resultpanels=[resultpanels;pointsforseparation(i,:)];
        end
    else
        resultpanels=[resultpanels;pointsforseparation(i,:)];
    end
end




%           imshow(im);
%          hold on
%          for i=1:size(resultpanels, 1)
%
%                 rectangle('Position',resultpanels(i,:),'EdgeColor','b','LineWidth',5);
%
%          end
%          pause;
%          close all;

%% Automatically complement

% To find the gap
horgap=floor(width/30);
vecgap=floor(height/30);
% findhorgap=0;
% findvecgap=0;
%
% if size(resultpanels,1)>1
%
% table1=tabulate(resultpanels(:,1));
% [F1,I1]=max(table1(:,2));
%
%
% table2=tabulate(resultpanels(:,2));
% [F2,I2]=max(table2(:,2));
%
%
% if F1>F2
%     findhorgap=1;
%     I1=max(find(table1(:,2)==F1));
%     result1=table1(I1,1);
% else
%     findvecgap=1;
%     I2=max(find(table2(:,2)==F2));
%     result2=table2(I2,1);
% end
%
% if findhorgap==1
% table=tabulate(resultpanels(:,3));
% [F,I]=max(table(:,2));
% I=max(find(table(:,2)==F));
% result=table(I,1);
% end
%
% if findvecgap==1
% table=tabulate(resultpanels(:,4));
% [F,I]=max(table(:,2));
% I=max(find(table(:,2)==F));
% result=table(I,1);
% end
%
% end

% Complement

numofpanel=size(resultpanels,1);
i=1;
if size(pointsforseparation,1)>0
    maxwidth=max(pointsforseparation(:,3));
    maxheight=max(pointsforseparation(:,4));
end

while i<=numofpanel
    numofpanel=size(resultpanels,1);
    
    if (resultpanels(i,3)>maxwidth*0.5 && resultpanels(i,4)>maxheight*0.5) || (resultpanels(i,3)>width/5 && resultpanels(i,4)>height/5)
        %Up
        if resultpanels(i,2)-vecgap-resultpanels(i,4)>0 && resultpanels(i,1)+resultpanels(i,3)<width
            panels=im(resultpanels(i,2)-vecgap-resultpanels(i,4):resultpanels(i,2)-vecgap,resultpanels(i,1):resultpanels(i,1)+resultpanels(i,3));
            work=0;
            
            %          entropy(panels)
            if sum(sum(panels<0.9))>=(0.8*averagedarkarea*numel(panels)) && entropy(panels)>0.5
%                 0.8*averagedarkarea
%                 sum(sum(panels<0.9))
%                 close all;
%                 imshow(panels);
%                 pause;
%                 close all;
                for j=1:numofpanel
                    overlapratio= bboxOverlapRatio([resultpanels(i,1),resultpanels(i,2)-vecgap-resultpanels(i,4),resultpanels(i,3),resultpanels(i,4)],resultpanels(j,:),'Min');
                    if overlapratio>0.01
                        work=1;
                    end
                end
                
                if work==0
                    resultpanels=[resultpanels;resultpanels(i,1),resultpanels(i,2)-vecgap-resultpanels(i,4),resultpanels(i,3),resultpanels(i,4)];
                end
            end
        end
        % Down
        if resultpanels(i,2)+vecgap+2*resultpanels(i,4)<height && resultpanels(i,1)+resultpanels(i,3)<width
            panels=im(resultpanels(i,2)+vecgap+resultpanels(i,4):resultpanels(i,2)+vecgap+2*resultpanels(i,4),resultpanels(i,1):resultpanels(i,1)+resultpanels(i,3));
            
            
            work=0;
            %          entropy(panels)
            if sum(sum(panels<0.9))>=(0.8*averagedarkarea*numel(panels)) && entropy(panels)>0.5
%                 0.8*averagedarkarea
%                 sum(sum(panels<0.9))
%                 close all;
%                 imshow(panels);
%                 pause;
%                 close all;
                for j=1:numofpanel
                    overlapratio= bboxOverlapRatio([resultpanels(i,1),resultpanels(i,2)+vecgap+resultpanels(i,4),resultpanels(i,3),resultpanels(i,4)],resultpanels(j,:),'Min');
                    if overlapratio>0.01
                        work=1;
                    end
                end
                if work==0
                    resultpanels=[resultpanels;resultpanels(i,1),resultpanels(i,2)+vecgap+resultpanels(i,4),resultpanels(i,3),resultpanels(i,4)];
                end
            end
        end
        % Left
        if resultpanels(i,1)-horgap-resultpanels(i,3)>1 && resultpanels(i,2)+resultpanels(i,4)<height
            panels=im(resultpanels(i,2):resultpanels(i,2)+resultpanels(i,4),resultpanels(i,1)-horgap-resultpanels(i,3):resultpanels(i,1)-horgap);
            
            
            work=0;
            %          entropy(panels)
            if sum(sum(panels<0.9))>=(0.8*averagedarkarea*numel(panels)) && entropy(panels)>0.5
%                 0.8*averagedarkarea
%                 sum(sum(panels<0.9))
%                 close all;
%                 imshow(panels);
%                 pause;
%                 close all;
                for j=1:numofpanel
                    overlapratio= bboxOverlapRatio([resultpanels(i,1)-horgap-resultpanels(i,3),resultpanels(i,2),resultpanels(i,3),resultpanels(i,4)],resultpanels(j,:),'Min');
                    if overlapratio>0.01
                        work=1;
                    end
                end
                if work==0
                    resultpanels=[resultpanels;resultpanels(i,1)-horgap-resultpanels(i,3),resultpanels(i,2),resultpanels(i,3),resultpanels(i,4)];
                end
            end
        end
        % Right
        if resultpanels(i,1)+resultpanels(i,3)+horgap+resultpanels(i,3)<width && resultpanels(i,2)+resultpanels(i,4)<height
            panels=im(resultpanels(i,2):resultpanels(i,2)+resultpanels(i,4),resultpanels(i,1)+resultpanels(i,3)+horgap:resultpanels(i,1)+resultpanels(i,3)+horgap+resultpanels(i,3));
            
            
            work=0;
            %          entropy(panels)
            if sum(sum(panels<0.9))>=(0.8*averagedarkarea*numel(panels)) && entropy(panels)>0.5
%                 0.8*averagedarkarea
%                 sum(sum(panels<0.9))
%                 close all;
%                 imshow(panels);
%                 pause;
%                 close all;
                for j=1:numofpanel
                    overlapratio= bboxOverlapRatio([resultpanels(i,1)+resultpanels(i,3)+horgap,resultpanels(i,2),resultpanels(i,3),resultpanels(i,4)],resultpanels(j,:),'Min');
                    if overlapratio>0.01
                        work=1;
                    end
                end
                if work==0
                    resultpanels=[resultpanels;resultpanels(i,1)+resultpanels(i,3)+horgap,resultpanels(i,2),resultpanels(i,3),resultpanels(i,4)];
                end
            end
        end
        
    end
    
    numofpanel=size(resultpanels,1);
    i=i+1;
    
end

%
%
%% At the end
% emptytop=min(resultpanels(:,2));
% emptyleft=min(resultpanels(:,1));
% emptydown=max(resultpanels(:,2)+resultpanels(:,4));
% emptyright=max(resultpanels(:,1)+resultpanels(:,3));
% if emptytop>height/3
%     resultpanels
% end
%
% if emptyleft>width/3
%
% end
%
% if emptydown<height*2/3
%
% end
%
% if emptyright<width*2/3
%
% end

if size(resultpanels,1)<2
    resultpanels=[1,1,width,height];
end

if min(resultpanels(:,2))>height/(min(5,1+size(resultpanels,1)))
    panels=im(10:min(resultpanels(:,2))-10,min(pointsforseparation(:,1)):width-min(pointsforseparation(:,1)));
            
    if sum(sum(panels<0.9))>=(0.2*averagedarkarea*numel(panels))
        resultpanels=[resultpanels;10,10,width-20,min(resultpanels(:,2))-10];
    end
end




