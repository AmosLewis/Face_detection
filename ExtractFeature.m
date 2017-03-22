function  Feature = ExtractFeature(I,Point,N_FEATURES,W_FEATURES)
%%%EXTRACTFEATURE 此处显示有关此函数的摘要%%
%   I 输入的120*100图像 
%   Point 返回的值
%   N_FEATURES 特征的个数
%   W_FEATURES 小框的宽度 默认5*5 或者 10*10
%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Row,Col] = size(I);
%%%%%%%%%%计算积分图%%%%%%%%%%
I_Integral=zeros(Row,Col);
I=double(I);
for i=1:Row
    for j=1:Col
        if i==1 && j==1             %积分图像左上角
            I_Integral(i,j)=I(i,j);
        elseif i==1 && j~=1         %积分图像第一行
            I_Integral(i,j)=I_Integral(i,j-1)+I(i,j);
        elseif i~=1 && j==1         %积分图像第一列
            I_Integral(i,j)=I_Integral(i-1,j)+I(i,j);
        else                        %积分图像其它像素
            I_Integral(i,j)=I(i,j)+I_Integral(i-1,j)+I_Integral(i,j-1)-I_Integral(i-1,j-1);  
        end
    end
end

%%%%%%%%%%选取特征点%%%%%%%%%%
% Point(:,1)=floor(Point(:,1)+Row/6-1); %去掉头发，只取下面20-120部份
% Point(:,3)=floor(Point(:,3)+Row/6-1); %只是120*100时候 floor 可以不加

%%%%%%%%%%计算特征值%%%%%%%%%%
for i = 1:N_FEATURES
    %第一组框% 
    x=Point(i,1);
    y=Point(i,2);
    C = I_Integral(x,y);
    if (x==1) && (y==1)%单独处理第一个点
        Point(i,5) = I_Integral(x,y);
    elseif (y <= W_FEATURES)&&(y <= W_FEATURES)%单独处理前十列点
        Point(i,5) = C;
    elseif y <= W_FEATURES%单独处理前十列点
        B = I_Integral(x-W_FEATURES,y);
        Point(i,5) = C-B;
    elseif x <= W_FEATURES%单独处理前十行点
        D = I_Integral(x,y-W_FEATURES);
        Point(i,5) = C-D;
    else
        A = I_Integral(x-W_FEATURES,y-W_FEATURES);
        B = I_Integral(x-W_FEATURES,y);
        D = I_Integral(x,y-W_FEATURES);
        Point(i,5) = C+A-B-D;
    end
    %第二组框% 
    x=Point(i,3);%第二个图的横坐标
    y=Point(i,4);%第二个图的纵坐标
    C = I_Integral(x,y);
    if (x==1) && (y==1)%单独处理第一个点
        Point(i,6) = I_Integral(x,y);
    elseif (y <= W_FEATURES)&&(y <= W_FEATURES)%单独处理前十列点
        Point(i,6) = C;
    elseif y <= W_FEATURES%单独处理前十列点
        B = I_Integral(x-W_FEATURES,y);
        Point(i,6) = C-B;
    elseif x <= W_FEATURES%单独处理前十行点
        D = I_Integral(x,y-W_FEATURES);
        Point(i,6) = C-D;
    else
        A = I_Integral(x-W_FEATURES,y-W_FEATURES);
        B = I_Integral(x-W_FEATURES,y);
        D = I_Integral(x,y-W_FEATURES);
        Point(i,6) = C+A-B-D;
    end
    Point(i,7) =Point(i,5) - Point(i,6);
end
Feature = Point(:,7);
end

