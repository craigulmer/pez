function pez_plot(is_quick)
%
%  pez_plot(is_quick) :: These update the plots window.
%  for PeZ v3.1beta last Rev 9/22/97  -- No Modifications without author's consent
%  (type 'pez' in MATLAB to run)
%  Craig Ulmer / GRiMACE@ee.gatech.edu

  global mat_version aspect_ratio_name fixed_aspect;
  global pez_redraw_type;
  global pez_stemx pez_stemy;


  global p_list z_list num_poles num_zeros num_diff_poles num_diff_zeros
  global id_plot fr_omega frs_omega z_axis plot_theta pez_fuz plot_ax pez_log pez_gain pez_groupdelay

  %---- Switch to the plot window, recreate if necessary ------------
    if  ~any( get(0,'children') == id_plot )
	  pez('new_plot_win');
	  new=1;                   %x
	  figure(id_plot);         %x
    end, 

    set(id_plot,'visible','on');
    h_data=get(id_plot,'user');    

  %---- Fix the list as Polynomials ---------------------------------  
    if (num_diff_poles == 0 )      
	 tmp_p_list = 0;
	 p_poly=[];
    else 
	 tmp_p_list=p_list(:,1)+j*p_list(:,2);
	 tmp_p_list=pez_exp( tmp_p_list,p_list(:,4) ); 
	 p_poly=poly(tmp_p_list); 
    end;
	
    if (num_diff_zeros == 0 )
	 tmp_z_list = 0;
	 z_poly=[];
    else
	 tmp_z_list=z_list(:,1)+j*z_list(:,2);
	 tmp_z_list=pez_exp( tmp_z_list,z_list(:,4) );  
	 z_poly=poly(tmp_z_list);
    end;
     
  %---- Do the Pole-Zero Plot ---------------------------------------

    if (~is_quick) %Redraws all
      axes(plot_ax(1));
      cla;       
      plot(cos(plot_theta),sin(plot_theta),':y',[-10; 10],[0;0],':y',[0;0],[-10; 10],':y','erasemode',pez_redraw_type);
      h_data(1)=plot(0,0,'erasemode',pez_redraw_type,'color','yellow');  %x's
      h_data(2)=plot(0,0,'erasemode',pez_redraw_type,'color','yellow');  %o's
      set(gcf,'userdata',h_data);
    end;

    if num_poles
      set(h_data(1),'xdata',p_list(:,1),'ydata',p_list(:,2),'linestyle','x','color','yellow');
     
      if(~is_quick)%Only draw if redrawing all
	  num_array(:,1:2 )=p_list(:,1:2)+pez_fuz;
	  num_array(:,3)=p_list(:,4);
	  num_array((num_array(:,3)==1),:)=[];
	  if ~isempty(num_array)
	    for loops_suck=1:length(num_array(:,1)),
	       text(num_array(loops_suck,1),num_array(loops_suck,2),num2str(num_array(loops_suck,3)),'color','white');
	    end;   
	  end;  
      end;%isquick
    end;
    
    num_array=[];
    
    if num_zeros
      set(h_data(2),'xdata',z_list(:,1),'ydata',z_list(:,2),'linestyle','o','color','yellow');

      if(~is_quick) %only draw if redrawing all
	  num_array(:,1:2 )=z_list(:,1:2)+pez_fuz;
	  num_array(:,3)=z_list(:,4);
	  num_array((num_array(:,3)==1),:)=[];
	  if ~isempty(num_array)
	    for loops_suck=1:length(num_array(:,1)),
	      text(num_array(loops_suck,1),num_array(loops_suck,2),num2str(num_array(loops_suck,3)),'color','white' );
	    end;   
	 end;
      end; %isquick
    end; %num_zeros
  
    if(~is_quick), axis([-z_axis z_axis -z_axis z_axis]); end;

  %---- Do the Impulse Response -------------------------------------
    L=49;
    if (num_poles==0 & num_zeros<10)  L=10;
      elseif (num_poles==0 & num_zeros>=10 & num_zeros<49 ) L=num_zeros; end,
    
    if (num_zeros==0) z_poly=1; end,
    if (num_poles==0) p_poly=1; end,
   
    zztmp=find(z_poly==0);
    zptmp=find(p_poly==0);
    zero_zeropad=length(zztmp(zztmp>max(find(z_poly~=0))));
    pole_zeropad=length(zptmp(zptmp>max(find(p_poly~=0))));
    
    h=pez_gain*real(filter(z_poly,p_poly, [1; zeros(L,1)]));
    
    start_place=0;
    if pole_zeropad
       h=[zeros(pole_zeropad,1); h];
    end;
    if zero_zeropad,
       start_place=-zero_zeropad;
    end;

    if(length(h)>50), h=h(1:50); end; %Truncate if necessary
       
    set(h_data(3),'xdata',start_place:(start_place+length(h)-1),...
		  'ydata',h, 'linestyle','o','erasemode',pez_redraw_type);
    
    out_stem=pez_stemy(1:3*length(h));
    out_stem(2:3:3*length(h))=h;

    set(h_data(4),'xdata',pez_stemx(1:3*length(h))+start_place,...
		  'ydata',out_stem,'erasemode',pez_redraw_type);

    if(~is_quick),
	set(plot_ax(2),'xlim',[start_place-2 length(h)+start_place+2],...
		      'ylim',[ 1.1*min([-1; h]) 1.1*max([1; h]) ]      );
    end;
 
    shifter_val=zero_zeropad-pole_zeropad;
    
  %---- Do the Magnitude Plot ---------------------------------------

    if is_quick
       hfreq=pez_freq(z_poly,p_poly,frs_omega);
       hfreq=exp(j*frs_omega*shifter_val).*hfreq*pez_gain;
       if (pez_log)
	 db_value=20*log10(abs(hfreq));
	 set(h_data(5),'xdata',frs_omega/2/pi,'ydata',db_value);
       else
	  set(h_data(5),'xdata',frs_omega/2/pi,'ydata',abs(hfreq) );
       end;  
    else
       hfreq=pez_freq(z_poly,p_poly,fr_omega);
       hfreq=exp(j*fr_omega*shifter_val).*hfreq*pez_gain;
       if (pez_log)
	 db_value=20*log10(abs(hfreq));
	 set(h_data(5),'xdata',fr_omega/2/pi,'ydata',db_value);
	 set(plot_ax(3),'ylim', [ max([1.05*min(db_value-1) -120]) 1.05*max([1 db_value])]);
       else  
	 set(h_data(5),'xdata',fr_omega/2/pi,'ydata',abs(hfreq) );
	 set( plot_ax(3),'ylim',[ -0.05 1.05*max([1 abs(hfreq)])  ]);
       end;  
    end;   

  %---- Do the Phase Plot -------------------------------------------
    if ~pez_groupdelay,
	  if is_quick,
	      set(h_data(6),'xdata',frs_omega/2/pi, 'ydata',angle(hfreq));
	  else,
	      data_angle=angle(hfreq);
	      set(h_data(6),'xdata',fr_omega/2/pi,'ydata',data_angle);
	      set(plot_ax(4),'ylim',[1.05*min([-1 data_angle]) 1.05*max([1 data_angle])]);
	 end;
    else
	  if is_quick,
	      set(h_data(6),'xdata',frs_omega/2/pi,'ydata',grpdelay(z_poly,p_poly,frs_omega) );
	  else,
	      data_grp=grpdelay(z_poly,p_poly,fr_omega);
	      set(h_data(6),'xdata',fr_omega/2/pi,'ydata',data_grp );
	      set(plot_ax(4),'ylim',[ 1.05*min([-1 data_grp]) 1.05*max([1 data_grp])] );
 end;
end;
    

