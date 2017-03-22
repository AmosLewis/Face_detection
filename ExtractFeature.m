function  Feature = ExtractFeature(I,Point,N_FEATURES,W_FEATURES)
%%%EXTRACTFEATURE �˴���ʾ�йش˺�����ժҪ%%
%   I �����120*100ͼ�� 
%   Point ���ص�ֵ
%   N_FEATURES �����ĸ���
%   W_FEATURES С��Ŀ�� Ĭ��5*5 ���� 10*10
%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Row,Col] = size(I);
%%%%%%%%%%�������ͼ%%%%%%%%%%
I_Integral=zeros(Row,Col);
I=double(I);
for i=1:Row
    for j=1:Col
        if i==1 && j==1             %����ͼ�����Ͻ�
            I_Integral(i,j)=I(i,j);
        elseif i==1 && j~=1         %����ͼ���һ��
            I_Integral(i,j)=I_Integral(i,j-1)+I(i,j);
        elseif i~=1 && j==1         %����ͼ���һ��
            I_Integral(i,j)=I_Integral(i-1,j)+I(i,j);
        else                        %����ͼ����������
            I_Integral(i,j)=I(i,j)+I_Integral(i-1,j)+I_Integral(i,j-1)-I_Integral(i-1,j-1);  
        end
    end
end

%%%%%%%%%%ѡȡ������%%%%%%%%%%
% Point(:,1)=floor(Point(:,1)+Row/6-1); %ȥ��ͷ����ֻȡ����20-120����
% Point(:,3)=floor(Point(:,3)+Row/6-1); %ֻ��120*100ʱ�� floor ���Բ���

%%%%%%%%%%��������ֵ%%%%%%%%%%
for i = 1:N_FEATURES
    %��һ���% 
    x=Point(i,1);
    y=Point(i,2);
    C = I_Integral(x,y);
    if (x==1) && (y==1)%���������һ����
        Point(i,5) = I_Integral(x,y);
    elseif (y <= W_FEATURES)&&(y <= W_FEATURES)%��������ǰʮ�е�
        Point(i,5) = C;
    elseif y <= W_FEATURES%��������ǰʮ�е�
        B = I_Integral(x-W_FEATURES,y);
        Point(i,5) = C-B;
    elseif x <= W_FEATURES%��������ǰʮ�е�
        D = I_Integral(x,y-W_FEATURES);
        Point(i,5) = C-D;
    else
        A = I_Integral(x-W_FEATURES,y-W_FEATURES);
        B = I_Integral(x-W_FEATURES,y);
        D = I_Integral(x,y-W_FEATURES);
        Point(i,5) = C+A-B-D;
    end
    %�ڶ����% 
    x=Point(i,3);%�ڶ���ͼ�ĺ�����
    y=Point(i,4);%�ڶ���ͼ��������
    C = I_Integral(x,y);
    if (x==1) && (y==1)%���������һ����
        Point(i,6) = I_Integral(x,y);
    elseif (y <= W_FEATURES)&&(y <= W_FEATURES)%��������ǰʮ�е�
        Point(i,6) = C;
    elseif y <= W_FEATURES%��������ǰʮ�е�
        B = I_Integral(x-W_FEATURES,y);
        Point(i,6) = C-B;
    elseif x <= W_FEATURES%��������ǰʮ�е�
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

