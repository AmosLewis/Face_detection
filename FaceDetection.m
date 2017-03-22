 tic;
 clc;
 clear;
 Min_dis = 1;
 IMAGE_DATA_N =110;%110个原始数据
 IMAGE_DATA_ROW = 56;%原始数据归一化112*92
 IMAGE_DATA_COL = 45;
 N_FEATURES = 1000;
 W_FEATURES = 5;%feature 的宽度
 Features =zeros(N_FEATURES,IMAGE_DATA_N);% N_FEATURES*110 features 训练集的特征值
 Features2 =zeros(N_FEATURES,IMAGE_DATA_N);% N_FEATURES*110 features 用于计算欧式距离 
 Point1 = rand(N_FEATURES,4);%随机生成点 用于5*5计算特征 7列[x;y;X;Y;xy面积;XY面积;特征值]
 Point1(:,[1,3]) = ceil(Point1(:,[1,3])* IMAGE_DATA_ROW);
 Point1(:,[2,4]) = ceil(Point1(:,[2,4])* IMAGE_DATA_COL);
 Point = [Point1,zeros(N_FEATURES,3)];%用于ExtractFeature的输入参数
 Image_Slide = zeros(IMAGE_DATA_ROW,IMAGE_DATA_COL);%存放对test图像处理的120*100的滑块信息
 STEP = 10;%滑块的步长
 dis = zeros(1,IMAGE_DATA_N);%distance
 %THRESHOLD = 39000; 对应112*92
% THRESHOLD = 23000;%test2:19000-22000 % test6 : 23000-%4013: 20000-25000 %test3 23000-25000%Dinner 23000%test5 
THRESHOLD = 23000;

%input database%
Image_Data = {0};%set a cell array to put data
str = 'pic\';
for i=1:IMAGE_DATA_N%
    Image_Data{i} = imread([str,num2str(i),'.pgm']);
    Image_Data{i} = imresize(Image_Data{i},[IMAGE_DATA_ROW,IMAGE_DATA_COL]);%resize the image
    %gaussian%
    sigma=6;%标准差大小  
    window=double(uint8(3*sigma)*2+1);%窗口大小一半为3*sigma  
    H=fspecial('gaussian', window, sigma);%fspecial('gaussian', hsize, sigma)产生滤波模板  
    %为了不出现黑边，使用参数'replicate'（输入图像的外部边界通过复制内部边界的值来扩展）  
    Image_Data{i}=imfilter(Image_Data{i},H,'replicate'); 
    %ExtractFeature%
    Features(:,i) = ExtractFeature( Image_Data{i},Point,N_FEATURES,W_FEATURES);
end

%input test image%
Image_Test{1} = imread('test3.jpg');
imshow(Image_Test{1,1});%显示图像 并用于画矩形
hold on;
%gaussian滤波%
sigma=6;%标准差大小  
window=double(uint8(3*sigma)*2+1);%窗口大小一半为3*sigma  
H=fspecial('gaussian', window, sigma);%fspecial('gaussian', hsize, sigma)产生滤波模板  
%为了不出现黑边，使用参数'replicate'（输入图像的外部边界通过复制内部边界的值来扩展）  
Image_Test{1,1}=imfilter(Image_Test{1,1},H,'replicate');  

