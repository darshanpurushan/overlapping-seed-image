clc
close all
clear all
%% Intialization
folder = 'D:\internship_1';
filePattern = fullfile(folder,'samara_15o' ,'*.tif');
files1 = dir(filePattern);
files = natsortfiles(files1);

ImageFolder ='D:\internship_1\samara_15o_bg';

n=numel(files);
Y = [];
X = [];
Yt = [];
Xt = [];
Area = [];
speed = [];
I_c = [];
rpm = [];
cone_l = [];
cone_r = [];
tempx = 0;
tempy = 0;
temptx = 0;
tempty = 0;


bg = rgb2gray(imread("D:\internship_1\samara_15o\1.tif"));

%% Background Subtraction   

for a = 1 : n
    baseFileName = files(a).name;
    fullFileName = fullfile(files(a).folder, baseFileName);
    I = rgb2gray(imread(fullFileName));   
    count = 0;
    [L,B]=size(bg);
    temp = uint8(zeros(L,B));
    for i=1:L
        for j=1:B
            if bg(i,j)-I(i,j)<=15                        
                temp(i,j)=255;                        
            else
                temp(i,j)= I(i,j);
                if count == 0
                    tempty = j;
                    temptx = i;
                end
                count = count+1;
                tempx = i;
                tempy = j;
            end
        end
    end
    file_name_1 = sprintf('%d.tif', a);
    fullFileName_1 = fullfile(ImageFolder, file_name_1);
    imwrite(im2bw(temp),fullFileName_1,'tif');
    Area(a) = count;
    Y(a) = tempx; %bottom y coordinate
    X(a) = tempy; %bottom x coordinate
    Yt(a) = temptx; %top y coordinate
    Xt(a) = tempty; %top x coordinate
end

%% Descent Velocity Calculation & Path Prediction
figure
plot(X,Y) %Path plot
title('Samara Path Tracking');


for i = 1 :(length(X) -1)
    speed(i) = (Y(i+1)-Y(i))*0.000857*1057;
end
fprintf('\n The average vertical desecent velocity is %f m/s\n',mean(speed))


%% Samara Areas 
for i = 1:length(Area)
    I_c(i) = i;
end
figure
plot(I_c,Area) %Path plot
title('Projected Area Variation');
xlabel("Image Number")
ylabel("Area in pixels")

%% RPM Calculations
f = 1;
av=mean(Area);
for i=30:(length(Area)-30)
    if (Area(i)<Area(i+1))&&(Area(i)<Area(i-1)&&(Area(i)<av))
        min_area(f)=i;
        f=f+1;
    end
end
for i=3:(length(min_area)-1)
    rps=(min_area(i)-min_area(i-2))/1057;
    rpm(i-2)=rps*60;
end
fprintf('\n The average RPM is %f',mean(rpm))

%% Coning angle
for c = 1 : length(min_area)
    num = min_area(c);
if Xt(num)>X(num)
    cone_r(c) = atand(-(Yt(num)-Y(num))/(Xt(num)-X(num)));
else 
    cone_l(c) = atand((Yt(num)-Y(num))/(Xt(num)-X(num)));
end
end
avg_cone = (mean(cone_r)+mean(cone_l))/2;
fprintf('\n The average coning angle is %f degrees', avg_cone);
