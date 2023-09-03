clear all;
clear
clc;
%读进图像
[filename, pathname] = uigetfile({'*.jpg'; '*.bmp'; '*.gif'}, '选择图片');

%没有图像
if filename == 0
    return;
end

img = imread([pathname, filename]);
[y, x, dim] = size(img);

%转换为灰度图
if dim>1
    img = rgb2gray(img);
end

sigma = 1;
gausFilter = fspecial('gaussian', [3,3], sigma);
img0= imfilter(img, gausFilter, 'replicate');

zz = double(img0);


 %自己的边缘检测函数
 [m,theta,sector,canny1,canny2,bin] = canny1step(img0, 22);
 [msrc,thetasrc,sectorsrc,c1src,c2src,binsrc] = canny1step(img, 22);

  %Matlab自带的边缘检测
 ed = edge(img0, 'canny', 0.5); 
 
 
[xx, yy] = meshgrid(1:x, 1:y);

figure(1)
%mesh(yy, xx, zz);
surf(yy, xx, zz);
xlabel('y');
ylabel('x');
zlabel('Grayscale');
axis tight

figure(2)    
subplot(2,4,1);imshow(img);%原图
subplot(2,4,2);imshow(img0);%高斯滤波后
subplot(2,4,3);imshow(uint8(m));%导数
subplot(2,4,4);imshow(uint8(canny1));%非极大值抑制
subplot(2,4,5);imshow(uint8(canny2));%双阈值
subplot(2,4,6);imshow(ed);%Matlab自带边缘检测
subplot(2,4,7);imshow(bin);%我自己的bin
    
figure(3)
edzz = 255*double(ed);
mesh(yy,xx,edzz);
xlabel('y');
ylabel('x');
zlabel('Grayscale');
axis tight 
 
figure(4)
mesh(yy,xx,m);%画偏导数
xlabel('y');
ylabel('x');
zlabel('Derivative');
axis tight 
 
figure(5)
mesh(yy,xx,theta);
xlabel('y');
ylabel('x');
zlabel('Theta');
axis tight
 
figure(6)
mesh(yy,xx,sector);
xlabel('y');
ylabel('x');
zlabel('Sector');
axis tight
    
figure(7)
mesh(yy,xx,canny2);
xlabel('y');
ylabel('x');
zlabel('Sector');
axis tight
