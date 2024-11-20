clear,clc,close all



%初始界面大小：因为历史原因，初代代码的格子大小仍被使用来定义屏幕大小
a=20;%初代格子大小
b=15;%单个格子大小
global g_hang g_lie g_oldhang g_oldlie;

%格子行列数目:在创建格子和遍历每个格子时使用（更新状态、储存分布）
g_hang=40;
g_lie=40;

%只用来设置屏幕大小和按钮位置，初代代码遗留参数
g_oldhang=30;
g_oldlie=30;
pingmu=get(0,'screensize');
f=figure('menubar','none','numbertitle','off','name','康威的生命游戏', ...
    'position',[pingmu(3)/4 pingmu(4)/10 (g_oldhang+8)*a g_oldlie*a]);



%初始化细胞，设定细胞状态
%循环创建正方形的按钮代表格子。userdata:行列坐标，两种状态
for i=1:g_hang
    for j=1:g_lie
        p(i,j)=uicontrol(f,'style','pushbutton','position',[(j-1)*b (g_hang-i)*b b b], ...
            'userdata',[i,j,0]);
    end
end

%定标，确认i，j是对应着行列
set(p(1,1),'backgroundcolor','g','enable','on');%左上角是绿色格子（1，1）
set(p(end,end),'backgroundcolor','r','enable','on');%右下角是红色格子（end，end）

%点击改写颜色
for i=1:g_hang
    for j=1:g_lie
        set(p(i,j),'backgroundcolor','w','callback',@(h,e)cell(h,p));
    end
end

%随机生成，并且可以设置生命密度，即判断概率
randborn=uicontrol(f,'style','pushbutton','string','按密度生成', ...
    'position',[(g_oldlie+1)*a (g_oldhang-2.5-6-3)*a 6*a 1.5*a],'FontSize', 16);
set(randborn,'callback',@(h,e)anrandborn(p));

%设置生命密度
global rho;
rho=0.4;
bornrho=uicontrol(f,'style','edit','string','0.4', ...
    'position',[(g_oldlie+1)*a (g_oldhang-2.5-6-4.5)*a 4*a 1.5*a],'FontSize', 16);
set(bornrho,'callback',@(h,e)editbornrho(h));

%清空所有生命
empty=uicontrol(f,'style','pushbutton','string','清空', ...
    'position',[(g_oldlie+1)*a (g_oldhang-2.5-6-6)*a 4*a 1.5*a],'FontSize', 16);
set(empty,'callback',@(h,e)anempty(p));



%显示所有邻居值
side=uicontrol(f,'style','pushbutton','string','邻居值', ...
    'position',[(g_oldlie+1)*a (g_oldhang-2.5-6-6-3)*a 4*a 1.5*a],'FontSize', 16);
set(side,'callback',@(h,e)anside(p));

%隐藏邻居值（用隐藏更好理解，实际是删除了string)
emptyside=uicontrol(f,'style','pushbutton','string','隐藏邻居值', ...
    'position',[(g_oldlie+1)*a (g_oldhang-2.5-6-6-4.5)*a 6*a 1.5*a],'FontSize', 16);
set(emptyside,'callback',@(h,e)anemptyside(p));



%缓存当前生命分布
cache=uicontrol(f,'style','pushbutton','string','缓存','userdata',zeros(g_hang,g_lie), ...
    'position',[(g_oldlie+1)*a (g_oldhang-2.5-6-6-7.5)*a 4*a 1.5*a],'FontSize', 16);
set(cache,'callback',@(h,e)ancache(p,cache));

%各种内置和缓存的生命分布
wehave = uicontrol(f, 'style', 'popupmenu', 'string', ...
    {'缓存', '滑翔机', '太空船', '脉冲星', '蜂王梭','滑翔机枪', '振荡器', '火山喷发', '风车', '时钟', ...
    '哼哧哼哧', '传送门', '随机表情', '蝴蝶机'}, ...
    'position', [(g_oldlie+1)*a (g_oldhang-2.5-6-6-10.5)*a 6*a 1.5*a], 'FontSize', 16);

