function pez_bin(action,p_val)
%
%  pez_bin() :: Bulk of decode action routines. Zscale, Add Mirrors,etc
%  for PeZ v3.1b last Rev 11/10/97  -- No Modifications without author's consent
%  (type 'pez' in MATLAB to run)
%  Craig Ulmer / GRiMACE@ee.gatech.edu


global ed_scale sli_scale p_list z_list num_poles num_zeros z_axis w_main_win axes_zplane place num_diff_poles num_diff_zeros
global weight ed_weight sli_weight pez_new_point mirror_x mirror_y del_place del_x del_y  z_axis x_val y_val 
global pez_precision dp move_x_val move_y_val move_type move_numh move_place move_handle move_num_handle drag_move 
global ed_real ed_imag ed_mag ed_angle edit_type fr_omega id_plot pez_fuz 
global ui_text_line1 ui_text_line2 ui_text_line3 ui_text_line4 ed_change pez_gain pez_gain_ed pez_gain_sli pez_angle_type

global pez_redraw_kludge;

if nargin<1,
     action='new';
end;     




% ===================================
%  Handle the RESET Z_AXIS or 'rzaxis' call
if strcmp(action,'rzaxis')

       if (p_val), p_val=get(sli_scale,'val');
       else ,      p_val=str2num(get(ed_scale,'string')); end;
          
       if (p_val>=.5) & (p_val<=10)
          z_axis=p_val;
          axes(axes_zplane);
          axis([-z_axis z_axis -z_axis z_axis]);
       end,
       set(ed_scale,'string',num2str(z_axis));
       set(sli_scale,'val',z_axis);
       
       pez_fuz=2*z_axis/80;
       pez_plot(0);

% ===================================
%  Handle the RESET WEIGHT or 'rweight' call
elseif strcmp(action,'rweight')

    % See if came from slider or edit
       if (p_val), p_val=get(sli_weight,'val');
       else,       p_val=str2num(get(ed_weight,'string')); end;

    % Figure out direction  
       if (p_val>weight), p_val=ceil(p_val);
       elseif (p_val<weight), p_val=floor(p_val); end;
       
    % Determine if in range
       if (p_val>=1) & (p_val<=50), weight=p_val;
       elseif (p_val<1),            weight=1;
       else,                        weight=50;   end;
        
       set(ed_weight,'string',num2str(weight));
       set(sli_weight,'val',weight);

% ===================================
%  Handle the RESET GAIN or 'rgain' call
elseif strcmp(action,'rgain')

    % Get from slider or edit
       if (p_val),  p_val=get(pez_gain_sli,'val');
       else,        p_val=str2num(get(pez_gain_ed,'string'));end;

    % Figure out direction
    %   if (p_val>pez_gain), p_val=ceil(p_val);
    %   elseif (p_val<pez_gain), p_val=floor(p_val); end;
       
    % Determine if in range
       if (p_val>=0) & (p_val<=30), pez_gain=p_val;
       elseif            (p_val<1), pez_gain=0;
       else,                        pez_gain=30;   end;
        
       set(pez_gain_ed,'string',num2str(pez_gain));
       set(pez_gain_sli,'val',pez_gain);
       pez_plot(0);

% ===================================
%  Handle the Figure Mirrors for Poles or 'addmirrorp' call
elseif strcmp(action,'addmirrorp')
    place=0;

    if (abs(pez_new_point(1,1))<=0.05)
       pez_new_point(1,1)=0;
    end;
    if (abs(pez_new_point(1,2))<=0.05)
       pez_new_point(1,2)=0;
    end;          
   
    pez_add(pez_new_point,1,weight);
   
    if (mirror_x & pez_new_point(1,2))
        pez_new_point(1,2)= -pez_new_point(1,2);
        pez_add(pez_new_point,1,weight);
        pez_new_point(1,2)= -pez_new_point(1,2);
    end;
    if (mirror_y & pez_new_point(1,1))
        pez_new_point(1,1)= -pez_new_point(1,1);
        pez_add(pez_new_point,1,weight);
        pez_new_point(1,1)= -pez_new_point(1,1);
    end;
    if ( mirror_x & mirror_y & pez_new_point(1,1) & pez_new_point(1,2) )
        pez_new_point= -pez_new_point;
        pez_add(pez_new_point,1,weight);
        pez_new_point= -pez_new_point;
    end;  

    eval(pez_redraw_kludge);
    %refresh; %Otherwise ginput doesn't get cursor  
 
