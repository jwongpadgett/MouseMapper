function [] = QuiverSplit(posArr, minVal,col)
    if size(posArr,1)<2
        return
        %By Distange
   % elseif(norm(posArr(1,1:2)-posArr(end,1:2))<minVal)
   %     quiver(posArr(1,1),posArr(1,2),2*cosd(posArr(1,3)+90),2*sind(posArr(1,3)+90),'MaxHeadSize',2,'Color',[0,0,1]);
    elseif(length(posArr)<=minVal)
        quiver(posArr(1,1),posArr(1,2),2*cosd(posArr(1,3)+90),2*sind(posArr(1,3)+90),'MaxHeadSize',2,'Color',col);
    else
        QuiverSplit(posArr(1:floor(end/2),:),minVal,col);
        QuiverSplit(posArr(ceil(end/2):end,:),minVal,col);
    end
end