%按分布矩阵生成
plothave=uicontrol(f,'style','pushbutton','string','快速生成', ...
    'position',[(g_oldlie+1)*a (g_oldhang-2.5-6-6-9)*a 6*a 1.5*a],'FontSize', 16);
set(plothave,'callback',@(h,e)anplothave(p,cache,wehave));



%步进和循环两种演化方式
Se=zeros(g_hang,g_lie);           %生命分布矩阵
Sd=zeros(g_hang+2,g_lie+2);  %边界大小为一个格子的边界矩阵

%步进
bujin=uicontrol(f,'style','pushbutton','string','步进', ...
    'position',[(g_oldlie+1)*a (g_oldhang-2.5)*a 4*a 1.5*a],'FontSize', 16);
set(bujin,'callback',@(h,e)anbujin(p));

%循环
xunhuan=uicontrol(f,'style','pushbutton','string','循环', ...
    'position',[(g_oldlie+1)*a (g_oldhang-2.5-3)*a 4*a 1.5*a],'FontSize', 16,'userdata',0);
set(xunhuan,'callback',@(h,e)anxunhuan(h,p));

%循环可以设置演化速度，初始为演化一次停0.1s
uicontrol(f,'style','text','string','演化速度', ...
    'position',[(g_oldlie+0.2)*a (g_oldhang-2.5-4.5)*a 6*a 1.5*a],'FontSize', 16);
global twospeed;
twospeed=0.1;
yanhuasudu=uicontrol(f,'style','edit','string','0.1', ...
    'position',[(g_oldlie+1)*a (g_oldhang-2.5-6)*a 4*a 1.5*a],'FontSize', 16);
set(yanhuasudu,'callback',@(h,e)editsudu(h));



%回调函数
%细胞初始状态设定*手动设定
function cell(h,p,~)
    ind=get(h,'userdata');
    if ind(3)==0
        ind(3)=1;
        fprintf('\nSe(%d,%d)=1;',ind(1),ind(2));
    else
        ind(3)=0;
        fprintf('\nSe(%d,%d)=0;',ind(1),ind(2));
    end
    %上色
    if ind(3)==1
        set(p(ind(1),ind(2)),'backgroundcolor',[0.5 0.5 0.5]);
    else
        set(p(ind(1),ind(2)),'backgroundcolor','w');
    end
    set(h,'userdata',ind);
end

%步进
function anbujin(p,~)
    global g_hang g_lie;
    %Se状态矩阵
    Se=zeros(g_hang,g_lie);
    for i=1:g_hang
        for j=1:g_lie
            ind=get(p(i,j),'userdata');
            Se(i,j)=ind(3);
        end
    end
    %Sd边界矩阵
    Sd=zeros(g_hang+2,g_lie+2);%清除上次的残余
    Sd(2:g_hang+1,2:g_lie+1)=Se;
    %计算邻居值,通过矩阵对应相加
    sumValue = Sd(1:g_hang,1:g_lie)+Sd(1:g_hang,2:g_lie+1)+Sd(1:g_hang,3:g_lie+2) ...
                        +Sd(2:g_hang+1,1:g_lie)+Sd(2:g_hang+1,3:g_lie+2)+Sd(3:g_hang+2,1:g_lie) ...
                        +Sd(3:g_hang+2,2:g_lie+1)+Sd(3:g_hang+2,3:g_lie+2);
   %一次性更新状态
    for i=1:g_hang
        for j=1:g_lie
            if(sumValue(i,j)==3||(sumValue(i,j)==2&&Se(i,j)==1))
                Se(i,j) = 1;
            else
                Se(i,j) = 0;
            end
        end
    end
    %将状态返回给各个细胞，更改按钮状态，并改变按钮的状态存储数据
    for i=1:g_hang
        for j=1:g_lie
            set(p(i,j),'userdata',[i j Se(i,j)]);
            if Se(i,j)==0
                set(p(i,j),'backgroundcolor','w');
            else
                set(p(i,j),'backgroundcolor',[0.5 0.5 0.5]);
            end
        end
    end
end