% ===================================
%  Handle the ADD Single POLE or 'addsp' call
elseif strcmp(action,'addsp')
    
    set(ui_text_line1,'horizontalalignment','center','string','Add a Pole');
    set(ui_text_line2,'horizontalalignment','left','string','Use the mouse to position the crosshairs over the z-plane.');
    set(ui_text_line3,'horizontalalignment','left','string','Click the mouse button to add the pole. To abort adding a ');
    set(ui_text_line4,'horizontalalignment','left','string','pole, click outside of the z-plane. ');
    
    axes(axes_zplane);
    pez_new_point = ginput(1);  
    if ( ~any(abs(pez_new_point)>z_axis) )
        pez_bin('addmirrorp');
        pez_plot(0);  % -- Do a pez_new_point plot   
    else
        pez_place=0;
    end;        
    pez('restore_text');
                            
% ===================================
%  Handle the ADD Multiple POLES or 'addmp' call
elseif strcmp(action,'addmp')

    pez_new_point=[0 0];
    while ( ~any(abs(pez_new_point)>z_axis) )
         pez_bin('addsp');
    end;       

% ===================================
%  Handle the ADD Double POLE or 'adddp' call
elseif strcmp(action,'adddp')

    set(ui_text_line1,'horizontalalignment','center','string','Add a Double Pole: ( Symetric to unit circle )');
    set(ui_text_line2,'horizontalalignment','left','string','Use the mouse to position the crosshairs over the z-plane.');
    set(ui_text_line3,'horizontalalignment','left','string','Click the mouse button to add the pole. To abort adding a ');
    set(ui_text_line4,'horizontalalignment','left','string','pole, click outside of the z-plane. ');

    axes(axes_zplane);
    pez_new_point = ginput(1);  
    if ( ~any(abs(pez_new_point)>z_axis) )
        pez_bin('addmirrorp');
        k=[pez_new_point(1,1)+pez_new_point(1,2)*j];
        r=abs(k);
        theta=angle(k);
        k=(1/r)*exp(j*theta);
        pez_new_point(1,1)=real(k);
        pez_new_point(1,2)=imag(k);
        pez_bin('addmirrorp');

        pez_plot(0);  % -- Do a pez_new_point plot 
    end;      
    pez('restore_text');
        
% ===================================
%  Handle the Figure Mirrors for Zeros or 'addmirrorz' call
elseif strcmp(action,'addmirrorz')
    place=0;

    if (abs(pez_new_point(1,1))<=0.05)
       pez_new_point(1,1)=0;
       
    end;
    if (abs(pez_new_point(1,2))<=0.05)
       pez_new_point(1,2)=0;
    end;          

    pez_add(pez_new_point,0,weight);
    
    if (mirror_x & pez_new_point(1,2) )
           pez_new_point(1,2)= -pez_new_point(1,2);
           pez_add(pez_new_point,0,weight);
           pez_new_point(1,2)= -pez_new_point(1,2);
    end;
    if (mirror_y & pez_new_point(1,1) )
           pez_new_point(1,1)= -pez_new_point(1,1);
           pez_add(pez_new_point,0,weight);
           pez_new_point(1,1)= -pez_new_point(1,1);
    end;
    if (mirror_x & mirror_y & pez_new_point(1,1) & pez_new_point(1,2) )
           pez_new_point= -pez_new_point;
           pez_add(pez_new_point,0,weight);
           pez_new_point= -pez_new_point;
    end; 

    eval(pez_redraw_kludge);
    %refresh; %Otherwise ginput doesn't get cursor  
    
