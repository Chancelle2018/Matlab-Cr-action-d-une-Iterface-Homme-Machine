function [x,y,yb,bruit]=simulation(N,a,b,sigma,aff,rec) 
% ***********************************************************************************
% ** La fonction simulation permet de simuler la sortie d'un système linéaire bruité
% ** INPUT N: nombre de points de mesures 
% ** INPUT a: coefficient directeur de la droite linéaire 
% ** INPUT b: ordonnée à l'origine de la droite linéaire
% ** INPUT sigma: écart type de la gaussienne et coefficient du bruit
% ** INPUT aff: affiche ou non les graphes
% ** INPUT rec: enregistre les valeurs de N, a, b et sigma dans un workspace
% ** OUTPUT x: vecteur contenant les points de l'axe des abscisses 
% ** OUTPUT y: vecteur contenant les valeurs de la fonction linéaire
% ** OUTPUT yb: vecteur contenant les valeurs de la fonctions linéaire bruitée
% ** OUTPUT bruit: vecteur représentant le bruit aléatoire
% ***********************************************************************************
% ** exemple :
% **      [x,y,yb,bruit]=simulation(200,22,4,2,0,1);
% ***********************************************************************************


x=[0:1:ceil(N)-1];
y=a*x+b;
bruit= sigma*randn(1,ceil(N));
yb = y+bruit;

if aff %si aff=1 les figures s'affichent, sinon renvoie juste les valeurs de retour
    
%Affichage des graphes
axes(handles.axes1)
plot(x,y,'r-')
xlim('auto')
class=20;
title(['Fonction affine avec ',int2str(N),' points'])
xlabel('Axe temporel')
ylabel(['y =',num2str(a),'x+',num2str(b)])

axes(handles.axes2)
%histfit(bruit,class)       
hist(bruit,class)
xlim('auto')
title(['Répartition Gaussienne du bruit avec σ = ',num2str(sigma),' et ',int2str(N),' points'])
xlabel(['Découpage avec ', int2str(class),' classes'])
ylabel(['Quantité de bruit'])

axes(handles.axes3)
plot(x,bruit,'.c-')
xlim('auto')
title(['Visualisation du bruit']);
xlabel(['Axe temporel']);
ylabel(['Signal aléatoire du bruit']);

axes(handles.axes4)
plot(x,y,'r-')
xlim('auto')
hold on
plot(x,yb,'+gr')
title(['Sortie du système linéaire bruité']);
xlabel(['Axe temporel']);
ylabel(['Signal linéaire bruité']);
end 

if rec 
    save resultats.mat x y yb bruit 
end


end