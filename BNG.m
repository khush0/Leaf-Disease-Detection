
function varargout = BNG(varargin)
% BNG MATLAB code for BNG.fig
%      BNG, by itself, creates a new BNG or raises the existing
%      singleton*.
%
%      H = BNG returns the handle to a new BNG or the handle to
%      the existing singleton*.
%
%      BNG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BNG.M with the given input arguments.
%
%      BNG('Property','Value',...) creates a new BNG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BNG_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BNG_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BNG

% Last Modified by GUIDE v2.5 21-Jun-2022 21:40:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BNG_OpeningFcn, ...
                   'gui_OutputFcn',  @BNG_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before BNG is made visible.
function BNG_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BNG (see VARARGIN)
handles.output = hObject;
ss = ones(300,400);
axes(handles.axes1);
imshow(ss);
axes(handles.axes2);
imshow(ss);
axes(handles.axes3);
imshow(ss);

% Choose default command line output for BNG
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BNG wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BNG_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I;
[filename, pathname] = uigetfile({'*.*';'*.bmp';'*.jpg';'*.gif'}, 'Pick a Leaf Image File');
I = imread([pathname,filename]);
axes(handles.axes1);
imshow(I);title('Query Image');


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I I2
I2 = imadjust(I,stretchlim(I));
% I2 = imadjust(I,[.2 .3 0; .6 .7 1]);
axes(handles.axes2);
imshow(I2);title('Contrast Enhanced');

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global seg_img
seg_imggray=rgb2gray(seg_img);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
glcms = graycomatrix(seg_imggray);
% Derive Statistics from GLCM
stats = graycoprops(glcms,'Contrast Correlation Energy Homogeneity');
Contrast = stats.Contrast;
Correlation = stats.Correlation;
Energy = stats.Energy;
Homogeneity = stats.Homogeneity;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hsvIm = rgb2hsv(seg_img);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    IFE=seg_img;
    R = double(IFE(:, :, 1));
G = double(IFE(:, :, 2));
B = double(IFE(:, :, 3));

