%����

clear, clc, close all

% ��������������ȡ��ɫ����
extractColorRegion();

% ��̬����HSV��Ĥ�ĺ���
function mask = createDynamicHSVMask(image, hueRange, satRange, valRange)

    % ����HSV��Ĥ������ɫ�ࡢ���ͶȺ����ȷ�Χ��ѡ��ͼ���е��ض�����
   mask = (image(:,:,1) >= hueRange(1) & image(:,:,1) <= hueRange(2)) & ...
           (image(:,:,2) >= satRange(1) & image(:,:,2) <= satRange(2)) & ...
           (image(:,:,3) >= valRange(1) & image(:,:,3) <= valRange(2));

end

% ���ű�����ȡͼ����ȡָ����ɫ��Χ
function extractColorRegion()
    % ��ȡͼ��
    image = imread("D:\LeStoreDownload\Matlab\Program_Files\Polyspace\R2019b\bin\over_littleProgram\program_PointsPainting\BIGtest.png");  % �滻Ϊ���ͼ��·��
    
    % ��RGBͼ��ת��ΪHSVͼ��
    image = rgb2hsv(image); 
    
    % ����
    satRange = [0, 1];      % ���Ͷȷ�Χ
    valRange = [0, 1];      % ���ȷ�Χ
    hueStep = 0.05;  % Hue �Ĳ���
    hueRanges = 0:hueStep:1;  % Hue �ķ�Χ�� 0 �� 1
    
    %��������
    % ��ȡͼ��Ĵ�С
    [rows, cols, channels] = size(image);
    % ����һ����ԭͼ���С��ͬ�İ�ɫ����
    Painting =zeros(rows, cols, channels);
    % ��ʾ��ɫ����
    figure;
    subplot(1,2,1);
    imshow(Painting+1);
    
    %ȫ��Val
    %Val����,���һЩ�����ɫ��
    randomArrayWhite = rand(rows,cols)>0;
    goodSat=image(:,:,2).*randomArrayWhite;
    goodVal=image(:,:,3).*randomArrayWhite;
    goodVal=goodVal+(goodVal==0);
    
    hold on;  % ��ͬһͼ���ϻ���������ȡ�ĵ�

    for i = 1:length(hueRanges)-1
        % ��ǰ�� Hue ��Χ
        hueRange = [hueRanges(i), hueRanges(i+1)];

        % ���ɵ�ǰɫ�෶Χ��HSV��Ĥ
        colorMask = createDynamicHSVMask(image, hueRange, satRange, valRange);
        
        %hue����
        randomArrayHue = hueRanges(i) + randi([0, 1], rows, cols) * hueStep;
        


        Painting(:,:,1)=Painting(:,:,1)+randomArrayHue .* (colorMask);
        Painting(:,:,2)=Painting(:,:,2)+goodSat .* (colorMask);
        Painting(:,:,3)=Painting(:,:,3)+goodVal .* (colorMask);

    end
    Painting=hsv2rgb(Painting);
    
    % �����ʺ�scatter�������ʵ�����
    [x, y] = meshgrid(1:cols, 1:rows); % ����һ�����񣬰�������x��y����
    x = x(:); % ������ת��Ϊ������
    y = y(:); % ������ת��Ϊ������
    % ֱ�Ӵ�ͼ������ȡ��ɫ
    colors = reshape(Painting, [], 3); % ����άͼ�����ת��Ϊ��ά��ɫ����

    scatter(x, y, 5, colors, 'filled');

    %ԭ��
    subplot(1,2,2);
    image=hsv2rgb(image);
    imshow(image);
    title('Color Regions Extracted with Points');

 
end