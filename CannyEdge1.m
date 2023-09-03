clc;
clear all;
close all;
I=rgb2gray(imread(uigetfile('.jpg')));     
Img=double(I);  
[row,col]=size(I); 
 
%��һ��:Gaussian���ƽ���˲�
alf=1;  
n=5; 
n0=floor((n+1)/2);
 %Gaussian����˼���
for i=1:n    
	for j=1:n  
        h(i,j) = exp(-((i-n0)^2+(j-n0)^2)/(2*alf))/(2*pi*alf);  
	end  
end
 %ͨ�������ĸ�˹����˽��и�˹�˲�����ת��Ϊ8Ϊ��������
Img_gauss=uint8(conv2(Img,h,'same'));  
 
figure
imshow(I);title('Gray Image');  
figure
imshow(Img_gauss);title('Gaussian Filter Result'); 
 
M = zeros(row,col);
theta = zeros(row,col);
canny1 = zeros(row,col);%�Ǽ���ֵ����
canny2 = zeros(row,col);%˫��ֵ��������

Img_gauss=double(Img_gauss);    
for i=2:row-2 
	for j=2:col-2
        %�ڶ���:����x �� Y ����ķ��Ⱥͷ����ݶ�
        Sx=Img_gauss(i-1,j-1)+2*Img_gauss(i,j-1)+Img_gauss(i+1,j-1)-...
                -Img_gauss(i-1,j+1)-2*Img_gauss(i,j+1)-Img_gauss(i+1,j+1);  
        Sy=Img_gauss(i+1,j-1)+2*Img_gauss(i+1,j)+Img_gauss(i+1,j+1)-...
                -Img_gauss(i-1,j-1)-2*Img_gauss(i-1,j)-Img_gauss(i-1,j+1);  
        M(i,j)=sqrt(Sx^2+Sy^2);  %��¼����ֵ
        theta(i,j)= atan(Sx/Sy);%��¼��λ�ǣ���Ӧ�ݶȷ������ݶȴ�ֱ�ķ���Ϊ��Ե����
       
        %������:���ĸ�������бȽϣ��Ǽ���ֵ����
        dirc = theta(i,j);
        if abs(dirc) <= pi / 8
            if (M(i,j) > M(i-1,j-1) )&&( M(i,j)> M(i+1,j+1) )
                canny1(i, j) = M(i, j);
            end
        elseif abs(dirc) >= 3 * pi / 8
            if (M(i,j) > M(i-1,j-1) )&&( M(i,j)> M(i+1,j+1) )
            	canny1(i, j) = M(i, j);
            end
        elseif dirc > pi / 8 && dirc < 3 * pi / 8
            if ( M(i,j) > M(i-1,j-1) )&&( M(i,j)> M(i+1,j+1) )
            	canny1(i, j) = M(i, j);
            end
        elseif dirc > - 3 * pi / 8 && dirc < - pi / 8
        	if (M(i,j) > M(i-1,j-1) )&&( M(i,j)> M(i+1,j+1) )
            	canny1(i, j) = M(i, j);
            end
        end
	end  
end  
 
%���Ĳ�:˫��ֵ���ͱ�Ե���� 
 lowTh  = 0.15 *max(max(canny1));%����ֵ
 higtTh = 0.45 *max(max(canny1));%����ֵ
for i = 2 :row
    for j = 2 : col
        if canny1(i,j) >lowTh && canny1(i,j) < higtTh
            canny2(i,j) = canny1(i,j);
        end
    end
end

 figure
 imshow(uint8(M)); title('Canny����ͼ'); 
 figure
 imshow(uint8(canny1)); title('��������ƣ�Canny1 ��Ե�����'); 
 figure
 imshow(uint8(canny2)); title('˫��ֵ��أ�Canny2��Ե�����'); 