% ===================================
%  Handle the ADD Single ZERO or 'addsz' call
elseif strcmp(action,'addsz')

    set(ui_text_line1,'horizontalalignment','center','string','Add a Zero');
    set(ui_text_line2,'horizontalalignment','left','string','Use the mouse to position the crosshairs over the z-plane.');
    set(ui_text_line3,'horizontalalignment','left','string','Click the mouse button to add the zero. To abort adding a ');
    set(ui_text_line4,'horizontalalignment','left','string','zero, click outside of the z-plane. ');

    axes(axes_zplane);
    pez_new_point = ginput(1); 
    if (  ~any(abs(pez_new_point)>z_axis) )
       pez_bin('addmirrorz');
       pez_plot(0);  % -- Do a pez_new_point plot  
    else
       place=0;
    end;
    pez('restore_text');
        
% ===================================
%  Handle the ADD Multiple ZEROS or 'addmz' call
elseif strcmp(action,'addmz')

    pez_new_point=[0 0];
    while (  ~any(abs(pez_new_point)>z_axis) ) 
       pez_bin('addsz');
    end;       

% ===================================
%  Handle the ADD Double ZERO or 'adddz' call
elseif strcmp(action,'adddz')

    set(ui_text_line1,'horizontalalignment','center','string','Add a Double Zero: ( Symetric to unit circle )');
    set(ui_text_line2,'horizontalalignment','left','string','Use the mouse to position the crosshairs over the z-plane.');
    set(ui_text_line3,'horizontalalignment','left','string','Click the mouse button to add the zero. To abort adding a ');
    set(ui_text_line4,'horizontalalignment','left','string','zero, click outside of the z-plane. ');

    axes(axes_zplane);
    pez_new_point = ginput(1);
    if ( ~any(abs(pez_new_point)>z_axis) )
       pez_bin('addmirrorz');
       k=[pez_new_point(1,1)+pez_new_point(1,2)*j];
       r=abs(k);
       theta=angle(k);
       k=(1/r)*exp(j*theta);
       pez_new_point(1,1)=real(k);
       pez_new_point(1,2)=imag(k);
       pez_bin('addmirrorz');
       pez_plot(0);  % -- Do a pez_new_point plot   
    end;
    pez('restore_text');
        

% ===================================
%  Handle the ADD Double POLE-ZERO COMBO or 'adddpz' call
elseif strcmp(action,'adddpz')

    set(ui_text_line1,'horizontalalignment','center','string','Add a Pole / Zero Double: ( Symetric to unit circle )');
    set(ui_text_line2,'horizontalalignment','left','string','Use the mouse to position the crosshairs over the z-plane.');
    set(ui_text_line3,'horizontalalignment','left','string','Click the mouse button to add the pole/zero. To abort adding a ');
    set(ui_text_line4,'horizontalalignment','left','string','pole/zero, click outside of the z-plane. ');

    axes(axes_zplane);
    pez_new_point = ginput(1);
    if (  ~any(abs(pez_new_point)>z_axis) )
      k=pez_new_point(1,1)+pez_new_point(1,2)*j;
      r=abs(k);

      theta=angle(k);
      
      the_complement(1,1)= real((1/r)*exp(j*theta));
      the_complement(1,2)= imag((1/r)*exp(j*theta));

      if (r>1)             % true then original click outside circle          
         pez_bin('addmirrorz');
         pez_new_point=the_complement;
         pez_bin('addmirrorp');
      else                      % original click inside circle
         pez_bin('addmirrorp');
         pez_new_point=the_complement;
         pez_bin('addmirrorz');
      end;

      pez_plot(0);  % -- Do a pez_new_point plot  
    end;   
    pez('restore_text');
        
   
