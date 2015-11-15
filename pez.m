function pez(action,p_val)
%PeZ v2.8: A Pole-Zero Editor for MATLABby Craig Ulmer / GRiMACE@ee.gatech.edu
%No Modifications without the author's consent. See documentation for Legals.
%
%  See online help at:  http://www.ece.gatech.edu/users/grimace/pez/index.html
%
%Short: PeZ allows a user to graphically edit the poles and zeros for a
%filter in the complex Z-Plane. To run, boot up MATLAB and type  pez.

global ed_scale sli_scale p_list z_list num_poles num_zeros z_axis w_main_win axes_zplane place num_diff_poles num_diff_zeros
global weight ed_weight sli_weight new mirror_x mirror_y del_weight del_values pz precision ed_real ed_imag ed_mag ed_angle
global fr_omega id_plot ui_text_line1 ui_text_line2 ui_text_line3 ui_text_line4 pez_fuz ed_change plot_ax
global pez_gain

if nargin<1,
     action='new';
end;     

% ================================
%  Handle the NEW event

if strcmp(action,'new'),
  
  % Initialize variables
  labelcolor=192/255*[1 1 1];
  framecolor = [ .5 .5 .5];
 
  p_list=[];
  z_list=[];
  pez_gain=1;
  
  num_poles=0;
  num_diff_poles=0;
  num_zeros=0;
  num_diff_zeros=0;

  z_axis=2;

  weight=1;
  del_values=0;
  pz=0;
  pez_fuz=2*z_axis/80;
  pez_bin('init_strings');

   
  % Open up main control window
  w_main_win=figure('resize','on','units','pixels',...
                  'Pointer','watch',... 
                  'pos',[400 0 800 465],...
                  'numbertitle','off','name','PEZ v2.8 : Pole-Zero Control Window',...
                  'visible','off');
  
  pez('new_plot_win');

  pez_config('load_default');
    
  figure(w_main_win);
                  
  %^^^^^^^^^^^^ Menu Ops ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  

  % Set up the Menu Box Frame
  uicontrol(w_main_win, 'style','frame','units','norm','pos',[ .001 .93 .998 .070],'backgroundcolor',[.4 .4 .6] );

  um_file=uicontrol('Max',0 ,'Min',1 ,'Units','norm','back',[.5 .5 .8],'fore',[1 1 1],... 
                     'Pos',[ 0.01 0.945 0.14 0.05 ],... 
                     'Style','popupmenu','horizontalalign','left',... 
                     'string','<File...> |Load...|Save...|Save Roots...|Save Polys...|PeZ Info...|Exit');

  um_clear=uicontrol('Max',0 ,'Min',1 ,'Units','norm','back',[.5 .5 .8],'fore',[1 1 1],... 
                     'Pos',[ 0.155 0.945 0.14 0.05 ],... 
                     'Style','popupmenu','horizontalalign','left',... 
                     'string','<Clear...>|Poles|Zeros|All ');

  um_size=uicontrol('Max',0 ,'Min',1 ,'Units','norm','back',[.5 .5 .8],'fore',[1 1 1],... 
                     'Pos',[ 0.30 0.945 0.14 0.05 ],... 
                     'Style','popupmenu','horizontalalign','left',... 
                     'string','<Quicksize...>|Tiny|Small|Regular|---------|Redo Plots');

  set(um_file,'call',['argv=get(gco,''val'');set(gco,''val'',1);',...
                      'if argv==2, pez(''load'');pez_plot(0);',...
                      'elseif argv==3, pez(''save''); ',...
                      'elseif argv==4, pez(''save_roots'');',...
                      'elseif argv==5, pez(''save_poly'');',...
                      'elseif argv==6, pez(''hit_info'');',...
                      'elseif argv==7, pez(''exit'');end;']);

  set(um_clear,'call',['argv=get(gco,''val'');set(gco,''val'',1);',...
                      'if argv==2, pez_bin(''kill_poles'');',...
                      'elseif argv==3, pez_bin(''kill_zeros'');',...
                      'elseif argv==4, pez_bin(''kill_zeros'');pez_bin(''kill_poles''); end;']);

  set(um_size,'call',['argv=get(gco,''val'');set(gco,''val'',1);',...
                      'if argv==2, pez(''size_supersmall'');',...
                      'elseif argv==3, pez(''size_small'');',...
                      'elseif argv==4, pez(''size_regular'');',...
                      'elseif argv==6, pez_plot(0); end;']);
                                   
                     
  % Set up the Z-Plane plot Axes
  axes_zplane=axes('aspectRatio',[1,1],'units','norm','pos',[.06 .198 .38 .67],'drawmode','fast');
  
  axis(axis);
  set(gca,'box','on');
  
  hold on;
  
  theta = linspace(0,2*pi,70);
  plot(cos(theta),sin(theta),':',[-10; 10],[0;0],':y',[0;0],[-10; 10],':y');

  axis([-z_axis z_axis -z_axis z_axis]);
  title('Z-Plane');
  xlabel('Real part')
  ylabel('Imaginary part')

  % Set up the Info Box Frame
  uicontrol(w_main_win, 'style','frame','units','norm','pos',[ .47 .0 .52 .211],'backgroundcolor',[.65 .45 .45] );

  % Set up Info Box Welcome Text
  ui_text_line1 = uicontrol(w_main_win,'style','text','units','norm','pos', [ .49 .147 .48 .048],...
                       'backgroundcolor',[.65 .40 .40],...
                       'foregroundcolor','white');
 
  % Set up Info Box Welcome Text
  ui_text_line2 = uicontrol(w_main_win,'style','text','units','norm','pos', [ .49 .099 .48 .048],...
                       'backgroundcolor',[.65 .40 .40],...
                       'foregroundcolor','white');
 
  % Set up Info Box Welcome Text
  ui_text_line3 = uicontrol(w_main_win,'style','text','units','norm','pos', [ .49 .050 .48 .048],...
                       'backgroundcolor',[.65 .40 .40],...
                       'foregroundcolor','white');

  % Set up Info Box Welcome Text
  ui_text_line4 = uicontrol(w_main_win,'style','text','units','norm','pos', [ .49 .01 .48 .048],...
                       'backgroundcolor',[.65 .40 .40],...
                       'foregroundcolor','white');
   
  pez('restore_text');                     

  % -/- Z-Plane Scaler -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
 
  uicontrol('style','text','units','norm',...
          'pos', [.15 .09 .16 .04], 'backgroundcolor','black','foregroundcolor','cyan',...
          'horizontalalignment','left','string','Z-Plane Axis:');

  % Scale Entry Box
  ed_scale = uicontrol('style','edit','units','norm','pos', [.28 .09 .05 .036],...
                   'horizontalalignment','left',...
                   'string', num2str(z_axis), 'val', z_axis,...
                   'call', 'pez_bin(''rzaxis'',0); ');
          
  % Scale Slider
  sli_scale = uicontrol(w_main_win,'Style','slider','Min',.5,'Max',10,'val',z_axis,...
                      'units','norm','pos',[ .15 .045 .18 .036],...
                      'CallBack','pez_bin(''rzaxis'',1 );' );
 

  % -/- Add Options -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
  % Set Up big frame
  uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',[.65 .50 .50],'pos', [ .47 .23 .52 .68]);
  
  % Set up a frame for Weight
  uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',framecolor,'pos', [ .50 .27 .22 .10]);

  % Set up a frame for Add buttons
  uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',framecolor,'pos', [ .50 .38 .22 .45]);

  % Set up a frame for Add Title
  uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',framecolor,'pos', [ .50 .82 .22 .05]);
  
  % Set up Add Title Text
  uicontrol(w_main_win,'style','text','units','norm','pos', [ .51 .825 .20 .04],...
                       'backgroundcolor',framecolor,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','center','string','Add Poles & Zeros');

  
  % Set up text for Add Single

  uicontrol(w_main_win,'style','text','units','norm','pos', [ .51 .77 .20 .04],...
                       'backgroundcolor',framecolor,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','center','string','Add Single');

  uicontrol('style','push','units','norm', ...
                        'backgroundcolor',labelcolor,...
                        'foregroundcolor',[0 0 0],...
                        'string','Pole',...
                        'pos',[.515 .72 .095 .045 ],...
                        'callback','pez_bin(''addsp'');');
  
  uicontrol('style','push','units','norm', ...
                        'backgroundcolor',labelcolor,...
                        'foregroundcolor',[0 0 0],...
                        'string','Zero',...
                        'pos',[.615 .72 .095 .045 ],...
                        'callback','pez_bin(''addsz'');');


  
 % Set up text for Add Multiple

  uicontrol(w_main_win,'style','text','units','norm','pos', [ .51 .64 .20 .04],...
                       'backgroundcolor',framecolor,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','center','string','Add Multiple');

  uicontrol('style','push','units','norm', ...
                        'backgroundcolor',labelcolor,...
                        'foregroundcolor',[0 0 0],...
                        'string','Poles',...
                        'pos',[.515 .59 .095 .045 ],...
                        'callback','pez_bin(''addmp'');' );
  
  uicontrol('style','push','units','norm', ...
                        'backgroundcolor',labelcolor,...
                        'foregroundcolor',[0 0 0],...
                        'string','Zeros',...
                        'pos',[.615 .59 .095 .045 ],...
                        'callback','pez_bin(''addmz'');' );

% Set up text for Add Double

  uicontrol(w_main_win,'style','text','units','norm','pos', [ .51 .51 .20 .04],...
                       'backgroundcolor',framecolor,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','center','string','Add Double');

  uicontrol('style','push','units','norm', ...
                        'backgroundcolor',labelcolor,...
                        'foregroundcolor',[0 0 0],...
                        'string','Poles',...
                        'pos',[.51 .46 .095 .045 ],...
                        'callback','pez_bin(''adddp'');');
  
  uicontrol('style','push','units','norm', ...
                        'backgroundcolor',labelcolor,...
                        'foregroundcolor',[0 0 0],...
                        'string','Zeros',...
                        'pos',[.615 .46 .095 .045 ],...
                        'callback','pez_bin(''adddz'');');

  % Pole / Zero Combo
  uicontrol('style','push','units','norm', ...
                        'backgroundcolor',labelcolor,...
                        'foregroundcolor',[0 0 0],...
                        'string','Pole / Zero Combo',...
                        'pos',[ .51 .41 .20 .045 ],...
                        'callback','pez_bin(''adddpz''); ');

 
  % Set up text for Weight

  uicontrol(w_main_win,'style','text','units','norm','pos', [ .51 .325 .14 .04],...
                       'backgroundcolor',framecolor,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','left','string','Current Weight:');

  % Weight Entry Box
  ed_weight = uicontrol('style','edit','units','norm','pos', [.65 .325 .06 .04],...
                   'horizontalalignment','left',...
                   'string', num2str(weight), 'val', weight,...
                   'call', 'pez_bin(''rweight'',0); ');
          
  % Weight Slider
  sli_weight = uicontrol(w_main_win,'Style','slider','Min',1,'Max',50,'val',weight,...
                      'units','norm','pos',[ .51 .28 .20 .036],...
                      'CallBack','pez_bin(''rweight'',1);' );

 % ------------------------
 % Set up a frame for Move buttons
  uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',framecolor,'pos', [.73 .47 .24 .36]);
   
  % Set up a frame for Move Title
  uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',framecolor,'pos', [ .73 .82 .24 .05]);
 
  % Set up Move Title Text
  uicontrol(w_main_win,'style','text','units','norm','pos', [ .76 .825 .18 .04],...
                       'backgroundcolor',framecolor,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','center','string','Move Poles & Zeros');

  % Drag By Mouse
  uicontrol('style','push','units','norm', ...
                        'backgroundcolor',labelcolor,...
                        'foregroundcolor',[0 0 0],...
                        'string','Drag With Mouse',...
                        'pos',[.76 .75 .18 .045 ],...
                        'callback',...
                        ['global w_main_win drag_move;drag_move=1;pez(''info_edsel'');set(w_main_win,''Pointer'',''Crosshair'');',...
                         'set(w_main_win,''WindowButtonDownFcn'',''pez_bin(''''movedown'''');'');',...
                         'set(w_main_win,''WindowButtonUpFcn'',''pez_bin(''''moveup'''');''); ']      );
 
  % Drag By Mouse Real Time Plots
  uicontrol('style','push','units','norm', ...
                        'backgroundcolor',labelcolor,...
                        'foregroundcolor',[0 0 0],...
                        'string','Drag & Draw Plots',...
                        'pos',[.76 .67 .18 .045 ],...
                        'callback',...
                        ['global w_main_win drag_move;drag_move=1;pez(''info_edsel'');set(w_main_win,''Pointer'',''Crosshair'');',...
                         'set(w_main_win,''WindowButtonDownFcn'',''pez_bin(''''move_down_real'''');'');',...
                         'set(w_main_win,''WindowButtonUpFcn'',''pez_bin(''''moveup'''');''); ']      );

  % Point To Point
  uicontrol('style','push','units','norm', ...
                        'backgroundcolor',labelcolor,...
                        'foregroundcolor',[0 0 0],...
                        'string','Point to Point',...
                        'pos',[.76 .58 .18 .045 ],...
                        'callback','pez_bin(''point2point'');');
       
      
  % Edit by Co-Ord   
  ed_coord=uicontrol('style','push','units','norm', ...
                        'backgroundcolor',labelcolor,...
                        'foregroundcolor',[0 0 0],...
                        'string','Edit By Co-Ord',...
                        'pos',[.76 .49 .18 .045 ]);
                        

%^^^^^^^^^^^^ DELETE ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                          
  % Set up a frame for Delete buttons
  uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',framecolor,'pos', [ .73 .27 .24 .14]);
 
  % Set up a frame for Delete Title
  uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',framecolor,'pos', [ .73 .41  .24 .05]);
 
  % Set up Add Title Text
  uicontrol(w_main_win,'style','text','units','norm','pos', [ .76 .415 .18 .04],...
                       'backgroundcolor',framecolor,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','center','string','Delete Poles & Zeros');
          
  % Select & Delete
  uicontrol('style','push','units','norm', ...
                       'backgroundcolor',labelcolor,...
                       'foregroundcolor',[0 0 0],...
                       'string','Select & Delete Weighted',...
                       'pos',[.735 .34 .23 .04],'callback',...
                       'pez_bin(''dels'');');
 
  % Select & Delete Multiple
  uicontrol('style','push','units','norm', ...
                       'backgroundcolor',labelcolor,...
                       'foregroundcolor',[0 0 0],...
                       'string','Select & Delete Multiple',...
                       'pos',[.735 .29 .23 .04 ],'callback',...
                       'pez_bin(''delm'');');
 

%**************************************************************************************************
  
  % Set up a frame for Edit options
  ed_1 = uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',framecolor,'pos', [ .47 .23 .52 .68],'visible','off');
  ed_2 = uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',framecolor,'pos', [ .54 .25 .37 .56],'visible','off');
  ed_3 = uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',framecolor,'pos', [ .54 .81 .37 .09],'visible','off');

  ed_4=uicontrol('style','text','units','norm','pos', [.55 .83 .35 .04], ...
           'backgroundcolor',framecolor,...
           'foregroundcolor',[1 1 1],...
           'horizontalalignment','center','string','Edit a Pole or Zero by Coordinate','visible','off');

  % Edit Select
  ed_5=uicontrol('style','push','units','norm','backgroundcolor',labelcolor,...
                       'foregroundcolor',[0 0 0],'string','Select a Pole or Zero',...
                       'pos',[.59 .684 .27 .036 ],'call','pez_bin(''edit_select'');','visible','off');
                       

  % Set up CoOrdinate boxes
  ed_6=uicontrol('style','text','units','norm','pos', [.59 .612 .27 .036], ...
           'backgroundcolor',framecolor,...
           'foregroundcolor',[1 1 1],...
           'horizontalalignment','center','string','Cartesian Coordinates','visible','off');

  ed_7=uicontrol('style','text','units','norm','pos', [.59 .558 .06 .036], ...
           'backgroundcolor',framecolor,...
           'foregroundcolor',[1 1 1],...
           'horizontalalignment','left','string','Real:','visible','off');

  ed_real = uicontrol('style','edit','units','norm','pos', [.65 .558 .07 .036], ...
           'string', num2str(0), 'val', 0,'visible','off');
                  

%^^^^^^^^^^^^^^ IMAGINARY ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  ed_8=uicontrol('style','text','units','norm','pos', [.73 .558 .06 .036], ...
           'backgroundcolor',framecolor,...
           'foregroundcolor',[1 1 1],...
           'horizontalalignment','left','string','Imag:','visible','off');

  ed_imag = uicontrol('style','edit','units','norm','pos', [.79 .558 .07 .036],...
           'string', num2str(0), 'val', 0,'visible','off');



%^^^^^^^^^^^^^^ MAGNITUDE ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
               
  ed_9=uicontrol('style','text','units','norm','pos', [.59 .441 .27 .036], ...
           'backgroundcolor',framecolor,...
           'foregroundcolor',[1 1 1],...
           'horizontalalignment','center','string','Polar Coordinates','visible','off');
 
  ed_10=uicontrol('style','text','units','norm','pos', [.59 .387 .06 .036], ...
           'backgroundcolor',framecolor,...
           'foregroundcolor',[1 1 1],...
           'horizontalalignment','left','string','Mag:','visible','off');

  ed_mag = uicontrol('style','edit','units','norm','pos', [.65 .387 .07 .036],...
           'string', num2str(0), 'val', 0,'visible','off');
  
                              

%^^^^^^^^^^^^^^ ANGLE ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  ed_11=uicontrol('style','text','units','norm','pos', [.73 .387 .06 .036], ...
          'backgroundcolor',framecolor,...
          'foregroundcolor',[1 1 1],...
          'horizontalalignment','left','string','Angle:','visible','off');
          
  ed_angle = uicontrol('style','edit','units','norm','pos', [.79 .387 .07 .036], ...
          'string', num2str(0), 'val', 0,'visible','off');

  % Make Current Change
  ed_change=uicontrol('style','push','units','norm', ...
                       'backgroundcolor',labelcolor,...
                       'foregroundcolor',[0 0 0],...
                       'string','Make Current Change',...
                       'pos',[.59 .32 .27 .04 ],'visible','off','call','pez_bin(''edit_final'')');

  % Done Editing
  ed_12=uicontrol('style','push','units','norm', ...
                       'backgroundcolor',labelcolor,...
                       'foregroundcolor',[0 0 0],...
                       'string','Done Editing',...
                       'pos',[.59 .27 .27 .04 ],'visible','off');

% Now set up the calls so we can turn on/off the edit commands
  
  set(ed_12,'call',['set(',num2str(ed_1,32),',''visible'',''off'');',...
                    'set(',num2str(ed_2,32),',''visible'',''off'');',...
                    'set(',num2str(ed_3,32),',''visible'',''off'');',...
                    'set(',num2str(ed_4,32),',''visible'',''off'');',...
                    'set(',num2str(ed_5,32),',''visible'',''off'');',...
                    'set(',num2str(ed_6,32),',''visible'',''off'');',...
                    'set(',num2str(ed_7,32),',''visible'',''off'');',...
                    'set(',num2str(ed_8,32),',''visible'',''off'');',...
                    'set(',num2str(ed_9,32),',''visible'',''off'');',...
                    'set(',num2str(ed_10,32),',''visible'',''off'');',...
                    'set(',num2str(ed_11,32),',''visible'',''off'');',...
                    'set(',num2str(ed_12,32),',''visible'',''off'');',...
                    'set(',num2str(ed_change,32),',''visible'',''off'');',...
                    'set(',num2str(ed_real,32),',''visible'',''off'');',...
                    'set(',num2str(ed_real,32),',''call'',   '' '');',...
                    'set(',num2str(ed_imag,32),',''visible'',''off'');',...
                    'set(',num2str(ed_imag,32),',''call'',   '' '');',...
                    'set(',num2str(ed_mag,32),',''visible'',''off'');',...
                    'set(',num2str(ed_mag,32),',''call'',    '' '');',...
                    'set(',num2str(ed_angle,32),',''visible'',''off'');',...
                    'set(',num2str(ed_angle,32),',''call'',   '' '');',...
                    'pez(''restore_text'');']);
 
  set(ed_coord,'call',['set(',num2str(ed_1,32),',''visible'',''on'');',...
                    'set(',num2str(ed_2,32),',''visible'',''on'');',...
                    'set(',num2str(ed_3,32),',''visible'',''on'');',...
                    'set(',num2str(ed_4,32),',''visible'',''on'');',...
                    'set(',num2str(ed_5,32),',''visible'',''on'');',...
                    'set(',num2str(ed_6,32),',''visible'',''on'');',...
                    'set(',num2str(ed_7,32),',''visible'',''on'');',...
                    'set(',num2str(ed_8,32),',''visible'',''on'');',...
                    'set(',num2str(ed_9,32),',''visible'',''on'');',...
                    'set(',num2str(ed_10,32),',''visible'',''on'');',...
                    'set(',num2str(ed_11,32),',''visible'',''on'');',...
                    'set(',num2str(ed_12,32),',''visible'',''on'');',...
                    'set(',num2str(ed_real,32),',''visible'',''on'');',...
                    'set(',num2str(ed_imag,32),',''visible'',''on'');',...
                    'set(',num2str(ed_mag,32),',''visible'',''on'');',...
                    'set(',num2str(ed_angle,32),',''visible'',''on'');',...
                    'pez(''info_edco'');']);
 

% ----- Done Setting Up, Resize everything --------------------------------------------
 
  
  % Done drawing, now restore the pointer and window
  set(w_main_win,'Pointer','arrow','visible','on');

%------------ Load --------------------------------------------------------------------
elseif ( strcmp(action,'load') )

  [fn,pth] = uigetfile('*.mat','Load Data');

  if fn
  
    % First clear out old data
    pez_bin('kill_poles');pez_bin('kill_zeros');
    
    eval(['load ',pth,fn,';']);
  
    hold on;

    axes(axes_zplane);
            
    for t_count=1:num_diff_poles
    
       p_list( t_count,3) = plot( p_list(t_count,1), p_list(t_count,2), 'x');
       if ( p_list( t_count, 4 ) > 1 )
          pez_fuz=2*z_axis/80;
          p_list( t_count, 5 ) = text(p_list(t_count,1)+pez_fuz,p_list(t_count,2)+pez_fuz,num2str(p_list(t_count,4)) );
       end,
       
    end,
    
    for t_count=1:num_diff_zeros

       z_list( t_count,3) = plot( z_list(t_count,1), z_list(t_count,2), 'o');
       if ( z_list( t_count, 4 ) > 1 ) 
          pez_fuz=2*z_axis/80;
          z_list( t_count, 5 ) = text(z_list(t_count,1)+pez_fuz,z_list(t_count,2)+pez_fuz,num2str(z_list(t_count,4)) );
       end,
    end,
    
    pez_bin('doplot');    

  end,


%------------ Save --------------------------------------------------------------------
elseif strcmp(action,'save')

 
    [fn,pth] = uiputfile('*.mat','Save Plots');
    
    if fn
      eval(['save ',pth,fn,' num_zeros num_diff_zeros z_list num_poles num_diff_poles p_list' ]);
    end,
  

%------------ Save Special ------------------------------------------------------------
elseif ( strcmp(action,'save_roots') | strcmp(action,'save_poly') )

 
    [fn,pth] = uiputfile('*.mat','Save Special');
    
    if fn

      if (num_diff_poles == 0 )      
         pole_root_list = 0;
         pole_poly_list = [];
      else 
         pole_root_list = p_list(:,1)+j*p_list(:,2);
         pole_root_list = pez_exp( pole_root_list,p_list(:,4) ); 
         pole_poly_list = poly(pole_root_list); 
      end;
        
      if (num_diff_zeros == 0 )
         zero_root_list = 0;
         zero_poly_list = [];
      else
         zero_root_list = z_list(:,1)+j*z_list(:,2);
         zero_root_list = pez_exp( zero_root_list,z_list(:,4) );  
         zero_poly_list = poly(zero_root_list);
      end;


     if strcmp(action,'save_roots')
        eval(['save ',pth,fn,' pole_root_list zero_root_list']);
     else   
        eval(['save ',pth,fn,' pole_poly_list zero_poly_list']);
     end,

  end,  


%------------ Exit --------------------------------------------------------------------
elseif strcmp(action,'exit')

 delete(w_main_win);

 if  any( get(0,'children') == id_plot )
    delete(id_plot);
 end,   

 clear ed_scale;clear sli_scale p_list;clear z_list;clear num_poles;clear num_zeros;clear z_axis;
 clear w_main_win;clear axes_zplane;clear place;clear num_diff_poles;clear num_diff_zeros;
 clear weight;clear ed_weight;clear sli_weight;clear new;clear mirror_x;clear mirror_y;clear del_weight;
 clear del_values;clear pz;clear precision;clear ed_real;clear ed_imag;clear ed_mag;clear ed_angle;
 clear fr_omega;clear id_plot;


%------------ New Plot Window -------------------------------------------------------
elseif strcmp(action,'new_plot_win')

  id_plot=figure('units','normal','pos',[0 .70 .35 .45],'numbertitle','off',...
                 'name','Pole-Zero Plots','visible','off');

  % Set up the Menu Box Frame
  uicontrol(id_plot, 'style','frame','units','norm','pos',[ .001 .92 .998 .08],'backgroundcolor',[.4 .4 .6] );

  uicontrol('Max',0 ,'Min',1 ,'Units','norm','back',[.5 .5 .8],'fore',[1 1 1],... 
                     'Pos',[ 0.01 0.93 0.31 0.06 ],... 
                     'Style','popupmenu','horizontalalign','left',...
                     'string','<Print...> |To Printer...|To PS File...|To EPS File...|To GIF File...',...
                     'call',['argv=get(gco,''val'');set(gco,''val'',1);',...
                             'if argv==2, print;',...
                             'elseif argv==3, pez(''print_ps'');',...
                             'elseif argv==4, pez(''print_eps'');',...
                             'elseif argv==5, pez(''print_gif''); end; ']);

  uicontrol('Max',0 ,'Min',1 ,'Units','norm','back',[.5 .5 .8],'fore',[1 1 1],... 
                     'Pos',[ 0.33 0.93 0.35 0.06],... 
                     'Style','popupmenu','horizontalalign','left',... 
                     'string','<Quick Size...>|Small|Regular|Large|Hide',...
                     'call',['argv=get(gco,''val'');set(gco,''val'',1);',...
                             'if argv==2, pez(''size2_small'');',...
                             'elseif argv==3, pez(''size2_regular'');',...
                             'elseif argv==4, pez(''size2_large'');',...
                             'elseif argv==5, pez(''hide_me'');end;']);


   uicontrol('style','checkbox','units','norm','back',[.5 .5 .8],'fore',[1 1 1],...
                  'Pos',[ 0.70 0.925 0.28 0.06],... 
                  'string','Mag in dB',...
                  'val',0,...
                  'call','global pez_log;pez_log=get(gco,''val'');pez_plot(0);');


   plot_ax(1)=axes('box','on','units','norm','pos',[0.07 0.54 0.35 0.3255]);
   set(plot_ax(1),'fontsize',9);
    title('Z-Plane');
    hold on;

   plot_ax(2)=axes('box','on','units','norm','pos',[0.62 0.54 0.35 0.3255]);
    set(plot_ax(2),'fontsize',9);
    title('Impulse Response');
    xlabel('time index n');ylabel('amplitude');
    hold on;

   plot_ax(3)=axes('box','on','units','norm','pos',[0.07 0.08 0.35 0.3255]);
    set(plot_ax(3),'fontsize',9);
    title('Magnitude of Frequency Response');
    xlabel('omega/pi');ylabel('amplitude');
    grid on;
    hold on;

   plot_ax(4)=axes('box','on','units','norm','pos',[0.62 0.08 0.35 0.3255]);
    set(plot_ax(4),'fontsize',9);
    title('Phase of Frequency Response');
    xlabel('omega/pi');ylabel('radians');
    hold on;
     
%------------ Print File ---------------------------------------------------------------
elseif  strcmp(action,'print_ps') 

   [fn,pth] = uiputfile('*.ps','Print to PS File');
   if fn
         eval(['print ',pth,fn]);
   end,

elseif  strcmp(action,'print_eps') 

   [fn,pth] = uiputfile('*.eps','Print to EPS File');
   if fn
         eval(['print -deps ',pth,fn]);
   end,

elseif  strcmp(action,'print_gif') 

  
   [fn,pth] = uiputfile('*.gif','Print to GIF File');
   if fn
         eval(['print -dgif8 ',pth,fn]);
   end,

%------------ Resize Figure ------------------------------------------------------------
elseif  (strcmp(action,'size_supersmall') | strcmp(action,'size_small') | strcmp(action,'size_regular') )

   if strcmp(action,'size_regular')
         x_size=800; y_size=465;
   elseif  strcmp(action,'size_small')
         x_size=600; y_size=350; 
   else
         x_size=400; y_size=232;
   end;
   
   the_old_position = get(gcf,'pos');
   the_old_position(3)=x_size;
   the_old_position(4)=y_size;
   
   set(gcf,'pos',the_old_position);

elseif  (strcmp(action,'size2_small') | strcmp(action,'size2_regular') | strcmp(action,'size2_large') )

   if strcmp(action,'size2_small')
         x_size=.20;
         y_size=.25;
   elseif  strcmp(action,'size2_regular')
         x_size=.35;
         y_size=.45; 
   else
         x_size=.70;
         y_size=.90;
   end;
  
   set(gcf,'units','norm');
   the_old_position = get(gcf,'pos');
   the_old_position(3:4)=[x_size y_size];
  
   
   set(gcf,'pos',the_old_position);

%---------
elseif  strcmp(action,'hide_me')

   set(gcf,'visible','off');            
%---------
elseif  strcmp(action,'restore_text')

 set(ui_text_line1,'horizontalalignment','center','string','Welcome to PEZ 2.8: The Pole Zero Editor');
 set(ui_text_line2,'horizontalalignment','center','string','EE 2200');
 set(ui_text_line3,'horizontalalignment','center','string','Georgia Institute of Technology');
 set(ui_text_line4,'horizontalalignment','center','string','Comments: Grimace@ee.gatech.edu');

%---------
elseif  strcmp(action,'hit_info')

 set(ui_text_line1,'horizontalalignment','center','string','PEZ by Craig Ulmer  :[ GRiMACE@ee.gatech.edu ]:');
 set(ui_text_line2,'horizontalalignment','center','string','~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
 set(ui_text_line3,'horizontalalignment','center','string','No Modifications/Sales without Author''s Consent');
 set(ui_text_line4,'horizontalalignment','center','string','"People who make Generalizations are wrong"');

%---------
elseif  strcmp(action,'info_edco')

 set(ui_text_line1,'horizontalalignment','center','string','Edit by Coordinate');
 set(ui_text_line2,'horizontalalignment','center','string',  'Press the ''Select a Pole or Zero'' button to choose ');
 set(ui_text_line3,'horizontalalignment','center','string',  'an object to edit.');
 set(ui_text_line4,'horizontalalignment','center','string',  'Press ''Done Editing'' to return to the Main Menu.');

%---------
elseif  strcmp(action,'info_edsel')

 set(ui_text_line1,'horizontalalignment','center','string','Select an Object to Edit');
 set(ui_text_line2,'horizontalalignment','center','string',  'Click on a Pole or Zero to edit with the mouse.');
 set(ui_text_line3,'horizontalalignment','left','string',  '');
 set(ui_text_line4,'horizontalalignment','center','string',  'To abort, click outside of the Z-Plane axis.');

%---------
elseif  strcmp(action,'info_edch')

 set(ui_text_line1,'horizontalalignment','center','string','Edit an Object');
 set(ui_text_line2,'horizontalalignment','left','string',  'Now change the CoOrdinates of the object by changing');
 set(ui_text_line3,'horizontalalignment','left','string',  'the values in the edit boxes. Click ''Make Current Change'' ');
 set(ui_text_line4,'horizontalalignment','left','string',  'to finalize.                  To abort, click ''Done Editing''. ');

%---------
elseif  strcmp(action,'info_move')

 set(ui_text_line1,'horizontalalignment','center','string','Move Selected Object');
 set(ui_text_line2,'horizontalalignment','left','string',  'Now drag the object around the Z-Plane by moving the');
 set(ui_text_line3,'horizontalalignment','left','string',  'mouse.  When done, release the mouse button to finalize');
 set(ui_text_line4,'horizontalalignment','left','string',  '(and possibly click again if sticky). ');
 
%---------                  
else

  % Disable button until finished drawing
  %set(hlpHndl,'Enable','off');

  % Enable all of the buttons
  %set([contHndl spinHndl hlpHndl],'Enable','on');

  % Done drawing, now restore the pointer
  %set(w_main_win,'Pointer','arrow');


end;
