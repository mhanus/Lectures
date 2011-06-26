% Funkce vracejici materialovy index bunky 
%
%   na souradnicich (xi,yj)         ... c
%   jejiho leveho (west) souseda    ... w
%   jejiho praveho (east) souseda   ... e
%   jejiho dolniho (south) souseda  ... s
%   jejiho horniho (north) souseda  ... n
%
% V pripade, ze sousedni bunka neexistuje, je 
% prislusna promenna nastavena na -1.
%
function [c, w, e, s, n] = get_reg(xi,yj,reg)
    [nx, ny] = size(reg);
    
    s = 0;
    e = 0;
    w = 0;
    n = 0;
    c = reg(xi,yj);
    
    if yj == 1 && xi == 1
        s = -1;
        w = -1;        
    elseif yj == 1 && xi > 1 && xi < nx
        s = -1;    
    elseif yj == 1 && xi == nx
        s = -1;
        e = -1;
    elseif xi == 1 && yj > 1 && yj < ny
        w = -1;
    elseif xi == nx && yj > 1 && yj < ny
        e = -1;
    elseif xi == 1 && yj == ny
        n = -1;
        w = -1;
    elseif yj == ny && xi > 1 && xi < nx
        n = -1;
    elseif xi == nx && yj == ny
        n = -1;
        e = -1;
    end
       
    if s ~= -1
        s = reg(xi,yj-1);
    end
    if e ~= -1
        e = reg(xi+1,yj);
    end
    if n ~= -1
        n = reg(xi,yj+1);
    end
    if w ~= -1
        w = reg(xi-1,yj);
    end
end