function rdraw
%Refresh utility for the lame PC version of Matlab v4.2
%This version of Matlab erases things by mistake, you can
%get things back by rescaling the axis. kludge kludge kludge

global pez_is_not_a_lame_pc axes_zplane

if(pez_is_not_a_lame_pc), return
end;

size=get(axes_zplane,'xlim');
set(axes_zplane,'xlim',size-(1)*10^(-10));
set(axes_zplane,'xlim',size+(1)*10^(-10));

