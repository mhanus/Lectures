clear all

%% Ucinne prurezy

D  = [ 0.650 0.750 1.150 ];
Sa = [ 0.120 0.100 0.010 ];
%nSf= [ 0.185 0.075 0.000 ];
nSf= [ 0.185 0.150 0.000 ];

%% Externi zdroj

S = 1;

%% Diskretizace

% sirka x vyska [cm]
a = 10;
b = 10;

% pocet bunek site v osach x,y, jejich rozmery
nx = 200; 
ny = 100;

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

%% Sestaveni soustavy algebraickych rovnic

A = sparse(nx*ny,nx*ny);
k = 1;

for yj = 1:ny
    for xi = 1:nx
        [c, w, e, s, n] = get_reg(xi,yj,reg);
        
        if w ~= -1  % unik pres levou stranu bunky
            acw = 2*hy*D(w).*D(c)./( (D(w)+D(c))*hx );
            A(k,k-1) = -acw;
        else
            acw = 0.0;  % J = 0 na levem okraji reaktoru
        end
        if s ~= -1  % unik pres spodni stranu bunky
            acs = 2*hx*D(s).*D(c)./( (D(s)+D(c))*hy );
            A(k,k-nx) = -acs;
        else
            acs = 0.0;  % J = 0 na spodnim okraji reaktoru
        end
        if e ~= -1  % unik pres pravou stranu bunky
            ace = 2*hy*D(c).*D(e)./( (D(c)+D(e))*hx );
            A(k,k+1) = -ace;
        else
            ace = 2*hy*D(c)/hx;     % phi = 0 na pravem okraji reaktoru           
        end
        if n ~= -1  % unik pres horni stranu bunky
            acn = 2*hx*D(c).*D(n)./( (D(c)+D(n))*hy );
            A(k,k+nx) = -acn;
        else
            acn = 2*hx*D(c)/hy;     % phi = 0 na hornim okraji reaktoru
        end
        
        A(k,k) = acw + ace + acs + acn + hx*hy*(Sa(c) - nSf(c));
        
        k = k + 1;
    end
end  

figure;
spy(A)

% Prava strana
rhs = zeros(nx*ny,1);
rhs(1) = S/4;

%% Reseni soustavy

phi = A\rhs;

%% Zobrazeni vysledku

PHI = zeros(ny,nx);
k = 1;
for yj = 1:ny
    for xi = 1:nx
        PHI(yj,xi) = phi(k);
        k = k + 1;
    end
end

figure;
contourf(Xs,Ys,PHI,30);
colorbar;
axis square;
figure;
surf(Xs,Ys,PHI);
colorbar;
axis square;
