 tic;
 clc;
 clear;
 Min_dis = 1;
 IMAGE_DATA_N =110;%110��ԭʼ����
 IMAGE_DATA_ROW = 56;%ԭʼ���ݹ�һ��112*92
 IMAGE_DATA_COL = 45;
 N_FEATURES = 1000;
 W_FEATURES = 5;%feature �Ŀ��
 Features =zeros(N_FEATURES,IMAGE_DATA_N);% N_FEATURES*110 features ѵ����������ֵ
 Features2 =zeros(N_FEATURES,IMAGE_DATA_N);% N_FEATURES*110 features ���ڼ���ŷʽ���� 
 Point1 = rand(N_FEATURES,4);%������ɵ� ����5*5�������� 7��[x;y;X;Y;xy���;XY���;����ֵ]
 Point1(:,[1,3]) = ceil(Point1(:,[1,3])* IMAGE_DATA_ROW);
 Point1(:,[2,4]) = ceil(Point1(:,[2,4])* IMAGE_DATA_COL);
 Point = [Point1,zeros(N_FEATURES,3)];%����ExtractFeature���������
 Image_Slide = zeros(IMAGE_DATA_ROW,IMAGE_DATA_COL);%��Ŷ�testͼ�����120*100�Ļ�����Ϣ
 STEP = 10;%����Ĳ���
 dis = zeros(1,IMAGE_DATA_N);%distance
 %THRESHOLD = 39000; ��Ӧ112*92
% THRESHOLD = 23000;%test2:19000-22000 % test6 : 23000-%4013: 20000-25000 %test3 23000-25000%Dinner 23000%test5 
THRESHOLD = 23000;

%input database%
Image_Data = {0};%set a cell array to put data
str = 'pic\';
for i=1:IMAGE_DATA_N%
    Image_Data{i} = imread([str,num2str(i),'.pgm']);
    Image_Data{i} = imresize(Image_Data{i},[IMAGE_DATA_ROW,IMAGE_DATA_COL]);%resize the image
    %gaussian%
    sigma=6;%��׼���С  
    window=double(uint8(3*sigma)*2+1);%���ڴ�Сһ��Ϊ3*sigma  
    H=fspecial('gaussian', window, sigma);%fspecial('gaussian', hsize, sigma)�����˲�ģ��  
    %Ϊ�˲����ֺڱߣ�ʹ�ò���'replicate'������ͼ����ⲿ�߽�ͨ�������ڲ��߽��ֵ����չ��  
    Image_Data{i}=imfilter(Image_Data{i},H,'replicate'); 
    %ExtractFeature%
    Features(:,i) = ExtractFeature( Image_Data{i},Point,N_FEATURES,W_FEATURES);
end

%input test image%
Image_Test{1} = imread('test3.jpg');
imshow(Image_Test{1,1});%��ʾͼ�� �����ڻ�����
hold on;
%gaussian�˲�%
sigma=6;%��׼���С  
window=double(uint8(3*sigma)*2+1);%���ڴ�Сһ��Ϊ3*sigma  
H=fspecial('gaussian', window, sigma);%fspecial('gaussian', hsize, sigma)�����˲�ģ��  
%Ϊ�˲����ֺڱߣ�ʹ�ò���'replicate'������ͼ����ⲿ�߽�ͨ�������ڲ��߽��ֵ����չ��  
Image_Test{1,1}=imfilter(Image_Test{1,1},H,'replicate');  

Image_Test{1} = rgb2gray(Image_Test{1});%���ڱ���ԭʼͼ����Ϣ ��ɫͼ���ɻҶ�ͼ��
Image_Test{2} = Image_Test{1};%�����ݴ��м��������Сͼ��
[Image_Test_Row,Image_Test_Col]=size(Image_Test{2});%�ҳ�testͼ���ʼ������ N_FEATURES0 1000
Point_R =[ ones(1,2),ones(1,1)*IMAGE_DATA_COL,ones(1,1)*IMAGE_DATA_ROW,ones(1,1)];%���ڻ���������[x,y,w,h,score]
%find all subtest image%
%����>120 ���� ����>100��һֱѰ��%
N_Shrink = 0;%��С�Ĵ���,���ڼ��㻭����ʱ���λ�ӡ�
Rec = 1;%���ο�ı��
while ((Image_Test_Row>=IMAGE_DATA_ROW) && (Image_Test_Col>=IMAGE_DATA_COL))
    %find 120*100 ����%
    Image_Big = Image_Test{2}; 
    for c = 1:STEP:(Image_Test_Col-IMAGE_DATA_COL+1)
        for r = 1:STEP:(Image_Test_Row-IMAGE_DATA_ROW+1)
            %����%
          %  rectangle('Position',[c,r,IMAGE_DATA_COL,IMAGE_DATA_ROW],'LineWidth',1,'EdgeColor','g');
            
            Image_Slide(1:IMAGE_DATA_ROW,1:IMAGE_DATA_COL) = Image_Big(r:r+IMAGE_DATA_ROW-1,c:c+IMAGE_DATA_COL-1);
            %ExtracFeature% 
            Features2(:,1) = ExtractFeature( Image_Slide,Point,N_FEATURES,W_FEATURES);
            %compare distance%
            Features2 =repmat(Features2(:,1),[1,IMAGE_DATA_N]);%  �ظ�15��
            Features2 = (Features2-Features).^2;
            for f = 1:IMAGE_DATA_N %�����ŷʽ���� ������ֵ�Ƚ�
                dis(f)=floor((sum(Features2(:,f))).^0.5)+1;
            end
               %  if dis(f)<THRESHOLD
                   % N_Confidence=N_Confidence+1;
                 % end
                 % if N_Confidence>0.5*IMAGE_DATA_N%�г���һ��ƥ�䣬˵��������
            [Min_dis,Index_dis] = min(dis);
            if Min_dis<THRESHOLD %&& dis(f)>THRESHOLD2
                %������ͼ����
                Point_R(Rec,1) = ceil(r/(0.8)^N_Shrink);
                Point_R(Rec,2) = ceil(c/(0.8)^N_Shrink);
                %������͸�
                Point_R(Rec,3) = ceil(IMAGE_DATA_COL/(0.8)^N_Shrink);%IMAGE_DATA_COL;%
                Point_R(Rec,4) = ceil(IMAGE_DATA_ROW/(0.8)^N_Shrink);%IMAGE_DATA_ROW;%
                %  ���Ŷ�%
                Point_R(Rec,5)= THRESHOLD/dis(f);%Խ���ţ�ֵԽ�� 
               % Point_R(Rec,5)= 1000/abs((THRESHOLD+THRESHOLD2)/2-dis(f));%Խ���ţ�ֵԽ��
                Rec = Rec + 1; 
                %��������ûNMS ֮ǰ�Ŀ�
                rectangle('Position',[Point_R(end,2)+1,Point_R(end,1)+1,Point_R(end,3),Point_R(end,4)],'LineWidth',2,'EdgeColor','b');
            end
                % disС����ֵ˵�����ҵ�һ������
             
        end
    end
    %shrink image%
    Image_Test{2} = imresize(Image_Test{2},0.8);%��Сͼ��
    [Image_Test_Row,Image_Test_Col]=size(Image_Test{2});%�ҳ�testͼ����С��ĸ߿�
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

