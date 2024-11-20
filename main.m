%寄了

clear, clc, close all

% 调用主函数，提取颜色区域
extractColorRegion();

% 动态生成HSV掩膜的函数
function mask = createDynamicHSVMask(image, hueRange, satRange, valRange)

    % 生成HSV掩膜：根据色相、饱和度和亮度范围来选择图像中的特定区域
   mask = (image(:,:,1) >= hueRange(1) & image(:,:,1) <= hueRange(2)) & ...
           (image(:,:,2) >= satRange(1) & image(:,:,2) <= satRange(2)) & ...
           (image(:,:,3) >= valRange(1) & image(:,:,3) <= valRange(2));

end

% 主脚本：读取图像并提取指定颜色范围
function extractColorRegion()
    % 读取图像
    image = imread("D:\LeStoreDownload\Matlab\Program_Files\Polyspace\R2019b\bin\over_littleProgram\program_PointsPainting\BIGtest.png");  % 替换为你的图像路径
    
    % 将RGB图像转换为HSV图像
    image = rgb2hsv(image); 
    
    % 划分
    satRange = [0, 1];      % 饱和度范围
    valRange = [0, 1];      % 亮度范围
    hueStep = 0.05;  % Hue 的步长
    hueRanges = 0:hueStep:1;  % Hue 的范围从 0 到 1
    
    %创建背景
    % 获取图像的大小
    [rows, cols, channels] = size(image);
    % 创建一个与原图像大小相同的白色背景
    Painting =zeros(rows, cols, channels);
    % 显示白色背景
    figure;
    subplot(1,2,1);
    imshow(Painting+1);
    
    %全局Val
    %Val数组,添加一些随机的色点
    randomArrayWhite = rand(rows,cols)>0;
    goodSat=image(:,:,2).*randomArrayWhite;
    goodVal=image(:,:,3).*randomArrayWhite;
    goodVal=goodVal+(goodVal==0);
    
    hold on;  % 在同一图像上绘制所有提取的点

    for i = 1:length(hueRanges)-1
        % 当前的 Hue 范围
        hueRange = [hueRanges(i), hueRanges(i+1)];

        % 生成当前色相范围的HSV掩膜
        colorMask = createDynamicHSVMask(image, hueRange, satRange, valRange);
        
        %hue数组
        randomArrayHue = hueRanges(i) + randi([0, 1], rows, cols) * hueStep;
        


        Painting(:,:,1)=Painting(:,:,1)+randomArrayHue .* (colorMask);
        Painting(:,:,2)=Painting(:,:,2)+goodSat .* (colorMask);
        Painting(:,:,3)=Painting(:,:,3)+goodVal .* (colorMask);

    end
    Painting=hsv2rgb(Painting);
    
    % 创建适合scatter宝宝体质的数组
    [x, y] = meshgrid(1:cols, 1:rows); % 创建一个网格，包含所有x和y坐标
    x = x(:); % 将矩阵转换为列向量
    y = y(:); % 将矩阵转换为列向量
    % 直接从图像中提取颜色
    colors = reshape(Painting, [], 3); % 将三维图像矩阵转换为二维颜色矩阵

    scatter(x, y, 5, colors, 'filled');

    %原画
    subplot(1,2,2);
    image=hsv2rgb(image);
    imshow(image);
    title('Color Regions Extracted with Points');

 
end