% ===================================
%  Handle the Figure Mirrors for Zeros or 'delmirrorz' call
elseif strcmp(action,'delmirrorz')                                                


        pez_del(del_place,0,weight);
         
        if (mirror_x & num_zeros)
           del_place=pez_hit(del_x,-del_y,z_list(:,1),z_list(:,2),pez_precision);
           if del_place
              pez_del(del_place,0,weight);
           end;   
        end;
        
        if (mirror_y & num_zeros)
           del_place=pez_hit(-del_x,del_y,z_list(:,1),z_list(:,2),pez_precision);
           if del_place   
              pez_del(del_place,0,weight);
           end;   
        end;

        if (mirror_x & mirror_y & num_zeros)
           del_place=pez_hit(-del_x,-del_y,z_list(:,1),z_list(:,2),pez_precision);
           if del_place         
              pez_del(del_place,0,weight);
           end;
        end;
  
% ===================================
%  Handle the Figure Mirrors for Poles or 'delmirrorp' call
elseif strcmp(action,'delmirrorp')                                                


        pez_del(del_place,1,weight);
         
        if (mirror_x & num_poles)
           del_place=pez_hit(del_x,-del_y,p_list(:,1),p_list(:,2),pez_precision);
           if del_place
              pez_del(del_place,1,weight);
           end;   
        end;
        
        if (mirror_y & num_poles)
           del_place=pez_hit(-del_x,del_y,p_list(:,1),p_list(:,2),pez_precision);
           if del_place   
              pez_del(del_place,1,weight);
           end;   
        end;

        if (mirror_x & mirror_y & num_poles)
           del_place=pez_hit(-del_x,-del_y,p_list(:,1),p_list(:,2),pez_precision);
           if del_place         
              pez_del(del_place,1,weight);
           end;
        end;


% ===================================
%  Handle the Delete Single  'delexecute' call
elseif strcmp(action,'delexecute')
 
  if ((abs(del_x)<= z_axis) & (abs(del_y) <= z_axis) )
  
    del_place=0;
    if num_zeros
          del_place=pez_hit(del_x,del_y,z_list(:,1),z_list(:,2),pez_precision);
          if  del_place 
              pez_bin('delmirrorz');
          end;
    end;
              
    if (num_poles & ~del_place)
          del_place=pez_hit(del_x,del_y,p_list(:,1),p_list(:,2),pez_precision);
          if  del_place
              pez_bin('delmirrorp');
          end;
    end;      
 end;

  eval(pez_redraw_kludge);
  %refresh; %Otherwise ginput doesn't get cursor  
  pez_plot(0);

% ===================================
%  Handle the Delete Single  'dels' call
elseif strcmp(action,'dels')

    set(ui_text_line1,'horizontalalignment','center','string','Delete a Weighted Pole/Zero');
    set(ui_text_line2,'horizontalalignment','left','string','Use the mouse to select the object to be removed. If the');
    set(ui_text_line3,'horizontalalignment','left','string','item is weighted, the current weight will be subtracted'); 
    set(ui_text_line4,'horizontalalignment','left','string','from the object. To abort,click outside of the z-plane. ');

    drawnow;

      axes(axes_zplane);
      dp=ginput(1);
      del_x=dp(1,1);
      del_y=dp(1,2);

      pez_bin('delexecute');
      
      pez('restore_text');
 
% ===================================
%  Handle the Delete Many 'delm' call
elseif strcmp(action,'delm')

    set(ui_text_line1,'horizontalalignment','center','string','Delete Multiple Weighted Poles/Zeros');
    set(ui_text_line2,'horizontalalignment','left','string','Use the mouse to select the object to be removed. If the');
    set(ui_text_line3,'horizontalalignment','left','string','item is weighted, the current weight will be subtracted'); 
    set(ui_text_line4,'horizontalalignment','left','string','from the object. To abort, click outside of the z-plane.');

    drawnow;
      
       axes(axes_zplane);
       dp=ginput(1);
       del_x=dp(1,1);
       del_y=dp(1,2);

       pez_bin('delexecute');

       if ((abs(del_x) > z_axis) | (abs(del_y) > z_axis) | ( num_poles+num_zeros==0 ) )     
           pez('restore_text');
       else
           pez_bin('delm');
       end; 

