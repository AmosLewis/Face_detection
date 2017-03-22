function picks = NMS(boxes, overlap)
 %%boxesΪһ��m*n�ľ�������mΪboundingbox�ĸ�����n��ǰ4��Ϊÿ��boundingbox�����꣬��ʽΪ
%%��x1,y1,x2,y2������5:n��Ϊÿһ������Ŷȡ�overlapΪ�趨ֵ��0.3,0.5 .....
x1 = boxes(:,1);%����boundingbox��x1����
y1 = boxes(:,2);%����boundingbox��y1����
x2 = boxes(:,3);%����boundingbox��x2����
y2 = boxes(:,4);%����boundingbox��y2����
area = (x2-x1+1) .* (y2-y1+1); %ÿ��%����boundingbox�����
picks = cell(size(boxes, 2)-4, 1);%Ϊÿһ��Ԥ����һ����Ҫ������cell
 for iS = 5:size(boxes, 2)%ÿһ�൥������
    s = boxes(:,iS);%���е�score
    [vals, I] = sort(s);%���Ŷȴӵ͵�������
    pick = s*0;
    counter = 1;
    while ~isempty(I)
       last = length(I);%
       i = I(last);  
       pick(counter) = i;%����������ÿ��÷���ߵ�boundingbox
       counter = counter + 1;

       xx1 = max(x1(i), x1(I(1:last-1)));
       yy1 = max(y1(i), y1(I(1:last-1)));
       xx2 = min(x2(i), x2(I(1:last-1)));
       yy2 = min(y2(i), y2(I(1:last-1)));


       w = max(0.0, xx2-xx1+1);
       h = max(0.0, yy2-yy1+1);


       inter = w.*h;
       o = inter ./ (area(i) + area(I(1:last-1)) - inter);%����÷���ߵ��Ǹ�boundingbox�������boundingbox�Ľ������


      I = I(o<=overlap);%��������С��һ����ֵ��boundingbox
     end

     pick = pick(1:(counter-1));
     picks{iS-4} = pick;%����ÿһ���boundingbox
 end


     