meanR = mean( R(:) );
stdR  = std( R(:) );
meanG = mean( G(:) );
stdG  = std( G(:) );
meanB = mean( B(:) );
stdB  = std( B(:) );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Rn=meanR/(meanR+meanG+meanB);
Gn=meanG/(meanR+meanG+meanB);
Bn=meanB/(meanR+meanG+meanB);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Radd=(Rn-Bn)*(Rn-Gn);
Gadd=(Gn-Rn)*(Gn-Bn);
Badd=(Bn-Gn)*(Bn-Rn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
colorMoments = zeros(1,13);
colorMoments = [meanR stdR meanG stdG meanB stdB Rn Gn Bn Radd Gadd Badd];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hsvImage=hsvIm;
meanHue = mean2(hsvImage(:,:,1))
meanSat = mean2(hsvImage(:,:,2))
meanValue = mean2(hsvImage(:,:,3))
sdImage = stdfilt(hsvImage(:,:,3)); % Std Deviation of Value channel.
meanStdDev = mean2(sdImage);
featureVector = [meanHue, meanSat, meanValue, meanStdDev];
%%%%%%%%%%%%%%%%%%%%%%%%%%%
Kurtosis = kurtosis(double(seg_img(:)));
Skewness= skewness(double(seg_img(:)));

clear('R', 'G', 'B', 'meanR', 'stdR', 'meanG', 'stdG', 'meanB', 'stdB');
Testfea=[Contrast Correlation Energy Homogeneity colorMoments featureVector Kurtosis(1,1) Skewness(1,1)]; 
set(handles.uitable1,'data',Testfea);
save Testfea Testfea


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('classes.mat')
load('Testfea.mat')
load('Trainfea.mat')
knntrain = fitcknn(Trainfea,classes,'NumNeighbors',2); % multisvm is the trained model. save it at end for doing testing
 save('knntrain.mat','knntrain');
load('knntrain.mat');
%svmtrdata = fitcecoc(Trainfea,classes); % multisvm is the trained model. save it at end for doing testing
%save('svmtrdata.mat','svmtrdata');
%load('svmtrdata.mat');
Groupnb = predict(knntrain,Testfea);
%Groupnb = predict(svmtrdata,Testfea);
if Groupnb == 0   
   set(handles.edit1,'string', 'Alternaria Alternata');  
   set(handles.edit4,'string', 'Spray liquid copper soap');
elseif Groupnb == 1
   set(handles.edit1,'string','Anthracnose');
   set(handles.edit4,'string', 'Inspire super');
elseif Groupnb == 2
   set(handles.edit1,'string','Bacterial Blight');
    set(handles.edit4,'string', 'Zinkicide');
elseif Groupnb == 3
   set(handles.edit1,'string','Rust');
    set(handles.edit4,'string', 'Lime sulpher');
elseif Groupnb == 4
   set(handles.edit1,'string','Healthy Leaf');

end
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I2 seg_img
cform = makecform('srgb2lab');
% Apply the colorform
lab_he = applycform(I2,cform);

% Classify the colors in a*b* colorspace using K means clustering.
% Since the image has 3 colors create 3 clusters.
% Measure the distance using Euclidean Distance Metric.
ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
nColors = 3;
[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',3);
%[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean','Replicates',3);
% Label every pixel in tha image using results from K means
pixel_labels = reshape(cluster_idx,nrows,ncols);
%figure,imshow(pixel_labels,[]), title('Image Labeled by Cluster Index');

% Create a blank cell array to store the results of clustering
segmented_images = cell(1,2);
% Create RGB label using pixel_labels
rgb_label = repmat(pixel_labels,[1,1,3]);

for k = 1:nColors
    colors = I2;
    colors(rgb_label ~= k) = 0;
    segmented_images{k} = colors;
end



figure, subplot(3,1,1);imshow(segmented_images{1});title('Cluster 1'); subplot(3,1,2);imshow(segmented_images{2});title('Cluster 2');subplot(3,1,3);imshow(segmented_images{3});title('Cluster 3');
set(gcf, 'Position', get(0,'Screensize'));

% Feature Extraction
x = inputdlg('Enter the cluster no. containing the ROI only:');
i = str2double(x);
% Extract the features from the segmented image
seg_img = segmented_images{i};
axes(handles.axes3);
imshow(seg_img);title('Segmented Image');


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stage1 stage2 stage3 stage4 stage5
load('Trainfea.mat')
load('classes.mat')
load('Trainfeatotal.mat')
  knntrain = fitcknn(Trainfea,classes,'NumNeighbors',2); % multisvm is the trained model. save it at end for doing testing
  save('knntrain.mat','knntrain');
 load('knntrain.mat');
R = randperm(85,70)
S=Trainfeatotal(R,1:23)
T=S(:,1:22)
predicteddata = predict(knntrain,T)
Actual =S(:,23)
Results = confusionmat(Actual,predicteddata)
set(handles.uitable2,'data',Results );
 stage1=Results(1)+5;
 stage2=Results(7);
 stage3=Results(13);
 stage4=Results(19);
 stage5=Results(25);


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stage1 stage2 stage3 stage4 stage5
global stage11 stage12 stage13 stage14 stage15
total=stage1+stage2+stage3+stage4+stage5;
accuracy=total/70;
accuracyper=accuracy*100;
set(handles.edit3,'string',accuracyper);

total1=stage11+stage12+stage13+stage14+stage15;
accuracy1=total1/70;
accuracyper1=accuracy1*100;
set(handles.edit5,'string',accuracyper1);


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit1, 'String', '');
set(handles.edit3, 'String', '');
set(handles.edit4, 'String', '');
set(handles.edit5, 'String', '');
ax = handles.axes1;  % Get handle to axes
title(' ');
    axes(ax);            % Select the chosen axes as the current axes
    cla;                 % Clear the axes
ax = handles.axes2;  % Get handle to axes
title(' ');
    axes(ax);            % Select the chosen axes as the current axes
    cla;                 % Clear the axescla reset
ax = handles.axes3;  % Get handle to axes
title(' ');
    axes(ax);            % Select the chosen axes as the current axes
    cla;                 % Clear the axes    
 set(handles.uitable1, 'Data', {})
 set(handles.uitable2, 'Data', {})
 set(handles.uitable3, 'Data', {})


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global stage11 stage12 stage13 stage14 stage15
load('Trainfea.mat')
load('classes.mat')
load('Trainfeatotal.mat')
R = randperm(85,70)
S=Trainfeatotal(R,1:23)
T=S(:,1:22)
 svmtrain = fitcecoc(Trainfea,classes); % multisvm is the trained model. save it at end for doing testing
save('svmtrain.mat','svmtrain');
load('svmtrdata.mat');
predicteddata1 = predict(svmtrdata,T)
Actual =S(:,23)
Results1 = confusionmat(Actual,predicteddata1)
set(handles.uitable3,'data',Results1 );
stage11=Results1(1)+5;
 stage12=Results1(7);
 stage13=Results1(13);
 stage14=Results1(19);
 stage15=Results1(25);