% ===================================
%  Handle the Button Down for a Move 'movedown_b' call
elseif strcmp(action,'movedown_b') 

      %If user in edit menu, then forget moving
      set(ed_change,'visible','off');
      set(ed_real,'string','0');      
      set(ed_imag,'string','0');      
      set(ed_mag,'string','0');      
      set(ed_angle,'string','0');      
      set(ed_real,'call',' ');      
      set(ed_imag,'call',' ');      
      set(ed_mag,'call',' ');      
      set(ed_angle,'call',' '); 
      set(ed_change,'visible','off');

      %---------- This is the new version.. get rid of old..
      
      move_place = [ 0     0 0 0];
      move_handle= [ p_val 0 0 0];
      move_numh  = [ 0     0 0 0];
      move_type  = 0;
      
      if (num_poles)
        tmp_place=find(p_list(:,3)==p_val);
        if (tmp_place)
            move_place(1)=tmp_place;
            move_type=1;
            move_numh(1)=p_list(move_place(1),5);
            if (mirror_x)
                tmp_place=find( (p_list(:,1)==p_list(move_place(1),1)) .* (p_list(:,2)==(-p_list(move_place(1),2))) );
                if (tmp_place), move_place(2)=tmp_place; move_handle(2)=p_list(tmp_place,3);move_numh(2)=p_list(tmp_place,5); end;
            end;
            if (mirror_y)
                tmp_place=find( (p_list(:,1)==(-p_list(move_place(1),1))) .* (p_list(:,2)==p_list(move_place(1),2)) );
                if (tmp_place), move_place(3)=tmp_place; move_handle(3)=p_list(tmp_place,3);move_numh(3)=p_list(tmp_place,5); end;
            end;
            if (mirror_y & mirror_x)
                tmp_place=find( (p_list(:,1)==(-p_list(move_place(1),1))) .* (p_list(:,2)==(-p_list(move_place(1),2))) );
                if (tmp_place), move_place(4)=tmp_place; move_handle(4)=p_list(tmp_place,3);move_numh(4)=p_list(tmp_place,5); end;
            end;
        end;
      end;
      
      if ( (num_zeros) & ~(move_place(1)) )
        tmp_place=find(z_list(:,3)==p_val);
        if (tmp_place)
            move_place(1)=tmp_place;
            move_type=0;
            move_numh(1)=z_list(move_place(1),5);
            if (mirror_x)
                tmp_place=find( (z_list(:,1)==z_list(move_place(1),1)) .* (z_list(:,2)==(-z_list(move_place(1),2))) );
                if (tmp_place), move_place(2)=tmp_place; move_handle(2)=z_list(tmp_place,3);move_numh(2)=z_list(tmp_place,5); end;
            end;
            if (mirror_y)
                tmp_place=find( (z_list(:,1)==(-z_list(move_place(1),1))) .* (z_list(:,2)==z_list(move_place(1),2)) );
                if (tmp_place), move_place(3)=tmp_place; move_handle(3)=z_list(tmp_place,3);move_numh(3)=z_list(tmp_place,5); end;
            end;
            if (mirror_y & mirror_x)
                tmp_place=find( (z_list(:,1)==(-z_list(move_place(1),1))) .* (z_list(:,2)==(-z_list(move_place(1),2))) );
                if (tmp_place), move_place(4)=tmp_place; move_handle(4)=z_list(tmp_place,3);move_numh(4)=z_list(tmp_place,5); end;
            end;
        end;
      end;
     
      %--Make sure remove duplicates
      kk=move_place;
      dup_mask=~([0 kk(2:4)==kk(1)]|[0 0 kk(3:4)==kk(2)]|[0 0 0 kk(4)==kk(3)]);
      move_place  = move_place .* dup_mask;
      move_handle = move_handle.* dup_mask;
      move_numh   = move_numh  .* dup_mask;
     
     
     if ( move_place(1) )                                    %--Now have the list of junk to send       
        global pez_has_completed;
        pez_has_completed=0;
        set(w_main_win,'WindowButtonMotionFcn',['pez_move(''move'',',num2str(move_type),');'] );
        set(w_main_win,'WindowButtonUpFcn', ['pez_move(''finalize'',',num2str(move_type),');']);
     end;          
               
              

