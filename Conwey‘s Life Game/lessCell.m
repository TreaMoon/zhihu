clear,clc,close all


%��ʼ�����С
a=20;
global hang lie;
hang=30;
lie=30;
pingmu=get(0,'screensize');

f=figure('menubar','none','numbertitle','off','name','������������Ϸ','position',[pingmu(3)/4 pingmu(4)/10 (lie+8)*a hang*a]);

%��ʼ��ϸ�����趨ϸ��״̬
%�������������εİ�ť����
for i=1:hang
    for j=1:lie
        p(i,j)=uicontrol(f,'style','pushbutton','position',[(j-1)*a (hang-i)*a a a],'userdata',[i,j,0]);%userdata:�������꣬����״̬
    end
end
%��ʼ���д��ɫ
for i=1:hang
    for j=1:lie
        set(p(i,j),'backgroundcolor','w','callback',@(h,e)cell(h,e,p));%Ϊÿ���������ûص�����
    end
end
set(p(1,1),'backgroundcolor','g','enable','on');%0.5Ϊ��ɫ��rgb
set(p(end,end),'backgroundcolor','r','enable','on');
%������ɣ����ҿ������������ܶȣ����жϸ���
randborn=uicontrol(f,'style','pushbutton','string','����','position',[(lie+1)*a (hang-2.5-6-3)*a 4*a 1.5*a],'FontSize', 16);
set(randborn,'callback',@(h,e)anrandborn(h,e,p));
%���������ܶ�
global rho;
rho=0.4;
bornrho=uicontrol(f,'style','edit','string','0.4','position',[(lie+1)*a (hang-2.5-6-4.5)*a 4*a 1.5*a],'FontSize', 16);
set(bornrho,'callback',@(h,e)editbornrho(h,e,p));
%�����������
empty=uicontrol(f,'style','pushbutton','string','���','position',[(lie+1)*a (hang-2.5-6-6)*a 4*a 1.5*a],'FontSize', 16);
set(empty,'callback',@(h,e)anempty(h,e,p));

%��ʾ�����ھ�ֵ
side=uicontrol(f,'style','pushbutton','string','�ھ�ֵ','position',[(lie+1)*a (hang-2.5-6-6-3)*a 4*a 1.5*a],'FontSize', 16);
set(side,'callback',@(h,e)anside(h,e,p));
%�����ھ�ֵ�������ظ�����⣬ʵ����ɾ����string��
emptyside=uicontrol(f,'style','pushbutton','string','�����ھ�ֵ','position',[(lie+1)*a (hang-2.5-6-6-4.5)*a 6*a 1.5*a],'FontSize', 16);
set(emptyside,'callback',@(h,e)anemptyside(h,e,p));

%���浱ǰ�����ֲ�
cache=uicontrol(f,'style','pushbutton','string','����','userdata',zeros(hang,lie),'position',[(lie+1)*a (hang-2.5-6-6-7.5)*a 4*a 1.5*a],'FontSize', 16);
set(cache,'callback',@(h,e)ancache(h,e,p,cache));
%�������úͻ���������ֲ�
wehave=uicontrol(f,'style','popupmenu','string',{'����','�����','̫�մ�','������','������'},'position',[(lie+1)*a (hang-2.5-6-6-10.5)*a 6*a 1.5*a],'FontSize', 16);
%���ֲ���������
plothave=uicontrol(f,'style','pushbutton','string','��������','position',[(lie+1)*a (hang-2.5-6-6-9)*a 6*a 1.5*a],'FontSize', 16);
set(plothave,'callback',@(h,e)anplothave(h,e,p,cache,wehave));

%������ѭ�������ݻ���ʽ
Se=zeros(hang,lie);
Sd=zeros(hang+2,lie+2);
%����
bujin=uicontrol(f,'style','pushbutton','string','����','position',[(lie+1)*a (hang-2.5)*a 4*a 1.5*a],'FontSize', 16);
set(bujin,'callback',@(h,e)anbujin(h,e,p));
%ѭ��
xunhuan=uicontrol(f,'style','pushbutton','string','ѭ��','position',[(lie+1)*a (hang-2.5-3)*a 4*a 1.5*a],'FontSize', 16,'userdata',0);
set(xunhuan,'callback',@(h,e)anxunhuan(h,e,p));
%��ѭ����������ٶ�,���¿죬��������
uicontrol(f,'style','text','string','�ݻ��ٶ�','position',[(lie+0.2)*a (hang-2.5-4.5)*a 6*a 1.5*a],'FontSize', 16);
global twospeed;
twospeed=0.5;
yanhuasudu=uicontrol(f,'style','edit','string','0.5','position',[(lie+1)*a (hang-2.5-6)*a 4*a 1.5*a],'FontSize', 16);
set(yanhuasudu,'callback',@(h,e)editsudu(h,e,p));



