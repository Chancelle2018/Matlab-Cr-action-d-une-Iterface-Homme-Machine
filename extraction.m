function [b0,b1,sigma_est,s0,s1,R_2]= extraction(x,y,yb,bruit,aff) 
% *************************************************************************************
% ** La fonction extraction permet d'estimer l'erreur de mesure
% ** INPUT x: vecteur contenant les points de l'axe des abscisses 
% ** INPUT y: vecteur contenant les valeurs de la fonction linéaire
% ** INPUT yb: vecteur contenant les valeurs de la fonctions linéaire bruitée
% ** INPUT bruit: vecteur représentant le bruit aléatoire
% ** INPUT aff: affiche ou non le graphe du bruit estimé
% ** OUTPUT b1: coefficient directeur estimée de la droite linéaire 
% ** OUTPUT b0:  ordonnée à l'origine estimée de la droite linéaire 
% ** OUTPUT sigma_est: écart type de la gaussienne et coefficient estimée du bruit
% ** OUTPUT s0: erreur estimée de b0
% ** OUTPUT s1: erreur estimée de b1
% ** OUTPUT R_2: coefficient de détermination
% *************************************************************************************
% ** exemple :
% **      x=[0:1:ceil(20)-1];
% **      y= 2* x + 55;
% **      bruit= 2* randn(1,ceil(20));
% **      yb= y+bruit;
% **      [b0,b1,sigma_est,s0,s1,R_2]=extraction(x,y,yb,bruit,0);
% *************************************************************************************

%Estimation des paramètres b0 et b1
N=length(x);
U=[ones(N,1) x'];
U_t=U';
A=U_t*U ; %matrice du système
C=U_t*yb';
B=inv(A)*C;
b0=B(1,1);
b1=B(2,1);
yreg=b0+b1*x; %Régression linaire estimée

%Calcul des erreurs commises dans l'estimation des paramètres b0 et b1
Sr=sum((yb-yreg).^2); %somme résiduelle
Vr=Sr/(N-2); %car on a deux paramètres avec une régression linéaire ax+b
V=Vr*inv(A);
s0=sqrt(V(1,1));
s1=sqrt(V(2,2));

%Estimation de l'erreur commise sur la mesure
sigma_est=sqrt(Vr); %ecart-type résiduel

%Calcul des coefficients de détermination R_2 et de corrélation R
%Si yreg représente correctement les valeurs expérimentales: R_2--> 1 et -1<R<1
y_barre=mean(yb);
Se=sum((yreg-y_barre).^2);%somme expliquée des carrées des écarts
St=Se+Sr; %somme totale des carrés des écarts
R_2=Se/St;
R=sqrt(R_2); 

%Affichage des graphes selon le paramètre aff
if aff
load('resultats.mat');
plot(x,yb,'+g');
title(['Résultat du signal bruité Vert']); %legendes
xlabel(['Axe temporel']);
ylabel(['Quantité de bruit']);
hold on;
plot(x,yreg,'-r');
title(['Régression linéaire estimée Rouge']); %legendes 
end

end




