clear all

%pripad = 1; % Vypocet s ilustraci iteracni procedury
pripad = 2;

%% Materialove vlastnosti

D   = 1.5;    
L   = 10;     
Sa  = D ./ (L.^2);

%% Diskretizace

% delka desky [cm]
if pripad == 1
    a = 1;
else
    a = 100;
end

% N+1 uzlu diskretni site: x1 = 0, ... , x_{N+1} = a
if pripad == 1
    N = 10;
else
    N = 250;
end

% Vzdalenost mezi uzly site
h = a/N;

% Okrajove podminky - vakuum na obou okrajich
GAMMA_E = 0.5;
GAMMA_W = 0.5;

%% Externi zdroj

S = zeros(N+1,1);
S(N/2+1) = 1;

%% Iteracni reseni

% Pocatecni odhad
PHI = zeros(N+1,1);

norm_phi = 0;   % norma vektoru PHI (pro konvergencni krit.)

% Okno pro vykreslovani aproximace neutronoveho toku po kazde iteraci
figure;

max_iter = 100000;

for iter = 1:max_iter    
    plot(PHI)
    title(sprintf('iterace %d, phi(50)=%1.6f, phi(100)=%1.6f', iter, PHI(N/2+1), PHI(N+1)));
    axis square;
    drawnow
    
    oPHI = PHI;
        
    for xi = 1:N+1
        PHI(xi) = S(xi)/h;
        
        if xi == 1
            acw = (2*GAMMA_W*h + 2*D) / h^2;
        else
            acw = D/h^2;
            PHI(xi) = PHI(xi) + acw * oPHI(xi-1);
        end
        if xi == N+1
            ace = (2*GAMMA_E*h + 2*D) / h^2;
        else
            ace = D/h^2;
            PHI(xi) = PHI(xi) + ace * oPHI(xi+1);
        end
        
        acc = acw + ace + Sa;
        PHI(xi) = PHI(xi) / acc;
        
        if pripad == 1
            % Ilustrace iteracniho procesu
            if iter < 10
                plot(PHI)
                title(sprintf('iterace %d, x = %f', iter, (xi-1)*h));
                axis square;
                drawnow
                pause(1);
            end
        end
    end

    onorm_phi = norm_phi;
    norm_phi = sum(PHI);
    if (norm_phi - onorm_phi)/norm_phi < 1e-6
        disp((norm_phi - onorm_phi)/norm_phi) 
        break;
    end
    
    if (PHI(N/2+1) >= 3)
        break;
    end
end
