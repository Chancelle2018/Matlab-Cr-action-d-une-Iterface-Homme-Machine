function varargout = interface(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @interface_OpeningFcn, ...
                   'gui_OutputFcn',  @interface_OutputFcn, ...
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
end
% End initialization code - DO NOT EDIT


% --- Executes just before interface is made visible.
function interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to interface (see VARARGIN)

% Choose default command line output for interface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes interface wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% On déclare les variables globales
global a; 
global b;
global N;
global Sigma;
global class;
global bruit;
class=20;

%On initialise les valeurs par défaut
init;
load('init.mat');

%On appelle la fonction simulation et on récupère les valeurs x,y,yb et bruit
%Si AFF=1, on affiche les graphes dans une figure, si AFF=0, on n'affiche rien
[x,y,yb,bruit]=simulation(N,a,b,Sigma,0,1);

%On enregistre les nouvelles valeurs dans init.mat
save init.mat a b Sigma N;

%On appelle la fonction extraction avec les valeurs de retour de la fonction simulation
[b0,b1,sigma_est,s0,s1,R_2]= extraction(x,y,yb,bruit,0) ;

%On affiche les graphes dans notre interface

%1er graphe: Fonction affine sur N points
axes(handles.axes1);
plot(x,y,'r-');
xlim([0,N])%on ajuste l'axe des abscisses au nombre de points
title(['Fonction affine avec ',int2str(ceil(N)),' points']);
xlabel('Axe temporel');
ylabel(['y =',num2str(a),'x+',num2str(b)]);

%2ème graphe: Fonction gaussienne du bruit (Histogramme)
axes(handles.axes2);
%histfit(bruit,class) ;      
hist(bruit,class);
xlim('auto');
title(['Répartition Gaussienne du bruit avec σ = ',num2str(Sigma),' et ',int2str(ceil(N)),' points']);
xlabel(['Découpage avec ', int2str(class),' classes']);
ylabel(['Quantité de bruit']);

%3ème graphe: Visualisation du bruit
axes(handles.axes3);
plot(x,bruit,'.c-');
xlim([0,N]);
title(['Visualisation du bruit']);
xlabel(['Axe temporel']);
ylabel(['Signal aléatoire du bruit']);

%4ème graphe: Sortie du système linéaire bruité
axes(handles.axes4);
plot(x,y,'r-');
hold on;
plot(x,yb,'.gr');
hold off ;
xlim([0,N]);
title(['Sortie du système linéaire bruité']);
xlabel(['Axe temporel']);
ylabel(['Signal linéaire bruité']);

%On estime les erreurs relatives de a, b et sigma
err_a= 100.*abs((a-b1)/a);
err_b= 100.*abs((b-b0)/b);
err_sigma= 100.*abs((Sigma-sigma_est)/Sigma);

%On entre les valeurs des variables théoriques et estimées dans le tableau final
data = { a, b1, err_a; b, b0, err_b; Sigma, sigma_est, err_sigma};
set(handles.uitable1, 'Data', data);

end

% --- Outputs from this function are returned to the command line.
function varargout = interface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on slider movement.
function slidera_Callback(hObject, eventdata, handles)
% hObject    handle to slidera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%On récupère les valeurs des autres variables globales
global b; 
global N;
global Sigma; 
global class;
class=20;
global bruit;
load('init.mat');

%On récupère la valeur du slidera et on l'affecte à la valeur globale a
global a;
a=get(hObject,'Value');

%On affiche la valeur de a dans l'interface
set(handles.texta,'string',['Valeur de a = ',num2str(a)]);

%On appelle la fonction simulation
[x,y,yb,bruit]=simulation(N,a,b,Sigma,0,1);

%On enregistre ces valeurs dans init.mat
save init.mat a b Sigma N;

%On affiche les graphes dans notre interface à partir des valeurs retournées par la fonction simulation

%1er graphe: Fonction affine sur N points
axes(handles.axes1);
plot(x,y,'r-');
xlim([0,N])
title(['Fonction affine avec ',int2str(ceil(N)),' points']);
xlabel('Axe temporel');
if(b>=0)
ylabel(['y =',num2str(a),'x+',num2str(b)]);
else
ylabel(['y =',num2str(a),'x',num2str(b)]);
end

%2ème graphe: Fonction gaussienne du bruit (Histogramme)
axes(handles.axes2);
%histfit(bruit,class)       
hist(bruit,class);
xlim('auto')
title(['Répartition Gaussienne du bruit avec σ = ',num2str(Sigma),' et ',int2str(ceil(N)),' points']);
xlabel(['Découpage avec ', int2str(class),' classes']);
ylabel(['Quantité de bruit']);

%3ème graphe: Visualisation du bruit
axes(handles.axes3);
plot(x,bruit,'.c-');
xlim([0,N])
title(['Visualisation du bruit']);
xlabel(['Axe temporel']);
ylabel(['Signal aléatoire du bruit']);

%4ème graphe: Sortie du système linéaire bruité
axes(handles.axes4);
plot(x,y,'r-');
hold on;
plot(x,yb,'.gr');
hold off ;
xlim([0,N]);
title(['Sortie du système linéaire bruité']);
xlabel(['Axe temporel']);
ylabel(['Signal linéaire bruité']);

%On appelle maintenant la fonction extraction
[b0,b1,sigma_est,s0,s1,R_2]= extraction(x,y,yb,bruit,0); 

%On estime les erreurs relatives de sigma
err_a= 100.*abs((a-b1)/a);
err_b= 100.*abs((b-b0)/b);
err_sigma= 100.*abs((Sigma-sigma_est)/Sigma);

%On entre les valeurs des variables théoriques et estimées dans le tableau final
data = { a, b1, err_a; b, b0, err_b; Sigma, sigma_est, err_sigma};
set(handles.uitable1, 'Data', data);
end


% --- Executes during object creation, after setting all properties.
function slidera_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slidera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes on slider movement.
function sliderb_Callback(hObject, ~, handles)
% hObject    handle to sliderb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%On récupère les valeurs des autres variables globales
global a;
global N;
global Sigma; 
global class;
global bruit;
class=20;
load('init.mat')

%On récupère la valeur du sliderb et on l'affecte à la valeur globale b
global b;
b=get(hObject,'Value');

%On affiche la valeur de b dans l'interface
set(handles.textb,'string',['Valeur de b = ',num2str(b,3)]);

%On appelle la fonction simulation
[x,y,yb,bruit]=simulation(N,a,b,Sigma,0,1);

%On enregistre les nouvelles valeurs
save init.mat a b Sigma N;

%On affiche les graphes dans notre interface à partir des valeurs retournées par la fonction simulation

%1er graphe: Fonction affine sur N points
axes(handles.axes1);
plot(x,y,'r-');
xlim([0,N])
title(['Fonction affine avec ',int2str(ceil(N)),' points']);
xlabel('Axe temporel');
if(b>=0)
ylabel(['y =',num2str(a),'x+',num2str(b)]);
else
ylabel(['y =',num2str(a),'x',num2str(b)]);
end

%2ème graphe: Fonction gaussienne du bruit (Histogramme)
axes(handles.axes2);
%histfit(bruit,class)       
hist(bruit,class);
xlim('auto')
title(['Répartition Gaussienne du bruit avec σ = ',num2str(Sigma),' et ',int2str(ceil(N)),' points']);
xlabel(['Découpage avec ', int2str(class),' classes']);
ylabel(['Quantité de bruit']);

%3ème graphe: Visualisation du bruit
axes(handles.axes3);
plot(x,bruit,'.c-');
xlim([0,N])
title(['Visualisation du bruit']);
xlabel(['Axe temporel']);
ylabel(['Signal aléatoire du bruit']);

%4ème graphe: Sortie du système linéaire bruité
axes(handles.axes4);
plot(x,y,'r-');
xlim('auto');
hold on;
plot(x,yb,'.gr');
hold off ;
xlim([0,N]);
title(['Sortie du système linéaire bruité']);
xlabel(['Axe temporel']);
ylabel(['Signal linéaire bruité']);

%On appelle maintenant la fonction extraction
[b0,b1,sigma_est,s0,s1,R_2]= extraction(x,y,yb,bruit,0) 

%On estime les erreurs relatives de a, b et sigma
err_a= 100.*abs((a-b1)/a);
err_b= 100.*abs((b-b0)/b);
err_sigma= 100.*abs((Sigma-sigma_est)/Sigma);

%On entre les valeurs des variables théoriques et estimées dans le tableau final
data = { a, b1, err_a; b, b0, err_b; Sigma, sigma_est, err_sigma};
set(handles.uitable1, 'Data', data);

end

% --- Executes during object creation, after setting all properties.
function sliderb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes on slider movement.
function sliderN_Callback(hObject, eventdata, handles)
% hObject    handle to sliderN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%On récupère les valeurs des autres variables globales
global a ;
global b;
global Sigma ;
global class;
global bruit;
class=20;
load('init.mat')

%On récupère la nouvelle valeur du slider N et on l'affecte à la valeur globale Sigma 
global N;
N=get(hObject,'Value');

%On affiche la valeur de N dans l'interface
set(handles.textN,'string',['Valeur de N = ',int2str(ceil(N))]);

%On enregistre les nouvelles valeurs
save init.mat a b Sigma N;

%On appelle la fonction simulation
[x,y,yb,bruit]=simulation(N,a,b,Sigma,0,1);

%On affiche les graphes dans notre interface à partir des valeurs retournées par la fonction simulation

%1er graphe: Fonction affine sur N points
axes(handles.axes1);
plot(x,y,'r-');
xlim([0,N])
title(['Fonction affine avec ',int2str(ceil(N)),' points']);
xlabel('Axe temporel');
if(b>=0)
ylabel(['y =',num2str(a),'x+',num2str(b)]);
else
ylabel(['y =',num2str(a),'x',num2str(b)]);
end

%2ème graphe: Fonction gaussienne du bruit (Histogramme)
axes(handles.axes2);
%histfit(bruit,class)       
hist(bruit,class);
xlim('auto') 
title(['Répartition Gaussienne du bruit avec σ = ',num2str(Sigma),' et ',int2str(ceil(N)),' points']);
xlabel(['Découpage avec ', int2str(class),' classes']);
ylabel(['Quantité de bruit']);

%3ème graphe: Visualisation du bruit
axes(handles.axes3);
plot(x,bruit,'.c-');
xlim([0,N])
title(['Visualisation du bruit']);
xlabel(['Axe temporel']);
ylabel(['Signal aléatoire du bruit']);

%4ème graphe: Sortie du système linéaire bruité
axes(handles.axes4);
plot(x,y,'r-');
hold on;
plot(x,yb,'.gr');
hold off ;
xlim([0,N]);
title(['Sortie du système linéaire bruité']);
xlabel(['Axe temporel']);
ylabel(['Signal linéaire bruité']);

%On appelle maintenant la fonction extraction
[b0,b1,sigma_est,s0,s1,R_2]= extraction(x,y,yb,bruit,0) ;

%On estime les erreurs relatives de a, b et sigma
err_a= 100.*abs((a-b1)/a);
err_b= 100.*abs((b-b0)/b);
err_sigma= 100.*abs((Sigma-sigma_est)/Sigma);

%On entre les valeurs des variables théoriques et estimées dans le tableau final
data = { a, b1, err_a; b, b0, err_b; Sigma, sigma_est, err_sigma};
set(handles.uitable1, 'Data', data);

end

% --- Executes during object creation, after setting all properties.
function sliderN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes on slider movement.
function sliderSigma_Callback(hObject, eventdata, handles)
% hObject    handle to sliderSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%On récupère les valeurs des autres variables globales
global a; 
global b;
global N;
global class;
global bruit;
class=20;
load('init.mat')

%On récupère la nouvelle valeur du sliderSigma et on l'affecte à la valeur globale Sigma 
global Sigma;
Sigma=get(hObject,'Value');

%On affiche la valeur de Sigma dans l'interface
set(handles.textSigma,'string',['Valeur de σ = ',num2str(Sigma)]);

%On enregistre les nouvelles valeurs
save init.mat a b Sigma N;

%On appelle la fonction simulation
[x,y,yb,bruit]=simulation(N,a,b,Sigma,0,1);


%On affiche les graphes dans notre interface à partir des valeurs retournées par la fonction simulation

%1er graphe: Fonction affine sur N points
axes(handles.axes1);
plot(x,y,'r-');
xlim([0,N])
title(['Fonction affine avec ',int2str(ceil(N)),' points']);
xlabel('Axe temporel');
if(b>=0)
ylabel(['y =',num2str(a),'x+',num2str(b)]);
else
ylabel(['y =',num2str(a),'x',num2str(b)]);
end

%2ème graphe: Fonction gaussienne du bruit (Histogramme)
axes(handles.axes2);
%histfit(bruit,class)       
hist(bruit,class);
xlim('auto')
title(['Répartition Gaussienne du bruit avec σ = ',num2str(Sigma),' et ',int2str(ceil(N)),' points']);
xlabel(['Découpage avec ', int2str(class),' classes']);
ylabel(['Quantité de bruit']);

%3ème graphe: Visualisation du bruit
axes(handles.axes3);
plot(x,bruit,'.c-');
xlim([0,N])
title(['Visualisation du bruit']);
xlabel(['Axe temporel']);
ylabel(['Signal aléatoire du bruit']);

%4ème graphe: Sortie du système linéaire bruité
axes(handles.axes4);
plot(x,y,'r-')
xlim([0,N])
hold on
plot(x,yb,'.gr');
hold off 
title(['Sortie du système linéaire bruité']);
xlabel(['Axe temporel']);
ylabel(['Signal linéaire bruité']);

%On appelle maintenant la fonction extraction
[b0,b1,sigma_est,s0,s1,R_2]= extraction(x,y,yb,bruit,0) ;

%On estime les erreurs relatives de a, b et sigma
err_a= 100.*abs((a-b1)/a);
err_b= 100.*abs((b-b0)/b);
err_sigma= 100.*abs((Sigma-sigma_est)/Sigma);

%On entre les valeurs des variables théoriques et estimées dans le tableau final
data = { a, b1, err_a; b, b0, err_b; Sigma, sigma_est, err_sigma};
set(handles.uitable1, 'Data', data);

end

% --- Executes during object creation, after setting all properties.
function sliderSigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton1

%On récupère les variables globales
global a;
global b ;
global N;
global Sigma ;
global bruit;
global class;
class=20; 
load('init.mat')
load('resultats.mat')

%On affiche dans une nouvelle figure les graphes
figure()

subplot(3,2,1)
plot(x,y,'r-')
xlim([0,N])
title(['Fonction affine avec ',int2str(ceil(N)),' points'])
xlabel('Axe temporel')
ylabel(['y =',num2str(a),'x+',num2str(b)])

subplot(3,2,2)       
hist(bruit,class)
xlim('auto')
title(['Répartition Gaussienne du bruit avec σ = ',num2str(Sigma),' et ',int2str(ceil(N)),' points'])
xlabel(['Découpage avec ', int2str(class),' classes'])
ylabel(['Quantité de bruit'])

subplot(3,2,3)
plot(x,bruit,'.c-')
xlim([0,N])
title(['Visualisation du bruit']);
xlabel(['Axe temporel']);
ylabel(['Signal aléatoire du bruit']);

subplot(3,2,4)
xlim([0,N])
plot(x,y,'r-')
hold on
plot(x,yb,'.gr')
hold off
title(['Sortie du système linéaire bruité']);
xlabel(['Axe temporel']);
ylabel(['Signal linéaire bruité']);

end

function min_Callback(hObject, eventdata, handles)
% hObject    handle to min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min as text
%        str2double(get(hObject,'String')) returns contents of min as a double

%On récupère la valeur min saisie par l'utilisateur
min=str2double(get(hObject,'String'));

%On récupère la valeur actuelle de N
valueN=get(handles.sliderN, 'Value');

%Si la valeur actuelle est plus petite que min, la valeur actuelle prend la valeur de min
if(min>=valueN)
set(handles.sliderN, 'Value', min);   
%On modifie l'affichage de la valeur de N dans l'interface
set(handles.textN,'string',['Valeur de N = ',int2str(ceil(min))]);
set(handles.sliderN, 'Min', min);
end

set(handles.sliderN, 'Min', min);

end

% --- Executes during object creation, after setting all properties.
function min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function max_Callback(hObject, eventdata, handles)
% hObject    handle to max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max as text
%        str2double(get(hObject,'String')) returns contents of max as a double

%On récupère la valeur max saisie par l'utilisateur
max=str2double(get(hObject,'String'));

%On récupère la valeur actuelle de N
valueN=get(handles.sliderN, 'Value');

%Si la valeur actuelle est plus grande que max, la valeur actuelle prend la valeur de max
if(max<=valueN)
set(handles.sliderN, 'Value', max); 
%On modifie l'affichage de la valeur de N dans l'interface
set(handles.textN,'string',['Valeur de N = ',int2str(ceil(max))]);
set(handles.sliderN, 'Max', max);
end

set(handles.sliderN, 'Max', max);

end

% --- Executes during object creation, after setting all properties.
function max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
