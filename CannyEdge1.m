clc;
clear all;
close all;
I=rgb2gray(imread(uigetfile('.jpg')));     
Img=double(I);  
[row,col]=size(I); 
 
%第一步:Gaussian卷积平滑滤波
alf=1;  
n=5; 
n0=floor((n+1)/2);
 %Gaussian卷积核计算
for i=1:n    
	for j=1:n  
        h(i,j) = exp(-((i-n0)^2+(j-n0)^2)/(2*alf))/(2*pi*alf);  
	end  
end
 %通过创建的高斯卷积核进行高斯滤波，并转换为8为整型数据
Img_gauss=uint8(conv2(Img,h,'same'));  
 
figure
imshow(I);title('Gray Image');  
figure
imshow(Img_gauss);title('Gaussian Filter Result'); 
 
M = zeros(row,col);
theta = zeros(row,col);
canny1 = zeros(row,col);%非极大值抑制
canny2 = zeros(row,col);%双阈值检测和连接

Img_gauss=double(Img_gauss);    
for i=2:row-2 
	for j=2:col-2
        %第二步:计算x 和 Y 方向的幅度和方向梯度
        Sx=Img_gauss(i-1,j-1)+2*Img_gauss(i,j-1)+Img_gauss(i+1,j-1)-...
                -Img_gauss(i-1,j+1)-2*Img_gauss(i,j+1)-Img_gauss(i+1,j+1);  
        Sy=Img_gauss(i+1,j-1)+2*Img_gauss(i+1,j)+Img_gauss(i+1,j+1)-...
                -Img_gauss(i-1,j-1)-2*Img_gauss(i-1,j)-Img_gauss(i-1,j+1);  
        M(i,j)=sqrt(Sx^2+Sy^2);  %记录幅度值
        theta(i,j)= atan(Sx/Sy);%记录方位角，反应梯度方向，与梯度垂直的方向即为边缘方向
       
        %第三步:分四个方向进行比较，非极大值抑制
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
 
%第四步:双阈值监测和边缘连接 
 lowTh  = 0.15 *max(max(canny1));%高阈值
 higtTh = 0.45 *max(max(canny1));%低阈值
for i = 2 :row
    for j = 2 : col
        if canny1(i,j) >lowTh && canny1(i,j) < higtTh
            canny2(i,j) = canny1(i,j);
        end
    end
end

 figure
 imshow(uint8(M)); title('Canny幅度图'); 
 figure
 imshow(uint8(canny1)); title('非最大抑制：Canny1 边缘检测结果'); 
 figure
 imshow(uint8(canny2)); title('双阈值监控：Canny2边缘检测结果'); 