% ===================================
%  Handle the Select Edits 'edit_select' call
elseif strcmp(action,'edit_select')

  pez('info_edsel');
  pez_new_point_obj=ginput(1);
  move_place=0;
  move_type=0;
  
  if ( (abs(pez_new_point_obj(1))<=z_axis) & (abs(pez_new_point_obj(2))<=z_axis)  )
    if num_poles 
        move_place=pez_hit(pez_new_point_obj(1),pez_new_point_obj(2),p_list(:,1),p_list(:,2),pez_precision);
        if ( move_place~=0 )
                 move_type=1;
        end;
    end
    if (num_zeros & ~move_place)
        move_place=pez_hit(pez_new_point_obj(1),pez_new_point_obj(2),z_list(:,1),z_list(:,2),pez_precision);
    end;
  end;
  
  if move_place
      set(ed_real,'call', 'global edit_type;edit_type=1; pez_bin(''edit_set'');');      
      set(ed_imag,'call', 'global edit_type;edit_type=1; pez_bin(''edit_set'');');      
      set(ed_mag,'call',  'global edit_type;edit_type=0; pez_bin(''edit_set'');');      
      set(ed_angle,'call','global edit_type;edit_type=0; pez_bin(''edit_set'');');      
      if move_type
        set(ed_real,'string',num2str(p_list(move_place,1)));
        set(ed_imag,'string',num2str(p_list(move_place,2)));
        set(ed_mag,'string',  num2str(  abs(p_list(move_place,1)+j*p_list(move_place,2)) ) );
        angle_val=angle(p_list(move_place,1)+j*p_list(move_place,2));
      else  
        set(ed_real,'string',num2str(z_list(move_place,1)));
        set(ed_imag,'string',num2str(z_list(move_place,2)));
        set(ed_mag,'string',  num2str(  abs(z_list(move_place,1)+j*z_list(move_place,2)) ) );
        angle_val=angle(z_list(move_place,1)+j*z_list(move_place,2));
      end;

      if (pez_angle_type==1)
        set(ed_angle,'string',num2str(angle_val));
      elseif (pez_angle_type==2)
        set(ed_angle,'string',num2str(angle_val/pi));
      elseif (pez_angle_type==3) 
        set(ed_angle,'string',num2str(angle_val*180/pi));
      end;
      
      set(ed_change,'visible','on');
      pez('info_edch');
  else %No hit, blank out
      set(ed_change,'visible','off');
      set(ed_real,'string','0');      
      set(ed_imag,'string','0');      
      set(ed_mag,'string','0');      
      set(ed_angle,'string','0');      
      set(ed_real,'call',' ');      
      set(ed_imag,'call',' ');      
      set(ed_mag,'call',' ');      
      set(ed_angle,'call',' '); 
      pez('info_edco');     
  end;       

% ===================================
%  Handle the Edit Change 'edit_set' call
elseif strcmp(action,'edit_set')

    if edit_type
       % -- Real/Imag value changed
       move_x_tmp=str2num(get(ed_real,'string'));
       move_y_tmp=str2num(get(ed_imag,'string'));
       total_tmp =move_x_tmp + j*move_y_tmp;
       mag_tmp   =abs(total_tmp);
       angle_tmp =angle(total_tmp);
       
       %Rescale Angle based on angle type
       if (pez_angle_type==2)
           angle_tmp=angle_tmp/pi;
       elseif (pez_angle_type==3)
           angle_tmp=angle_tmp*180/pi;
       end;        

    else
       % -- Mag / Ang  value changed
       mag_tmp    =str2num(get(ed_mag,'string'));
       angle_tmp  =str2num(get(ed_angle,'string'));

       if (pez_angle_type==1)
           total_tmp=mag_tmp*exp(j*angle_tmp);
       elseif (pez_angle_type==2)
           total_tmp=mag_tmp*exp(j*angle_tmp*pi);
       else
           total_tmp=mag_tmp*exp(j*angle_tmp*pi/180);
       end;    
       
       move_x_tmp =real(total_tmp);
       move_y_tmp =imag(total_tmp);
    end;    


    set(ed_real, 'string',num2str(move_x_tmp));
    set(ed_imag, 'string',num2str(move_y_tmp));
    set(ed_mag,  'string',num2str(mag_tmp   ));
    set(ed_angle,'string',num2str(angle_tmp ));   

