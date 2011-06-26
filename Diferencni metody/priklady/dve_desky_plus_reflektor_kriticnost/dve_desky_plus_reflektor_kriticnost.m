clear all

%% Ucinne prurezy

Difuze =    [0.65   0.75    1.15];
SigmaA =    [0.12   0.1     0.01];
nSigmaF =   [0.185  0.15    0.0];

%% Geometrie

a = 125;    % interval [0,a]

%% Okrajove podminky
%   J(0) + gammaW*phi(0) = 0
%   J(a) + gammaE*phi(a) = 0

gammaW = 0;     % symetrie
gammaE = 0.5;   % vakuum

%% Diskretizace

N = 3000; h = a/N;  % N podintervalu delky h

% Rozhranni mezi oblastmi s odlisnymi materialy (50cm, 100cm)
if1 = 2*N/5;
if2 = 4*N/5;

% Ucinne prurezy v jednotlivych oblastech
D = zeros(1, N);  
Sa = zeros(1, N); 
nSf = zeros(1, N);
D(1:if1)    = Difuze(1);  D(if1+1:if2)  = Difuze(2);  D(if2+1:N)   = Difuze(3);
Sa(1:if1)   = SigmaA(1);  Sa(if1+1:if2) = SigmaA(2);  Sa(if2+1:N)  = SigmaA(3);
nSf(1:if1)  = nSigmaF(1); nSf(if1+1:if2)= nSigmaF(2); nSf(if2+1:N) = nSigmaF(3);
nu = 2.43;
Sf = nSf/nu;

%% Sestaveni soustavy algebraickych rovnic

i = 2:(N-1);

% a_{i,i-1}
aim1 = 2*D(i).*D(i-1)./( (D(i)+D(i-1))*h );
% a_{i,i+1}
aip1 = 2*D(i).*D(i+1)./( (D(i)+D(i+1))*h );

ae(1) = -aim1(1);
ae(i) = -aip1;
aw(i-1) = -aim1;
aw(N-1) = -aip1(end);
ac(1) = -ae(1) - gammaW + h*Sa(1);
ac(i) = aim1 + aip1 + h*Sa(i);
ac(N) = -aw(N-1) + gammaE + h*Sa(N);

A = gallery('tridiag', aw, ac, ae); % matice difuze a absorpce
figure;
spy(A)

F = h*diag(nSf(1:N));   % matice stepnych zdroju

%% Uloha na vl. cisla

% Pocatecni odhady
keff = 1;
phi = 1e9 * ones(N,1);

% Promenne pro uchovani hodnot z predchozi iterace
ophi = zeros(N,1);
okeff = 0;

% Pri vypoctu vl. cisla se matice nemeni (jen prava strana) - LU faktorizaci 
% provedeme jen jednou
[L,U] = lu(A);

% Opakuj, dokud se fundamentalni neutronovy tok neustali (keff obvykle
% konverguje o nekolik radu rychleji)
it = 0;
while norm(ophi-phi)/norm(ophi) > 1e-6
    it = it+1;
    % Predchozi hodnoty
    okeff = keff;
    ophi = phi;
    % Nova hodnota phi
    y = L\(1/keff * F * phi);
    phi = U\y;
    plot(phi); 
    axis square
    drawnow;
    % Nova hodnota keff
    keff = keff * norm(nSf*phi,Inf)/norm(nSf*ophi,Inf);
    fprintf('keff(%d) = %1.6f\n', it, keff)
end

%% Normalizace na zadany vykon

Ptarget = 320; % 100We pri 32% ucinnosti = 320Wt

% Energie na jedno stepeni ([J])
Efis = 3.204E-11;
% Pocet stepeni v celem reaktoru za sekundu, v ustalenem stavu (proto delime 
% vypoctenym keff)
Fnominal = h * 1/keff*Sf(1:N) * phi;
Pnominal = Fnominal * Efis;

phi_abs = phi * (Ptarget / Pnominal);

figure;
plot(phi_abs)

%% Porovnani se semi-analytickym resenim z Mathematicy

load('Tok.mat');
load('x.mat');
load('Keff.mat');

% Hodnoty ve vektoru phi odpovidaji hodnotam reseni ve stredu intervalu
x = linspace(0.5*h,a-0.5*h,N);
fi=interp1(x,phi_abs,Expression1,'spline');
figure; 
plot(Expression1,Expression2*Expression3, 'r'); hold on; plot(Expression1,fi,'b')
axis square

fprintf('Relativni chyba keff: %g\n', (Expression3 - keff) / Expression3)