%循环
function anxunhuan(h,p,~)
    global g_hang g_lie twospeed;
    %按一次开始，再按一次停止
    global doing;
    doing=get(h,'userdata');
    if doing==0
        doing=1;
    else
        doing=0;
    end
    set(h,'userdata',doing);
    %根据doing可以停止或启动循环
    Se=zeros(g_hang,g_lie);
    while(doing)
        %Se状态矩阵
        for i=1:g_hang
            for j=1:g_lie
                ind=get(p(i,j),'userdata');
                Se(i,j)=ind(3);
            end
        end
        %Sd边界矩阵，也是操作矩阵
        Sd=zeros(g_hang+2,g_lie+2);%清除上次的残余
        Sd(2:g_hang+1,2:g_lie+1)=Se;
        %计算邻居值
        sumValue = Sd(1:g_hang,1:g_lie)+Sd(1:g_hang,2:g_lie+1)+Sd(1:g_hang,3:g_lie+2) ...
                            +Sd(2:g_hang+1,1:g_lie)+Sd(2:g_hang+1,3:g_lie+2)+Sd(3:g_hang+2,1:g_lie) ...
                            +Sd(3:g_hang+2,2:g_lie+1)+Sd(3:g_hang+2,3:g_lie+2);
       %一次性更新状态
        for i=1:g_hang
            for j=1:g_lie
                if(sumValue(i,j)==3||(sumValue(i,j)==2&&Se(i,j)==1))
                    Se(i,j) = 1;
                else
                    Se(i,j) = 0;
                end
            end
        end
        %将状态返回给各个细胞，更改按钮状态，并改变按钮的状态存储数据
        for i=1:g_hang
            for j=1:g_lie
                set(p(i,j),'userdata',[i j Se(i,j)]);
                if Se(i,j)==0
                    set(p(i,j),'backgroundcolor','w');
                else
                    set(p(i,j),'backgroundcolor',[0.5 0.5 0.5]);
                end
            end
        end
        pause(twospeed);
    end
end

%演化速度
function editsudu(h,~)
    global twospeed;
    str=get(h,'string');
    twospeed=str2double(str);
end

%随机生成
function anrandborn(p,~)
    global g_hang g_lie rho;
    Se=rand(g_hang,g_lie)<rho;
    for i=1:g_hang
        for j=1:g_lie
            set(p(i,j),'userdata',[i j Se(i,j)]);
            if Se(i,j)==0
                set(p(i,j),'backgroundcolor','w');
            else
                set(p(i,j),'backgroundcolor',[0.5 0.5 0.5]);
            end
        end
    end
end

%生命密度
function editbornrho(h)
    global rho;
    str=get(h,'string');
    rho=str2double(str);
end

%清空
function anempty(p,~)
    global g_hang g_lie;
    Se=zeros(g_hang,g_lie);
    for i=1:g_hang
            for j=1:g_lie
                set(p(i,j),'userdata',[i j Se(i,j)]);
                if Se(i,j)==0
                    set(p(i,j),'backgroundcolor','w');
                else
                    set(p(i,j),'backgroundcolor',[0.5 0.5 0.5]);
                end
            end
    end
    clc
end

%显示所有邻居值
function anside(p,~)
    global g_hang g_lie;
    %Se状态矩阵
    Se=zeros(g_hang,g_lie);
    for i=1:g_hang
        for j=1:g_lie
            ind=get(p(i,j),'userdata');
            Se(i,j)=ind(3);
        end
    end
    %Sd边界矩阵，也是操作矩阵
    Sd=zeros(g_hang+2,g_lie+2);%清除上次的残余
    Sd(2:g_hang+1,2:g_lie+1)=Se;
    %计算邻居值
    sumValue = Sd(1:g_hang,1:g_lie)+Sd(1:g_hang,2:g_lie+1)+Sd(1:g_hang,3:g_lie+2) ...
                        +Sd(2:g_hang+1,1:g_lie)+Sd(2:g_hang+1,3:g_lie+2)+Sd(3:g_hang+2,1:g_lie) ...
                        +Sd(3:g_hang+2,2:g_lie+1)+Sd(3:g_hang+2,3:g_lie+2);
    for i=1:g_hang
        for j=1:g_lie
            if sumValue(i,j)~=0
                set(p(i,j),'string',sumValue(i,j));
            else
                set(p(i,j),'string','');
            end
        end
    end