% ===================================
%  Handle the Edit Change 'edit_angle_type' call
elseif strcmp(action,'edit_angle_type')

    new_angle_type=get(gco,'val');
    old_angle=str2num(get(ed_angle,'string'));
    
    if (pez_angle_type==1)
      if (new_angle_type==2)
         set(ed_angle,'string',num2str(old_angle/pi));
      elseif (new_angle_type==3)
         set(ed_angle,'string',num2str(180*old_angle/pi));
      end;
    elseif (pez_angle_type==2)   
      if (new_angle_type==1)
         set(ed_angle,'string',num2str(old_angle*pi));
      elseif (new_angle_type==3)
         set(ed_angle,'string',num2str(old_angle*180));
      end;
    elseif (pez_angle_type==3)   
      if (new_angle_type==1)
         set(ed_angle,'string',num2str(old_angle*pi/180));
      elseif (new_angle_type==2)
         set(ed_angle,'string',num2str(old_angle/180));
      end;
    end;
    
    pez_angle_type=new_angle_type;
    
% ===================================****************************************************
%  Handle the Edit Change 'edit_final' call
elseif strcmp(action,'edit_final')

    pez_new_point(1,1)=str2num(get(ed_real,'string'));
    pez_new_point(1,2)=str2num(get(ed_imag,'string'));

    del_place=move_place;
    tmp_weight=weight;
    if move_type
      weight=p_list(move_place,4);
      del_x= p_list(move_place,1);
      del_y= p_list(move_place,2);
      pez_bin('delmirrorp');
      pez_bin('addmirrorp');
    else        
      weight=z_list(move_place,4);
      del_x= z_list(move_place,1);
      del_y= z_list(move_place,2);
      pez_bin('delmirrorz');
      pez_bin('addmirrorz');
    end;
    
    weight=tmp_weight;
    set(ed_real, 'string','0');
    set(ed_imag, 'string','0');
    set(ed_mag,  'string','0');
    set(ed_angle,'string','0');   
    set(ed_real,'call', ' ');      
    set(ed_imag,'call', ' ');      
    set(ed_mag,'call',  ' ');      
    set(ed_angle,'call',' ');      
    set(ed_change,'visible','off');
    
    pez('info_edco');
    pez_plot(0);
    
    axes(axes_zplane);
    eval(pez_redraw_kludge);
    rdraw;
    %refresh;
    
        
% ===================================
%  Handle the Clear Zeros 'kill_zeros' call
elseif strcmp(action,'kill_zeros')

    if num_zeros
      delete(z_list(:,3));
      delete(z_list(find(z_list(:,5)),5))
    end;
    
    pez_gain=1;
    set(pez_gain_ed,'string','1');
    set(pez_gain_sli,'val',1);
    
    z_list=[];
    num_zeros=0;
    num_diff_zeros=0;

% ===================================
%  Handle the Clear Poles 'kill_poles' call
elseif strcmp(action,'kill_poles')

    if num_poles
      delete(p_list(:,3));
      delete(p_list(find(p_list(:,5)),5))
    end;

    pez_gain=1;
    set(pez_gain_ed,'string','1');
    set(pez_gain_sli,'val',1);
    
    p_list=[];
    num_poles=0;
    num_diff_poles=0;

    
% ===================================
%  Handle the otherwise calls..  
else 
sprintf('This is a data file for Pez. To run this matlab program, type pez.'),
sprintf(action),
end
