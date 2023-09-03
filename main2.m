clc, clear;
close all;
tic;

img0 = imread(uigetfile('.jpg'));
img0 = double(rgb2gray(img0));

gauss = [1 2 1; 2 4 2;1 2 1] / 16;  % Gaussƽ��ģ��
sobelx = [-1 0 1; -2 0 2; -1 0 1];  % Sobelˮƽ��Եģ��
sobely = sobelx';                   % Sobel��ֱ��Եģ��

img = conv2(img0, gauss, 'same');   % ƽ��
gradx = conv2(img, sobelx, 'same'); % ˮƽ��Ե���
grady = conv2(img, sobely, 'same'); % ��ֱ��Ե���

M = sqrt(gradx .^ 2 + grady .^ 2);  % ��Ե�߶�
N = zeros(size(M));                 % ���������ͼ��
alpha = atan(grady ./ gradx);       % ��Ե����

for i = 2: length(M(:, 1))-1
    for j = 2: length(M(1, :))-1
        dirc = alpha(i, j);         
        % �ĸ����������жϲ����з�������ƣ����������
        % [1 2 3;4 5 6;7 8 9]����Ե��[4 5 6]������
        % ô���ǹ��ĵ���Ԫ��2��Ԫ��8��Ԫ��5�Ĵ�С��ϵ
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

TH = 0.4 * max(max(N));     % ����ֵ
TL = 0.2 * max(max(N));      % ����ֵ
THedge = N; 
TLedge = N;

THedge(THedge < TH) = 0;          % ǿ��Ե
TLedge(TLedge < TL) = 0;             % ����Ե

THedge = padarray(THedge, [1, 1], 0, 'both');   % ���б���չ����ֹ����ʱ����
TLedge = padarray(TLedge, [1, 1], 0, 'both');     % ��Ȧ��0
TLedge0 = TLedge;

isvis = ones(size(THedge));          % �Ƿ������ĳ���أ���Ϊ0������Ϊ1(���ڼ���)

while(sum(sum(THedge)))
    [x, y] = find(THedge ~= 0, 1);   % Ѱ��8�����ڷ�0���أ���Ϊ��һ�����������
    THedge = THedge .* isvis;         % �������ĵ���Ϊ0
    [TLedge0, isvis] = traverse(TLedge0, x, y, isvis);      % �ݹ����������ʣ�µ���δ������Ԫ�أ�����������Ŀ���Ե
end

TLedge = TLedge - TLedge0;           % �������Canny��Ե
THedge(:, end) = []; THedge(end, :) = []; THedge(1, :) = []; THedge(:, 1) = []; % ɾȥ��չ�ı�Ե
TLedge(:, end) = []; TLedge(end, :) = []; TLedge(1, :) = []; TLedge(:, 1) = [];

toc;

figure;
subplot(221), imshow(uint8(img0)), title('car');
subplot(222), imshow(uint8(M)), title('Amplitude');
subplot(223), imshow(uint8(alpha)), title('Alpha');
subplot(224), imshow(uint8(THedge)), title('output');