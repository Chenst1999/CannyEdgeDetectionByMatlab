clc;
clear;
close;

f_original = imread(uigetfile('.jpg'));              %����RGBͼƬ
f_grey = rgb2gray(f_original);                     %ת��Ϊ�Ҷ�ͼ��

%1.��˹�˲�
gw = fspecial('gaussian',[5,5],0.5);               %��˹�˲����úˣ�5*5����׼��Ϊ0.5
f_filter = imfilter(f_grey,gw,'replicate');        %��˹�˲�
f = f_filter;

%2.����Sobel���Ӽ��������ݶ�
Sobel_X = [-1,0,1;-2,0,2;-1,0,1];	%X����Sobel����
Sobel_Y = [-1,-2,-1;0,0,0;1,2,1];	%Y����Sobel����
[row,col] = size(f);
%ͼ�����䣬�߽粹��Ϊ0
f_extend = zeros(row+2,col+2); 
for  i = 2:row+1
    for j = 2:col+1
        f_extend(i,j) = f(i-1,j-1);
    end
end
Gx = zeros(row,col);
Gy = zeros(row,col);
%����x���y���ݶ�
for i = 2:row+1
    for j = 2:col+1
        window = [f_extend(i-1,j-1),f_extend(i-1,j),f_extend(i-1,j+1);...
            f_extend(i,j-1),f_extend(i,j),f_extend(i,j+1);...
            f_extend(i+1,j-1),f_extend(i+1,j),f_extend(i+1,j+1)];
        Gx(i-1,j-1) = sum(sum(Sobel_X .* window)); %����x���ݶ�
        Gy(i-1,j-1) = sum(sum(Sobel_Y .* window)); %����y���ݶ�
    end
end
Sxy = sqrt(Gx.*Gx + Gy.*Gy); %�ݶ�ǿ�Ⱦ������

%3.�Ǽ���ֵ����
indexD = zeros(row,col);
%�ж��ݶȷ����������䣬Gx=Gy=0��������Ϊ5���϶����Ǳ߽��
for i = 1:row
    for j = 1:col
        ix = Gx(i,j);
        iy = Gy(i,j);
        if (iy<=0 && ix>-iy) || (iy>=0 && ix<-iy)%�ݶȷ�����������1
            indexD(i,j) = 1;
        elseif (ix>0 && ix<=-iy) || (ix<0 && ix>=-iy)%�ݶȷ�����������2
            indexD(i,j) = 2;
        elseif (ix<=0 && ix>iy) || (ix>=0 && ix<iy)%�ݶȷ�����������3
            indexD(i,j) = 3;
        elseif (iy<0 && ix<=iy) || (iy>0 && ix>=iy)%�ݶȷ�����������4
            indexD(i,j) = 4;
        else%Gx��Gy��Ϊ0�����ݶȣ��϶��Ǳ�Ե
            indexD(i,j) = 5;
        end
    end
end

%GupΪ�Ϸ�������ݶȣ�GdownΪ�·�������ݶ�
Gup = zeros(row,col);
Gdown = zeros(row,col);
for i = 2:row-1%����Ǳ߽紦�Ĳ�ֵ�ݶ�ǿ��
    for j = 2:col-1
        ix = Gx(i,j);
        iy = Gy(i,j);
        if indexD(i,j) == 1 %��������1�ڲ�ֵ�ݶ�
            t = abs(iy./ix);
            Gup(i,j) = Sxy(i,j+1).*(1-t) + Sxy(i-1,j+1).*t;
            Gdown(i,j) = Sxy(i,j-1).*(1-t) + Sxy(i+1,j-1).*t;
        elseif indexD(i,j) == 2%��������2�ڲ�ֵ�ݶ�
            t = abs(ix./iy);
            Gup(i,j) = Sxy(i-1,j).*(1-t) + Sxy(i-1,j+1).*t;
            Gdown(i,j) = Sxy(i+1,j).*(1-t) + Sxy(i+1,j-1).*t;
        elseif indexD(i,j) == 3%��������3�ڲ�ֵ�ݶ�
            t = abs(ix./iy);
            Gup(i,j) = Sxy(i-1,j).*(1-t) + Sxy(i-1,j-1).*t;
            Gdown(i,j) = Sxy(i+1,j).*(1-t) + Sxy(i+1,j+1).*t;
        elseif indexD(i,j) == 4%��������4�ڲ�ֵ�ݶ�
            t = abs(iy./ix);
            Gup(i,j) = Sxy(i,j-1).*(1-t) + Sxy(i-1,j-1).*t;
            Gdown(i,j) = Sxy(i,j+1).*(1-t) + Sxy(i+1,j+1).*t;
        end
    end
end

Sxy_NMX = zeros(row,col);%�ж��Ƿ�Ϊ�ݶȷ��򼫴�ֵ
for i = 1:row                                     
    for j = 1:col
        if Sxy(i,j) >= Gup(i,j) && Sxy(i,j) >= Gdown(i,j)%��Ϊ�ݶȷ��򼫴�ֵ��������
            Sxy_NMX(i,j) = Sxy(i,j);%���򣬽������ƣ���0��
        end
    end
end
    
%4.�ͺ���ֵ��+5.���ƹ���������Ե
f_final = zeros(row,col);
Tl = 20;              
Th = 40;
connectNum = 1;

for i = 2:row-1                                     
    for j = 2:col-1
        if Sxy_NMX(i,j) >= Th          %���ڸ���ֵ������Ϊǿ��Ե
            f_final(i,j) = 1;
        elseif Sxy_NMX(i,j) <= Tl      %���ڵ���ֵ������Ϊ�Ǳ�Ե
            f_final(i,j) = 0;
        else                           %λ�ڸߵ���ֵ֮�������Ϊ����Ե�����й����Լ��
            count = 0;
            if Sxy_NMX(i-1,j-1)~=0     %���Ϸ�����
                count = count+1;
            end
            if Sxy_NMX(i-1,j)~=0       %�Ϸ�����
                count = count+1;
            end
            if Sxy_NMX(i-1,j+1)~=0     %���Ϸ�����
                count = count+1;
            end
            if Sxy_NMX(i,j-1)~=0       %������
                count = count+1;
            end
            if Sxy_NMX(i,j+1)~=0       %�ҷ�����
                count = count+1;
            end
            if Sxy_NMX(i+1,j-1)~=0     %���·�����
                count = count+1;
            end
            if Sxy_NMX(i+1,j)~=0       %�·�����
                count = count+1;
            end
            if Sxy_NMX(i+1,j+1)~=0     %���·�����
                count = count+1;
            end
            if count >= connectNum     %����Ե�ǹ�������Ϊ��Ե
                f_final(i,j) = 1;
            end
        end
    end
end

f_dafault = edge(f_grey,'canny'); %ʹ��Ĭ�ϲ���
figure
subplot(1,3,1);imshow(f_original);title('ԭʼͼ��');
subplot(1,3,2);imshow(f_final);title('�Ա�Canny��Ե���');
subplot(1,3,3);imshow(f_dafault);title('MATLAB����Canny');