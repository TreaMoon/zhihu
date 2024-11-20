clear,clc,close all


%初始界面大小
a=20;
global hang lie;
hang=30;
lie=30;
pingmu=get(0,'screensize');

f=figure('menubar','none','numbertitle','off','name','康威的生命游戏','position',[pingmu(3)/4 pingmu(4)/10 (lie+8)*a hang*a]);

%初始化细胞，设定细胞状态
%挨个创建正方形的按钮代表
for i=1:hang
    for j=1:lie
        p(i,j)=uicontrol(f,'style','pushbutton','position',[(j-1)*a (hang-i)*a a a],'userdata',[i,j,0]);%userdata:行列坐标，两种状态
    end
end
%初始点击写颜色
for i=1:hang
    for j=1:lie
        set(p(i,j),'backgroundcolor','w','callback',@(h,e)cell(h,e,p));%为每个案件设置回调函数
    end
end
set(p(1,1),'backgroundcolor','g','enable','on');%0.5为灰色的rgb
set(p(end,end),'backgroundcolor','r','enable','on');
%随机生成，并且可以设置生命密度，即判断概率
randborn=uicontrol(f,'style','pushbutton','string','生成','position',[(lie+1)*a (hang-2.5-6-3)*a 4*a 1.5*a],'FontSize', 16);
set(randborn,'callback',@(h,e)anrandborn(h,e,p));
%设置生命密度
global rho;
rho=0.4;
bornrho=uicontrol(f,'style','edit','string','0.4','position',[(lie+1)*a (hang-2.5-6-4.5)*a 4*a 1.5*a],'FontSize', 16);
set(bornrho,'callback',@(h,e)editbornrho(h,e,p));
%清空所有生命
empty=uicontrol(f,'style','pushbutton','string','清空','position',[(lie+1)*a (hang-2.5-6-6)*a 4*a 1.5*a],'FontSize', 16);
set(empty,'callback',@(h,e)anempty(h,e,p));

%显示所有邻居值
side=uicontrol(f,'style','pushbutton','string','邻居值','position',[(lie+1)*a (hang-2.5-6-6-3)*a 4*a 1.5*a],'FontSize', 16);
set(side,'callback',@(h,e)anside(h,e,p));
%隐藏邻居值（用隐藏更好理解，实际是删除了string）
emptyside=uicontrol(f,'style','pushbutton','string','隐藏邻居值','position',[(lie+1)*a (hang-2.5-6-6-4.5)*a 6*a 1.5*a],'FontSize', 16);
set(emptyside,'callback',@(h,e)anemptyside(h,e,p));

%缓存当前生命分布
cache=uicontrol(f,'style','pushbutton','string','缓存','userdata',zeros(hang,lie),'position',[(lie+1)*a (hang-2.5-6-6-7.5)*a 4*a 1.5*a],'FontSize', 16);
set(cache,'callback',@(h,e)ancache(h,e,p,cache));
%各种内置和缓存的生命分布
wehave=uicontrol(f,'style','popupmenu','string',{'缓存','滑翔机','太空船','脉冲星','蜂王梭'},'position',[(lie+1)*a (hang-2.5-6-6-10.5)*a 6*a 1.5*a],'FontSize', 16);
%按分布矩阵生成
plothave=uicontrol(f,'style','pushbutton','string','快速生成','position',[(lie+1)*a (hang-2.5-6-6-9)*a 6*a 1.5*a],'FontSize', 16);
set(plothave,'callback',@(h,e)anplothave(h,e,p,cache,wehave));

%步进和循环两种演化方式
Se=zeros(hang,lie);
Sd=zeros(hang+2,lie+2);
%步进
bujin=uicontrol(f,'style','pushbutton','string','步进','position',[(lie+1)*a (hang-2.5)*a 4*a 1.5*a],'FontSize', 16);
set(bujin,'callback',@(h,e)anbujin(h,e,p));
%循环
xunhuan=uicontrol(f,'style','pushbutton','string','循环','position',[(lie+1)*a (hang-2.5-3)*a 4*a 1.5*a],'FontSize', 16,'userdata',0);
set(xunhuan,'callback',@(h,e)anxunhuan(h,e,p));
%给循环添加两种速度,按下快，不按则慢
uicontrol(f,'style','text','string','演化速度','position',[(lie+0.2)*a (hang-2.5-4.5)*a 6*a 1.5*a],'FontSize', 16);
global twospeed;
twospeed=0.5;
yanhuasudu=uicontrol(f,'style','edit','string','0.5','position',[(lie+1)*a (hang-2.5-6)*a 4*a 1.5*a],'FontSize', 16);
set(yanhuasudu,'callback',@(h,e)editsudu(h,e,p));



