clear all

%% Ucinne prurezy

Difuze  = [0.5 0.2];    
L       = [21  2.8];     
SigmaA  = Difuze ./ (L.^2);

%% Geometrie

a = 30;    % interval [0,a]

%% Okrajove podminky
%   J(0) = S/2
%   phi() = 0

d_ex = 2*Difuze(2);  % extrapolovana vzdalenost pro aproximaci vakuove O.P.
S = 1;  % externi zdroj na leve strane oblasti (zahrnuty jako Neumannova O.P.)

%% Diskretizace

N = 300; h = a/N;  % N podintervalu delky h

% Rozhranni mezi oblastmi s odlisnymi materialy (15cm)
if1 = N/2;

% Ucinne prurezy v jednotlivych oblastech
D = zeros(1, N);
Sa = zeros(1, N);
D(1:if1)    = Difuze(1);    D(if1+1:N)  = Difuze(2);
Sa(1:if1)   = SigmaA(1);    Sa(if1+1:N) = SigmaA(2);

i = 2:(N-1);

% a_{i,i-1}
aim1 = 2*D(i).*D(i-1)./( (D(i)+D(i-1))*h );
% a_{i,i+1}
aip1 = 2*D(i).*D(i+1)./( (D(i)+D(i+1))*h );

ae(1) = -aim1(1);
ae(i) = -aip1;
aw(i-1) = -aim1;
aw(N-1) = -aip1(end);
ac(1) = -ae(1) + h*Sa(1);
ac(i) = aim1 + aip1 + h*Sa(i);
ac(N) = -aw(N-1) + D(N)/(h/2+d_ex) + h*Sa(N);

A = gallery('tridiag', aw, ac, ae); % matice difuze a absorpce
figure;
spy(A)

% Prava strana (zahrnuje externi zdroj nalevo a, zde nulovou, Dirichletovu
% podminku napravo)
g = 0;
rhs = [S/2; zeros(N-2, 1); g*D(N)/(h/2+d_ex)]; 

%% Reseni soustavy

phi = A\rhs;
plot(phi); 

%% Porovnani se semi-analytickym resenim z Mathematicy

load('Tok.mat');
load('x.mat');
load('phi0.mat');

% Hodnoty ve vektoru phi odpovidaji hodnotam reseni ve stredu intervalu
x = linspace(0.5*h,a-0.5*h,N);
fi=interp1(x,phi,Expression1,'spline');

figure; 
plot(Expression1,Expression2, 'r'); hold on; plot(Expression1,fi,'b')
axis square

fprintf('Relativni chyba v pocatku: %g\n', ...
    (Expression3 - fi(1)) / Expression3)