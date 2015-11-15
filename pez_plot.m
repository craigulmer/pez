function pez_plot(is_quick)

  global p_list z_list num_poles num_zeros num_diff_poles num_diff_zeros
  global id_plot fr_omega frs_omega z_axis plot_theta pez_fuz plot_ax

  %---- Switch to the plot window, recreate if necessary ------------
    if  ~any( get(0,'children') == id_plot )
          pez('new_plot_win');
    end, 

    set(id_plot,'visible','on');    
    figure(id_plot);

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
    axes(plot_ax(1));
    cla;
    set(gca,'box','on','aspect',[1 1]);
  
    hold on;
  
    plot(cos(plot_theta),sin(plot_theta),':',[-10; 10],[0;0],':y',[0;0],[-10; 10],':y');

    if num_poles
      plot(p_list(:,1),p_list(:,2),'x');
     
      num_array(:,1:2 )=p_list(:,1:2)+pez_fuz;
      num_array(:,3)=p_list(:,4);
      num_array((num_array(:,3)==1),:)=[];
      if ~isempty(num_array)
        for loops_suck=1:length(num_array(:,1)),
         text(num_array(loops_suck,1),num_array(loops_suck,2),num2str(num_array(loops_suck,3)));
        end;   
      end;  
      
    end;
    
    num_array=[];
    
    if num_zeros
      plot(z_list(:,1),z_list(:,2),'o');
            
      num_array(:,1:2 )=z_list(:,1:2)+pez_fuz;
      num_array(:,3)=z_list(:,4);
      num_array((num_array(:,3)==1),:)=[];
      if ~isempty(num_array)
         for loops_suck=1:length(num_array(:,1)),
          text(num_array(loops_suck,1),num_array(loops_suck,2),num2str(num_array(loops_suck,3)));
         end;   
      end;
   
    end;  
    xlabel('Real part')
    ylabel('Imaginary part')

    axis([-z_axis z_axis -z_axis z_axis]);

  %---- Do the Impulse Response -------------------------------------
    axes(plot_ax(2));
    cla;
    L=50;
    if (num_poles==0 & num_zeros<10)  L=10;
      elseif (num_poles==0 & num_zeros>=10) L=num_zeros; end,
    
    if (num_zeros==0) z_poly=1; end,
    if (num_poles==0) p_poly=1; end,
   
    zero_zeropad=length(find(z_poly==0));
    pole_zeropad=length(find(p_poly==0));
    
    h=real(filter(z_poly,p_poly, [1; zeros(L,1)]));
    
    start_place=0;
    if pole_zeropad
       h=[zeros(pole_zeropad,1); h];
    elseif zero_zeropad,
       start_place=-zero_zeropad;
    end;
       
    stem(start_place:(start_place+length(h)-1),h)
    
    
  %---- Do the Magnitude Plot ---------------------------------------
    axes(plot_ax(3));
    cla;
    if is_quick
       hfreq=pez_freq(z_poly,p_poly,frs_omega);
       plot(frs_omega/pi,abs(hfreq), [-1 1], [0 0]);
    else
       hfreq=pez_freq(z_poly,p_poly,fr_omega);
       plot(fr_omega/pi,abs(hfreq), [-1 1], [0 0]);
    end;   

  %---- Do the Phase Plot -------------------------------------------
    axes(plot_ax(4));
    cla;
    if is_quick
       plot(frs_omega/pi,angle(hfreq),[-1 1], [0 0]);
    else
       plot(fr_omega/pi,angle(hfreq),[-1 1], [0 0]);
    end;
    