%细胞初始状态设定*手动设定
function cell(h,e,p)
    ind=get(h,'userdata');
    fprintf('\n%d,%d',ind(1),ind(2));
    if ind(3)==0
        ind(3)=1;
    else
        ind(3)=0;
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
function anbujin(h,e,p)
    global hang lie;
    %Se状态矩阵
    Se=zeros(hang,lie);
    for i=1:hang
        for j=1:lie
            ind=get(p(i,j),'userdata');
            Se(i,j)=ind(3);
        end
    end
    %Sd边界矩阵，也是操作矩阵
    Sd=zeros(hang+2,lie+2);%清除上次的残余
    Sd(2:hang+1,2:lie+1)=Se;
    %计算邻居值
    sumValue = Sd(1:hang,1:lie)+Sd(1:hang,2:lie+1)+Sd(1:hang,3:lie+2)+Sd(2:hang+1,1:lie)+Sd(2:hang+1,3:lie+2)+Sd(3:hang+2,1:lie)+Sd(3:hang+2,2:lie+1)+Sd(3:hang+2,3:lie+2);%这里的sumvalue是矩阵对应相加
   %一次性更新状态
    for i=1:hang
        for j=1:lie
            if(sumValue(i,j)==3||(sumValue(i,j)==2&&Se(i,j)==1))
                Se(i,j) = 1;
            else
                Se(i,j) = 0;
            end
        end
    end
    %将状态返回给各个细胞，更改按钮状态，并改变按钮的状态存储数据
    for i=1:hang
        for j=1:lie
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
function anxunhuan(h,e,p)
    global hang lie twospeed;
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
    Se=zeros(hang,lie);
    while(doing)
        %Se状态矩阵
        for i=1:hang
            for j=1:lie
                ind=get(p(i,j),'userdata');
                Se(i,j)=ind(3);
            end
        end
        %Sd边界矩阵，也是操作矩阵
        Sd=zeros(hang+2,lie+2);%清除上次的残余
        Sd(2:hang+1,2:lie+1)=Se;
        %计算邻居值
        sumValue = Sd(1:hang,1:lie)+Sd(1:hang,2:lie+1)+Sd(1:hang,3:lie+2)+Sd(2:hang+1,1:lie)+Sd(2:hang+1,3:lie+2)+Sd(3:hang+2,1:lie)+Sd(3:hang+2,2:lie+1)+Sd(3:hang+2,3:lie+2);%这里的sumvalue是矩阵对应相加
       %一次性更新状态
        for i=1:hang
            for j=1:lie
                if(sumValue(i,j)==3||(sumValue(i,j)==2&&Se(i,j)==1))
                    Se(i,j) = 1;
                else
                    Se(i,j) = 0;
                end
            end
        end
        %将状态返回给各个细胞，更改按钮状态，并改变按钮的状态存储数据
        for i=1:hang
            for j=1:lie
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
function editsudu(h,e,p)
    global twospeed;
    str=get(h,'string');
    twospeed=str2double(str);
end

%随机生成
function anrandborn(h,e,p)
    global hang lie rho;
    Se=rand(hang,lie)<rho;
    for i=1:hang
        for j=1:lie
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
function editbornrho(h,e,p)
    global rho;
    str=get(h,'string');
    rho=str2double(str);
end

%清空
function anempty(h,e,p)
    global hang lie;
    Se=zeros(hang,lie);
    for i=1:hang
            for j=1:lie
                set(p(i,j),'userdata',[i j Se(i,j)]);
                if Se(i,j)==0
                    set(p(i,j),'backgroundcolor','w');
                else
                    set(p(i,j),'backgroundcolor',[0.5 0.5 0.5]);
                end
            end
        end
end

%显示所有邻居值
function anside(h,e,p)
    global hang lie;
    %Se状态矩阵
    Se=zeros(hang,lie);
    for i=1:hang
        for j=1:lie
            ind=get(p(i,j),'userdata');
            Se(i,j)=ind(3);
        end
    end
    %Sd边界矩阵，也是操作矩阵
    Sd=zeros(hang+2,lie+2);%清除上次的残余
    Sd(2:hang+1,2:lie+1)=Se;
    %计算邻居值
    sumValue = Sd(1:hang,1:lie)+Sd(1:hang,2:lie+1)+Sd(1:hang,3:lie+2)+Sd(2:hang+1,1:lie)+Sd(2:hang+1,3:lie+2)+Sd(3:hang+2,1:lie)+Sd(3:hang+2,2:lie+1)+Sd(3:hang+2,3:lie+2);%这里的sumvalue是矩阵对应相加
    for i=1:hang
        for j=1:lie
            if sumValue(i,j)~=0
                set(p(i,j),'string',sumValue(i,j));
            else
                set(p(i,j),'string','');
            end
        end
    end
end

%隐藏邻居值
function anemptyside(h,e,p)
    global hang lie;
    for i=1:hang
        for j=1:lie
            set(p(i,j),'string','');
        end
    end
end

%缓存
function ancache(h,e,p,cache)
    global hang lie;
    %Se状态矩阵
    Se=zeros(hang,lie);
    for i=1:hang
        for j=1:lie
            ind=get(p(i,j),'userdata');
            Se(i,j)=ind(3);
        end
    end
    set(cache,'userdata',Se);
end

%快速生成
function anplothave(h,e,p,cache,wehave)
    global hang lie;
    Se=zeros(hang,lie);
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
    end
    for i=1:hang
        for j=1:lie
            set(p(i,j),'userdata',[i j Se(i,j)]);
            if Se(i,j)==0
                set(p(i,j),'backgroundcolor','w');
            else
                set(p(i,j),'backgroundcolor',[0.5 0.5 0.5]);
            end
        end
    end
end