%ϸ����ʼ״̬�趨*�ֶ��趨
function cell(h,e,p)
    ind=get(h,'userdata');
    fprintf('\n%d,%d',ind(1),ind(2));
    if ind(3)==0
        ind(3)=1;
    else
        ind(3)=0;
    end
    %��ɫ
    if ind(3)==1
        set(p(ind(1),ind(2)),'backgroundcolor',[0.5 0.5 0.5]);
    else
        set(p(ind(1),ind(2)),'backgroundcolor','w');
    end
    set(h,'userdata',ind);
end

%����
function anbujin(h,e,p)
    global hang lie;
    %Se״̬����
    Se=zeros(hang,lie);
    for i=1:hang
        for j=1:lie
            ind=get(p(i,j),'userdata');
            Se(i,j)=ind(3);
        end
    end
    %Sd�߽����Ҳ�ǲ�������
    Sd=zeros(hang+2,lie+2);%����ϴεĲ���
    Sd(2:hang+1,2:lie+1)=Se;
    %�����ھ�ֵ
    sumValue = Sd(1:hang,1:lie)+Sd(1:hang,2:lie+1)+Sd(1:hang,3:lie+2)+Sd(2:hang+1,1:lie)+Sd(2:hang+1,3:lie+2)+Sd(3:hang+2,1:lie)+Sd(3:hang+2,2:lie+1)+Sd(3:hang+2,3:lie+2);%�����sumvalue�Ǿ����Ӧ���
   %һ���Ը���״̬
    for i=1:hang
        for j=1:lie
            if(sumValue(i,j)==3||(sumValue(i,j)==2&&Se(i,j)==1))
                Se(i,j) = 1;
            else
                Se(i,j) = 0;
            end
        end
    end
    %��״̬���ظ�����ϸ�������İ�ť״̬�����ı䰴ť��״̬�洢����
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

%ѭ��
function anxunhuan(h,e,p)
    global hang lie twospeed;
    %��һ�ο�ʼ���ٰ�һ��ֹͣ
    global doing;
    doing=get(h,'userdata');
    if doing==0
        doing=1;
    else
        doing=0;
    end
    set(h,'userdata',doing);
    %����doing����ֹͣ������ѭ��
    Se=zeros(hang,lie);
    while(doing)
        %Se״̬����
        for i=1:hang
            for j=1:lie
                ind=get(p(i,j),'userdata');
                Se(i,j)=ind(3);
            end
        end
        %Sd�߽����Ҳ�ǲ�������
        Sd=zeros(hang+2,lie+2);%����ϴεĲ���
        Sd(2:hang+1,2:lie+1)=Se;
        %�����ھ�ֵ
        sumValue = Sd(1:hang,1:lie)+Sd(1:hang,2:lie+1)+Sd(1:hang,3:lie+2)+Sd(2:hang+1,1:lie)+Sd(2:hang+1,3:lie+2)+Sd(3:hang+2,1:lie)+Sd(3:hang+2,2:lie+1)+Sd(3:hang+2,3:lie+2);%�����sumvalue�Ǿ����Ӧ���
       %һ���Ը���״̬
        for i=1:hang
            for j=1:lie
                if(sumValue(i,j)==3||(sumValue(i,j)==2&&Se(i,j)==1))
                    Se(i,j) = 1;
                else
                    Se(i,j) = 0;
                end
            end
        end
        %��״̬���ظ�����ϸ�������İ�ť״̬�����ı䰴ť��״̬�洢����
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

%�ݻ��ٶ�
function editsudu(h,e,p)
    global twospeed;
    str=get(h,'string');
    twospeed=str2double(str);
end

%�������
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

%�����ܶ�
function editbornrho(h,e,p)
    global rho;
    str=get(h,'string');
    rho=str2double(str);
end

%���
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

%��ʾ�����ھ�ֵ
function anside(h,e,p)
    global hang lie;
    %Se״̬����
    Se=zeros(hang,lie);
    for i=1:hang
        for j=1:lie
            ind=get(p(i,j),'userdata');
            Se(i,j)=ind(3);
        end
    end
    %Sd�߽����Ҳ�ǲ�������
    Sd=zeros(hang+2,lie+2);%����ϴεĲ���
    Sd(2:hang+1,2:lie+1)=Se;
    %�����ھ�ֵ
    sumValue = Sd(1:hang,1:lie)+Sd(1:hang,2:lie+1)+Sd(1:hang,3:lie+2)+Sd(2:hang+1,1:lie)+Sd(2:hang+1,3:lie+2)+Sd(3:hang+2,1:lie)+Sd(3:hang+2,2:lie+1)+Sd(3:hang+2,3:lie+2);%�����sumvalue�Ǿ����Ӧ���
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

%�����ھ�ֵ
function anemptyside(h,e,p)
    global hang lie;
    for i=1:hang
        for j=1:lie
            set(p(i,j),'string','');
        end
    end
end

%����
function ancache(h,e,p,cache)
    global hang lie;
    %Se״̬����
    Se=zeros(hang,lie);
    for i=1:hang
        for j=1:lie
            ind=get(p(i,j),'userdata');
            Se(i,j)=ind(3);
        end
    end
    set(cache,'userdata',Se);
end

%��������
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