end

%隐藏邻居值
function anemptyside(p,~)
    global g_hang g_lie;
    for i=1:g_hang
        for j=1:g_lie
            set(p(i,j),'string','');
        end
    end
end

%缓存
function ancache(p,cache,~)
    global g_hang g_lie;
    %Se状态矩阵
    Se=zeros(g_hang,g_lie);
    for i=1:g_hang
        for j=1:g_lie
            ind=get(p(i,j),'userdata');
            Se(i,j)=ind(3);
        end
    end
    set(cache,'userdata',Se);
end

%快速生成
function anplothave(p,cache,wehave,~)
    global g_hang g_lie;
    Se=zeros(g_hang,g_lie);
    var=get(wehave,'Value');
    switch var
        case 1
            Se=get(cache,'userdata');
        case 2
            Se(2,1)=1;
            Se(3,2)=1;
            Se(1,3)=1;
            Se(2,3)=1;
            Se(3,3)=1;
        case 3
            Se(13,2)=1;
            Se(15,2)=1;
            Se(12,3:8)=1;
            Se(13,8)=1;
            Se(14,8)=1;
            Se(15,7)=1;
            Se(16,5)=1;
        case 4
            Se(10:12,14)=1;
            Se(10:12,16)=1;
            Se(16:18,14)=1;
            Se(16:18,16)=1;
            Se(13,17:19)=1;
            Se(15,17:19)=1;
            Se(13,11:13)=1;
            Se(15,11:13)=1;
            Se(10:12,9)=1;
            Se(8,11:13)=1;
            Se(8,17:19)=1;
            Se(10:12,21)=1;
            Se(16:18,21)=1;
            Se(20,17:19)=1;
            Se(20,11:13)=1;
            Se(16:18,9)=1;
        case 5
            Se(12:13,4:5)=1;
            Se(11:13,10:11)=1;
            Se(10,12)=1;
            Se(9:10,14)=1;
            Se(14,12:2:14)=1;
            Se(15,14)=1;
            Se(12:13,24:25)=1;
        case 6
            Se(10:11,3:4)=1;
            Se(11,13)=1;
            Se(10:12,14)=1;
            Se(9:13,15)=1;
            Se([8,9,13,14],16)=1;
            Se(9:13,17)=1;
            Se([9,13],18)=1;
            Se([10,12],19)=1;
            Se(11,20)=1;
            Se(10:11,24)=1;
            Se(9,23)=1;
            Se(7:8,24)=1;
            Se([6,12],26)=1;
            Se([6,7,9,11,12],28)=1;
            Se(8:9,37:38)=1;
        case 7
            Se(14:18,21)=1;
            Se(16,[22,24,17,19,27,29])=1;
            Se(14:18,25)=1;
            Se([14,12,18,20],23)=1;
            Se([13,19],[22,24])=1;
            Se([12,18,20],23)=1;
            Se(16,[17,19,27,29])=1;
            Se(15,[18,28])=1;
            Se(17,[18,28])=1;
        case 8
            Se(10,17:22)=1;
            Se(10,[12,27])=1;
            Se(11,[10,11,12,27,28,29,16,17,22,23])=1;
            Se(12:16,[9,30])=1;
            Se(12,[15,24])=1;
            Se(13,[15,16,17,22,23,24,27,28,11,12])=1;
            Se(14,[8,31,11,14,17,18,21,22,25,28])=1;
            Se(15,12:16)=1;
            Se(15,23:27)=1;
            Se(16:19,[17,22])=1;
            Se([18,19],[19,20])=1;
            Se(17,[10,11,12,14,15,24,25,27,28,29])=1;
            Se([18,19,21],[12,27])=1;
            Se(18,[14,25])=1;
            Se(19:23,[15,24])=1;
            Se([20,21],[13,26])=1;
            Se(20,[18,21])=1;
            Se(23,[17,22])=1;
            Se(24,[16,17,23,22])=1;
        case 9
            Se(18,21)=1;
            Se(17,20)=1;
            Se(17,19)=1;
            Se(16,19)=1;
            Se(15,19)=1;
            Se(14,19)=1;
            Se(14,20)=1;
            Se(17,22)=1;
            Se(16,22)=1;
            Se(16,23)=1;
            Se(16,24)=1;
            Se(16,25)=1;
            Se(17,25)=1;
            Se(19,22)=1;
            Se(19,23)=1;
            Se(20,23)=1;
            Se(21,23)=1;
            Se(22,23)=1;
            Se(22,22)=1;
            Se(19,20)=1;
            Se(20,20)=1;
            Se(20,19)=1;
            Se(20,18)=1;
            Se(20,17)=1;
            Se(19,17)=1;
        case 10
            Se(14,21)=1;
            Se(15,21)=1;
            Se(16,21)=1;
            Se(17,21)=1;
            Se(18,20)=1;
            Se(19,20)=1;
            Se(20,20)=1;
            Se(21,20)=1;
            Se(18,22)=1;
            Se(19,22)=1;
            Se(20,22)=1;
            Se(15,23)=1;
            Se(16,23)=1;
            Se(17,23)=1;
            Se(15,19)=1;
            Se(16,19)=1;
            Se(17,19)=1;
            Se(18,18)=1;
            Se(19,18)=1;
            Se(20,18)=1;
            Se(16,17)=1;
            Se(17,17)=1;
            Se(18,16)=1;
            Se(19,16)=1;
            Se(17,15)=1;
            Se(18,24)=1;
            Se(19,24)=1;
            Se(16,25)=1;
            Se(17,25)=1;
            Se(18,26)=1;
        case 11
            Se(16,5)=1;
            Se(20,5)=1;
            Se(15,6)=1;
            Se(16,7)=1;
            Se(21,6)=1;
            Se(20,7)=1;
            Se(17,7)=1;
            Se(17,8)=1;
            Se(17,9)=1;
            Se(17,10)=1;
            Se(16,10)=1;
            Se(19,7)=1;
            Se(19,8)=1;
            Se(19,9)=1;
            Se(19,10)=1;
            Se(20,10)=1;
            Se(16,12)=1;
            Se(17,12)=1;
            Se(16,13)=1;
            Se(19,12)=1;
            Se(20,12)=1;
            Se(20,13)=1;
            Se(17,14)=1;
            Se(18,14)=1;
            Se(19,14)=1;
            Se(17,15)=1;
            Se(19,15)=1;
            Se(17,17)=1;
            Se(18,17)=1;
            Se(19,17)=1;
            Se(17,21)=1;
            Se(18,21)=1;
            Se(19,21)=1;
            Se(17,25)=1;
            Se(18,25)=1;
            Se(19,25)=1;
            Se(17,29)=1;
            Se(18,29)=1;
            Se(19,29)=1;
        case 12
            Se(14,12)=1;
            Se(14,13)=1;
            Se(14,14)=1;
            Se(14,15)=1;
            Se(14,16)=1;
            Se(14,17)=1;
            Se(15,17)=1;
            Se(15,16)=1;
            Se(15,15)=1;
            Se(15,14)=1;
            Se(15,13)=1;
            Se(15,12)=1;
            Se(14,19)=1;
            Se(14,20)=1;
            Se(15,19)=1;
            Se(15,20)=1;
            Se(16,19)=1;
            Se(16,20)=1;
            Se(17,19)=1;
            Se(17,20)=1;
            Se(18,19)=1;
            Se(18,20)=1;
            Se(19,19)=1;
            Se(19,20)=1;
            Se(17,12)=1;
            Se(17,13)=1;
            Se(18,12)=1;
            Se(18,13)=1;
            Se(19,12)=1;
            Se(19,13)=1;
            Se(20,12)=1;
            Se(21,12)=1;
            Se(22,12)=1;
            Se(20,13)=1;
            Se(21,13)=1;
            Se(22,13)=1;
            Se(21,15)=1;
            Se(22,15)=1;
            Se(21,16)=1;
            Se(22,16)=1;
            Se(21,17)=1;
            Se(22,17)=1;
            Se(21,18)=1;
            Se(22,18)=1;
            Se(21,19)=1;
            Se(22,19)=1;
            Se(21,20)=1;
            Se(22,20)=1;
        case 13
            Se(7,21)=1;
            Se(7,22)=1;
            Se(7,23)=1;
            Se(8,20)=1;
            Se(8,21)=1;
            Se(8,22)=1;
            Se(8,23)=1;
            Se(8,24)=1;
            Se(9,24)=1;
            Se(10,24)=1;
            Se(11,24)=1;
            Se(12,24)=1;
            Se(9,20)=1;
            Se(10,20)=1;
            Se(11,20)=1;
            Se(12,20)=1;
            Se(13,20)=1;
            Se(9,21)=1;
            Se(9,22)=1;
            Se(9,23)=1;
            Se(10,21)=1;
            Se(10,22)=1;
            Se(10,23)=1;
            Se(11,21)=1;
            Se(11,22)=1;
            Se(11,23)=1;
            Se(12,21)=1;
            Se(12,22)=1;
            Se(12,23)=1;
            Se(13,21)=1;
            Se(13,22)=1;
            Se(13,23)=1;
            Se(13,24)=1;
            Se(11,19)=1;
            Se(11,25)=1;
            Se(12,19)=1;
            Se(13,19)=1;
            Se(14,19)=1;
            Se(15,19)=1;
            Se(12,25)=1;
            Se(13,25)=1;
            Se(14,25)=1;
            Se(15,25)=1;
            Se(16,18)=1;
            Se(17,18)=1;
            Se(18,18)=1;
            Se(20,18)=1;
            Se(19,18)=1;
            Se(16,26)=1;
            Se(17,26)=1;
            Se(18,26)=1;
            Se(19,26)=1;
            Se(20,26)=1;
            Se(14,20)=1;
            Se(14,21)=1;
            Se(14,22)=1;
            Se(14,23)=1;
            Se(14,24)=1;
            Se(15,20)=1;
            Se(15,21)=1;
            Se(15,22)=1;
            Se(15,23)=1;
            Se(15,24)=1;
            Se(16,19)=1;
            Se(16,21)=1;
            Se(16,20)=1;
            Se(16,22)=1;
            Se(16,23)=1;
            Se(16,24)=1;
            Se(16,25)=1;
            Se(17,19)=1;
            Se(18,19)=1;
            Se(19,19)=1;
            Se(20,20)=1;
            Se(17,21)=1;
            Se(17,20)=1;
            Se(18,20)=1;
            Se(19,20)=1;
            Se(18,21)=1;
            Se(20,19)=1;
            Se(19,21)=1;
            Se(20,21)=1;
            Se(20,22)=1;
            Se(20,23)=1;
            Se(20,24)=1;
            Se(20,25)=1;
            Se(19,25)=1;
            Se(18,25)=1;
            Se(17,25)=1;
            Se(17,24)=1;
            Se(17,23)=1;
            Se(17,22)=1;
            Se(18,22)=1;
            Se(18,23)=1;
            Se(18,24)=1;
            Se(19,24)=1;
            Se(19,23)=1;
            Se(19,22)=1;
            Se(18,16)=1;
            Se(19,16)=1;
            Se(20,16)=1;
            Se(17,15)=1;
            Se(16,15)=1;
            Se(15,15)=1;
            Se(14,15)=1;
            Se(13,15)=1;
            Se(12,14)=1;
            Se(12,12)=1;
            Se(12,13)=1;
            Se(13,11)=1;
            Se(14,11)=1;
            Se(15,11)=1;
            Se(16,11)=1;
            Se(17,11)=1;
            Se(18,10)=1;
            Se(19,10)=1;
            Se(20,10)=1;
            Se(13,12)=1;
            Se(13,13)=1;
            Se(13,14)=1;
            Se(14,12)=1;
            Se(14,13)=1;
            Se(14,14)=1;
            Se(15,12)=1;
            Se(15,13)=1;
            Se(15,14)=1;
            Se(16,12)=1;
            Se(16,13)=1;
            Se(16,14)=1;
            Se(17,12)=1;
            Se(17,13)=1;
            Se(17,14)=1;
            Se(18,11)=1;
            Se(19,11)=1;
            Se(20,11)=1;
            Se(18,12)=1;
            Se(18,13)=1;
            Se(18,15)=1;
            Se(18,14)=1;
            Se(19,14)=1;
            Se(20,14)=1;
            Se(19,15)=1;
            Se(20,15)=1;
            Se(19,13)=1;
            Se(20,13)=1;
            Se(19,12)=1;
            Se(20,12)=1;
            Se(21,16)=1;
            Se(21,17)=1;
            Se(21,19)=1;
            Se(21,18)=1;
            Se(21,10)=1;
            Se(21,12)=1;
            Se(21,13)=1;
            Se(21,14)=1;
            Se(21,15)=1;
            Se(21,11)=1;
            Se(22,10)=1;
            Se(23,10)=1;
            Se(24,10)=1;
            Se(25,10)=1;
            Se(26,10)=1;
            Se(26,11)=1;
            Se(26,12)=1;
            Se(26,13)=1;
            Se(26,14)=1;
            Se(26,17)=1;
            Se(26,18)=1;
            Se(26,19)=1;
            Se(26,20)=1;
            Se(26,21)=1;
            Se(26,22)=1;
            Se(26,23)=1;
            Se(26,24)=1;
            Se(26,25)=1;
            Se(26,26)=1;
            Se(26,27)=1;
            Se(26,28)=1;
            Se(26,29)=1;
            Se(26,30)=1;
            Se(26,31)=1;
            Se(26,32)=1;
            Se(26,33)=1;
            Se(21,26)=1;
            Se(21,27)=1;
            Se(21,28)=1;
            Se(20,28)=1;
            Se(19,28)=1;
            Se(18,28)=1;
            Se(17,29)=1;
            Se(16,29)=1;
            Se(15,29)=1;
            Se(14,29)=1;
            Se(13,29)=1;
            Se(12,30)=1;
            Se(12,32)=1;
            Se(12,31)=1;
            Se(13,33)=1;
            Se(14,33)=1;
            Se(15,33)=1;
            Se(16,33)=1;
            Se(17,33)=1;
            Se(18,34)=1;
            Se(19,34)=1;
            Se(20,34)=1;
            Se(21,34)=1;
            Se(22,34)=1;
            Se(23,34)=1;
            Se(24,34)=1;
            Se(25,34)=1;
            Se(26,34)=1;
            Se(13,30)=1;
            Se(13,31)=1;
            Se(13,32)=1;
            Se(14,30)=1;
            Se(15,30)=1;
            Se(16,30)=1;
            Se(17,30)=1;
            Se(18,30)=1;
            Se(19,30)=1;
            Se(20,30)=1;
            Se(21,30)=1;
            Se(22,30)=1;
            Se(23,30)=1;
            Se(24,30)=1;
            Se(25,30)=1;
            Se(14,31)=1;
            Se(15,31)=1;
            Se(16,31)=1;
            Se(17,31)=1;
            Se(18,31)=1;
            Se(19,31)=1;
            Se(20,31)=1;
            Se(21,31)=1;
            Se(22,31)=1;
            Se(23,31)=1;
            Se(25,31)=1;
            Se(24,31)=1;
            Se(14,32)=1;
            Se(15,32)=1;
            Se(16,32)=1;
            Se(17,32)=1;
            Se(18,32)=1;
            Se(19,32)=1;
            Se(20,32)=1;
            Se(21,32)=1;
            Se(22,32)=1;
            Se(23,32)=1;
            Se(24,32)=1;
            Se(25,32)=1;
            Se(18,33)=1;
            Se(19,33)=1;
            Se(21,33)=1;
            Se(22,33)=1;
            Se(23,33)=1;
            Se(24,33)=1;
            Se(25,33)=1;
            Se(20,33)=1;
            Se(18,29)=1;
            Se(19,29)=1;
            Se(20,29)=1;
            Se(21,29)=1;
            Se(22,29)=1;
            Se(23,29)=1;
            Se(24,29)=1;
            Se(25,29)=1;
            Se(21,21)=1;
            Se(21,22)=1;
            Se(21,23)=1;
            Se(21,24)=1;
            Se(21,25)=1;
            Se(21,20)=1;
            Se(22,11)=1;
            Se(23,11)=1;
            Se(24,11)=1;
            Se(25,11)=1;
            Se(22,12)=1;
            Se(23,12)=1;
            Se(24,12)=1;
            Se(25,12)=1;
            Se(23,13)=1;
            Se(22,13)=1;
            Se(22,14)=1;
            Se(24,13)=1;
            Se(25,13)=1;
            Se(23,14)=1;
            Se(24,14)=1;
            Se(25,14)=1;
            Se(22,15)=1;
            Se(23,15)=1;
            Se(24,15)=1;
            Se(25,15)=1;
            Se(22,16)=1;
            Se(23,16)=1;
            Se(24,16)=1;
            Se(25,16)=1;
            Se(22,17)=1;
            Se(24,17)=1;
            Se(23,17)=1;
            Se(25,17)=1;
            Se(22,18)=1;
            Se(23,18)=1;
            Se(24,18)=1;
            Se(25,18)=1;
            Se(22,19)=1;
            Se(23,19)=1;
            Se(24,19)=1;
            Se(25,19)=1;
            Se(22,20)=1;
            Se(23,20)=1;
            Se(24,20)=1;
            Se(25,20)=1;
            Se(22,21)=1;
            Se(23,21)=1;
            Se(24,21)=1;
            Se(25,21)=1;
            Se(22,22)=1;
            Se(23,22)=1;
            Se(24,22)=1;
            Se(25,22)=1;
            Se(22,23)=1;
            Se(23,23)=1;
            Se(24,23)=1;
            Se(25,23)=1;
            Se(22,24)=1;
            Se(23,24)=1;
            Se(24,24)=1;
            Se(25,24)=1;
            Se(22,25)=1;
            Se(23,25)=1;
            Se(24,25)=1;
            Se(25,25)=1;
            Se(22,26)=1;
            Se(23,26)=1;
            Se(24,26)=1;
            Se(26,15)=1;
            Se(26,16)=1;
            Se(25,26)=1;
            Se(23,27)=1;
            Se(24,27)=1;
            Se(25,27)=1;
            Se(24,28)=1;
            Se(25,28)=1;
            Se(23,28)=1;
            Se(22,28)=1;
            Se(22,27)=1;
        case 14
            Se(15,4)=1;
            Se(14,3)=1;
            Se(12,3)=1;
            Se(11,5)=1;
            Se(11,6)=1;
            Se(10,7)=1;
            Se(8,7)=1;
            Se(7,8)=1;
            Se(7,9)=1;
            Se(7,10)=1;
            Se(7,11)=1;
            Se(7,12)=1;
            Se(7,13)=1;
            Se(15,5)=1;
            Se(15,6)=1;
            Se(15,7)=1;
            Se(15,8)=1;
            Se(15,10)=1;
            Se(15,9)=1;
            Se(15,11)=1;
            Se(15,12)=1;
            Se(15,13)=1;
            Se(8,13)=1;
            Se(9,13)=1;
            Se(10,12)=1;
            Se(12,14)=1;
            Se(13,15)=1;
            Se(14,15)=1;
            Se(15,15)=1;
            Se(15,14)=1;
            Se(19,13)=1;
            Se(20,13)=1;
            Se(21,13)=1;
            Se(19,12)=1;
            Se(19,11)=1;
            Se(19,10)=1;
            Se(19,9)=1;
            Se(19,8)=1;
            Se(20,7)=1;
            Se(22,7)=1;
            Se(22,12)=1;
            Se(23,10)=1;
            Se(23,9)=1;
    end
    for i=1:g_hang
        for j=1:g_lie
            set(p(i,j),'userdata',[i j Se(i,j)]);
            if Se(i,j)==0
                set(p(i,j),'backgroundcolor','w');
            else
                set(p(i,j),'backgroundcolor',[0.5 0.5 0.5]);
            end
        end
    end
end