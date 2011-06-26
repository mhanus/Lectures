clear all

%% Ucinne prurezy

D  = [ 0.650 0.750 1.150 ];
Sa = [ 0.120 0.100 0.010 ];
nSf= [ 0.185 0.150 0.000 ];

%% Diskretizace

% sirka x vyska [cm]
a = 100;
b = 100;

% pocet bunek site v osach x,y, jejich rozmery
nx = 250; 
ny = 250;

hx = a/nx;
hy = b/ny;
% souradnice vertikalniho a horizontalniho rozhranni mezi tremi zadanymi zonami
ifacex = nx/2;
ifacey = 3*ny/5;

% mapa materialu jednotlivych bunek site
reg = zeros(nx,ny);
% souradnice stredu bunek site (v nichz se nachazeji vypoctene hodnoty
% reseni).
Xs = zeros(ny,nx);
Ys = zeros(ny,nx);

for yj = 1:ny    
    for xi = 1:nx        
        Xs(yj,xi) = xi*hx - 0.5*hx;
        Ys(yj,xi) = yj*hy - 0.5*hy;
        
        if (xi <= ifacex && yj <= ifacey)
            reg(xi,yj) = 2;
        elseif (xi <= ifacex && yj > ifacey)
            reg(xi,yj) = 1;
        else
            reg(xi,yj) = 3;
        end        
    end
end

%% Iteracni reseni - pocatecni odhady

PHI = ones(nx,ny);
keff = 1;

% Pocatecni stepny zdroj: celkove mnozstvi neutronu uvolnene za jednotku casu 
% pri stepeni, vyvolanem pocatecnim rozlozenim neutronoveho toku
src = 0.0;
for yj = 1:ny    
    for xi = 1:nx
        src = src + nSf(reg(xi,yj))*PHI(xi,yj);
    end
end

%% Iterace na vypocet dominantniho vl. cisla a prislusneho vl. vektoru

% Okno pro vykreslovani aproximace neutronoveho toku po kazde iteraci
figure;

max_iter = 1000;

for iter = 1:max_iter
    osrc = src;
    src = 0.0;
    
    surf(Xs,Ys,PHI','LineStyle','None','FaceColor','interp');
    colorbar;
    title(sprintf('keff(%d) = %1.6f', iter, keff));
    axis square;
    drawnow
        
    for yj = 1:ny
        for xi = 1:nx
            [c, w, e, s, n] = get_reg(xi,yj,reg);
            
            PHI(xi,yj) = 1/keff * hx*hy* nSf(c) * PHI(xi,yj);

            if w ~= -1  % unik pres levou stranu bunky 
                acw = 2*hy*D(w).*D(c)./( (D(w)+D(c))*hx );
                PHI(xi,yj) = PHI(xi,yj) + acw*PHI(xi-1,yj);
            else
                acw = 0.0;  % J = 0 na levem okraji reaktoru
            end
            if s ~= -1  % unik pres spodni stranu bunky
                acs = 2*hx*D(s).*D(c)./( (D(s)+D(c))*hy );
                PHI(xi,yj) = PHI(xi,yj) + acs*PHI(xi,yj-1);
            else
                acs = 0.0;  % J = 0 na spodnim okraji reaktoru
            end
            if e ~= -1  % unik pres pravou stranu bunky
                ace = 2*hy*D(c).*D(e)./( (D(c)+D(e))*hx );
                PHI(xi,yj) = PHI(xi,yj) + ace*PHI(xi+1,yj);
            else
                ace = hy*D(c)/(hx/2+2.1312*D(c));   % vakuum na pravem okraji
            end
            if n ~= -1  % unik pres horni stranu bunky
                acn = 2*hx*D(c).*D(n)./( (D(c)+D(n))*hy );
                PHI(xi,yj) = PHI(xi,yj) + acn*PHI(xi,yj+1);
            else
                acn = hx*D(c)/(hy/2+2.1312*D(c));   % vakuum na hornim okraji
            end

            acc = acw + ace + acs + acn + hx*hy*Sa(c);
            PHI(xi,yj) = PHI(xi,yj) / acc;
            
            % prirustek k novemu stepnemu zdroji
            src = src + nSf(c)*PHI(xi,yj);
        end
    end

    % aktualizace vlastniho cisla
    okeff = keff;
    keff = keff * src/osrc;
    
    if (keff - okeff)/keff < 1e-6
        break;
    end
end

%% Zobrazeni vysledku

figure;
contourf(Xs,Ys,PHI',30);
colorbar;
