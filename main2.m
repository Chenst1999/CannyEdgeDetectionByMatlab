clc, clear;
close all;
tic;

img0 = imread(uigetfile('.jpg'));
img0 = double(rgb2gray(img0));

gauss = [1 2 1; 2 4 2;1 2 1] / 16;  % Gauss平滑模板
sobelx = [-1 0 1; -2 0 2; -1 0 1];  % Sobel水平边缘模板
sobely = sobelx';                   % Sobel垂直边缘模板

img = conv2(img0, gauss, 'same');   % 平滑
gradx = conv2(img, sobelx, 'same'); % 水平边缘卷积
grady = conv2(img, sobely, 'same'); % 垂直边缘卷积

M = sqrt(gradx .^ 2 + grady .^ 2);  % 边缘高度
N = zeros(size(M));                 % 非最大抑制图像
alpha = atan(grady ./ gradx);       % 边缘方向

for i = 2: length(M(:, 1))-1
    for j = 2: length(M(1, :))-1
        dirc = alpha(i, j);         
        % 四个基本方向判断并进行非最大抑制，比如矩阵是
        % [1 2 3;4 5 6;7 8 9]，边缘延[4 5 6]方向，那
        % 么我们关心的是元素2和元素8与元素5的大小关系
        if abs(dirc) <= pi / 8
            if M(i, j) == max([(M(i, j - 1)), M(i, j), M(i, j + 1)])
                N(i, j) = M(i, j);
            end
        elseif abs(dirc) >= 3 * pi / 8
            if M(i, j) == max([(M(i - 1, j)), M(i, j), M(i + 1, j)])
                N(i, j) = M(i, j);
            end
        elseif dirc > pi / 8 && dirc < 3 * pi / 8
            if M(i, j) == max([(M(i - 1, j - 1)), M(i, j), M(i + 1, j + 1)])
                N(i, j) = M(i, j);
            end
        elseif dirc > - 3 * pi / 8 && dirc < - pi / 8
            if M(i, j) == max([(M(i + 1, j - 1)), M(i, j), M(i - 1, j + 1)])
                N(i, j) = M(i, j);
            end
        end
    end
end

TH = 0.4 * max(max(N));     % 高阈值
TL = 0.2 * max(max(N));      % 低阈值
THedge = N; 
TLedge = N;

THedge(THedge < TH) = 0;          % 强边缘
TLedge(TLedge < TL) = 0;             % 弱边缘

THedge = padarray(THedge, [1, 1], 0, 'both');   % 进行边扩展，防止遍历时出错
TLedge = padarray(TLedge, [1, 1], 0, 'both');     % 外圈扩0
TLedge0 = TLedge;

isvis = ones(size(THedge));          % 是否遍历过某像素，是为0，不是为1(便于计算)

while(sum(sum(THedge)))
    [x, y] = find(THedge ~= 0, 1);   % 寻找8邻域内非0像素，作为下一步搜索的起点
    THedge = THedge .* isvis;         % 搜索过的点标记为0
    [TLedge0, isvis] = traverse(TLedge0, x, y, isvis);      % 递归遍历，最终剩下的是未遍历的元素，即孤立点或非目标边缘
end

TLedge = TLedge - TLedge0;           % 作差求出Canny边缘
THedge(:, end) = []; THedge(end, :) = []; THedge(1, :) = []; THedge(:, 1) = []; % 删去扩展的边缘
TLedge(:, end) = []; TLedge(end, :) = []; TLedge(1, :) = []; TLedge(:, 1) = [];

toc;

figure;
subplot(221), imshow(uint8(img0)), title('car');
subplot(222), imshow(uint8(M)), title('Amplitude');
subplot(223), imshow(uint8(alpha)), title('Alpha');
subplot(224), imshow(uint8(THedge)), title('output');