Image_Test{1} = rgb2gray(Image_Test{1});%用于保存原始图像信息 彩色图像变成灰度图像
Image_Test{2} = Image_Test{1};%用于暂存中间产生的缩小图像
[Image_Test_Row,Image_Test_Col]=size(Image_Test{2});%找出test图像初始化长宽 N_FEATURES0 1000
Point_R =[ ones(1,2),ones(1,1)*IMAGE_DATA_COL,ones(1,1)*IMAGE_DATA_ROW,ones(1,1)];%用于画矩形输入[x,y,w,h,score]
%find all subtest image%
%行数>120 并且 列数>100就一直寻找%
N_Shrink = 0;%缩小的次数,用于计算画矩形时候的位子。
Rec = 1;%矩形框的编号
while ((Image_Test_Row>=IMAGE_DATA_ROW) && (Image_Test_Col>=IMAGE_DATA_COL))
    %find 120*100 滑块%
    Image_Big = Image_Test{2}; 
    for c = 1:STEP:(Image_Test_Col-IMAGE_DATA_COL+1)
        for r = 1:STEP:(Image_Test_Row-IMAGE_DATA_ROW+1)
            %测试%
          %  rectangle('Position',[c,r,IMAGE_DATA_COL,IMAGE_DATA_ROW],'LineWidth',1,'EdgeColor','g');
            
            Image_Slide(1:IMAGE_DATA_ROW,1:IMAGE_DATA_COL) = Image_Big(r:r+IMAGE_DATA_ROW-1,c:c+IMAGE_DATA_COL-1);
            %ExtracFeature% 
            Features2(:,1) = ExtractFeature( Image_Slide,Point,N_FEATURES,W_FEATURES);
            %compare distance%
            Features2 =repmat(Features2(:,1),[1,IMAGE_DATA_N]);%  重复15次
            Features2 = (Features2-Features).^2;
            for f = 1:IMAGE_DATA_N %计算出欧式距离 并与阈值比较
                dis(f)=floor((sum(Features2(:,f))).^0.5)+1;
            end
               %  if dis(f)<THRESHOLD
                   % N_Confidence=N_Confidence+1;
                 % end
                 % if N_Confidence>0.5*IMAGE_DATA_N%有超过一半匹配，说明是人脸
            [Min_dis,Index_dis] = min(dis);
            if Min_dis<THRESHOLD %&& dis(f)>THRESHOLD2
                %给出画图坐标
                Point_R(Rec,1) = ceil(r/(0.8)^N_Shrink);
                Point_R(Rec,2) = ceil(c/(0.8)^N_Shrink);
                %给出宽和高
                Point_R(Rec,3) = ceil(IMAGE_DATA_COL/(0.8)^N_Shrink);%IMAGE_DATA_COL;%
                Point_R(Rec,4) = ceil(IMAGE_DATA_ROW/(0.8)^N_Shrink);%IMAGE_DATA_ROW;%
                %  置信度%
                Point_R(Rec,5)= THRESHOLD/dis(f);%越可信，值越大 
               % Point_R(Rec,5)= 1000/abs((THRESHOLD+THRESHOLD2)/2-dis(f));%越可信，值越大
                Rec = Rec + 1; 
                %画出所有没NMS 之前的框
                rectangle('Position',[Point_R(end,2)+1,Point_R(end,1)+1,Point_R(end,3),Point_R(end,4)],'LineWidth',2,'EdgeColor','b');
            end
                % dis小于阈值说明与找到一个人脸
             
        end
    end
    %shrink image%
    Image_Test{2} = imresize(Image_Test{2},0.8);%缩小图像
    [Image_Test_Row,Image_Test_Col]=size(Image_Test{2});%找出test图像缩小后的高宽
    N_Shrink = N_Shrink + 1;
end

%Point_R = Point_R(1:end-1,:);
%NMS%
overlap = 0.05;
boxes=Point_R;
boxes(:,3) = Point_R(:,1)+Point_R(:,3);
boxes(:,4) = Point_R(:,1)+Point_R(:,4);
picks = NMS(boxes, overlap);
N = picks{1,1};
Point_RR = zeros(size(N,1),5);
for i = 1: size(picks{1,1})
    Point_RR(i,:)= Point_R(N(i),:);
end
%draw rectange%
Size_P_RR =size(Point_RR,1);
for r = 1:Size_P_RR
    rectangle('Position',[Point_RR(r,2),Point_RR(r,1),Point_RR(r,3),Point_RR(r,4)],'LineWidth',2,'EdgeColor','r');
    hold on;
end
%}
toc;

