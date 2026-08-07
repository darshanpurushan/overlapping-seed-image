clc
close all
clear all
%% Intialization
folder = 'D:\internship_1';
filePattern = fullfile(folder,'samaras_1' ,'*.tif');
files1 = dir(filePattern);
files = natsortfiles(files1);

ImageFolder ='D:\internship_1\samara_bg_1';

n=numel(files);
Y = zeros();
X = zeros();
Area = zeros();
speed = zeros();
I_c = zeros();
min_area = zeros();
rpm = zeros();
coneod = zeros();
coneev = zeros();

f=0;

bg = rgb2gray(imread("D:\internship_1\samaras_1\1.tif"));

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
            if bg(i,j)-I(i,j)<=10                        
                temp(i,j)=255;                        
            else
                temp(i,j)= I(i,j);
                count = count+1;
            end
        end
    end
    file_name_1 = sprintf('%d.tif', a);
    fullFileName_1 = fullfile(ImageFolder, file_name_1);
    imwrite(im2bw(temp),fullFileName_1,'tif');
    Area(a) = count;
end

%% Descent Velocity Calculation & Path Prediction
filePattern2 = fullfile(ImageFolder, '*.tif');
files2 = dir(filePattern2);
files3 = natsortfiles(files2);

for b = 1 : length(files3)
    baseFileName1 = files3(b).name;
    fullFileName1 = fullfile(files(b).folder, baseFileName1);
    I1 = imread(fullFileName1);
    [a1,b1] = size(I1);
  flipud(I1);
    for x = 1:a1
        for y = 1:b1
            if I1(x,y) == 0
               Y(b) = x;
               X(b) = y;
            end
        end 
    end

end
plot(X,Y)
%% 
iter=1;
y1=[]
x1=[]
for i=1:length(X)
    if Y(i)~=0 & X(i)~=0
        y1(iter)=Y(i)
        x1(iter)=X(i)
        iter=iter+1
    end
end

figure
plot(x1,y1) %Path plot
title('Samara Path Tracking');


for i = 1 :((length(files3))/2)
    speed(i) = (y1(i+1)-y1(i))*0.00082*1057;
end
fprintf('The average vertical desecent velocity is %d',mean(speed))

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

av=mean(Area);
for i=3:(length(Area)-1)
    if (Area(i)<Area(i+1))&&(Area(i)<Area(i-1)&&(Area(i)<av))
        f=f+1;
        min_area(f)=i;
    else
        continue
    end
end

for i=2:length(min_area)
    rpf=1/(min_area(i)-min_area(i-1));
    rps=rpf*1057;
    rpm(i)=rps*30;
end
fprintf('The average RPM is %d',mean(rpm))

%% Coning angle
for c = 1 : length(min_area)
    num = min_area(c);
    baseFileName1 = files3(num).name;
    fullFileName1 = fullfile(files(num).folder, baseFileName1);
    I2 = imread(fullFileName1);
    [a1,b1] = size(I2);
  % Top Row
    for p = 1:a1
        for q = 1:b1
            if I2(p,q) == 0
               break
            else
               continue
            end
        end 
    end
  % Bottom Row
    flipud(I2);
    for r = 1:a1
        for s = 1:b1
            if I2(r,s) == 0
               break
            else
               continue
            end
        end 
    end
if mod(c,2) == 0
    coneev(c) = atand((q-s)/(p-r));
else 
    coneod(c) = atand((q-s)/(p-r));
end
end
fprintf('The average coning angle is %d and %d',mean(coneev),mean(coneod));
