function pez(action,p_val,p_val2)
%PeZ v3.1beta: A Pole-Zero Editor for MATLAB by Craig Ulmer / GRiMACE@ee.gatech.edu
%No Modifications without the author's consent. See documentation for Legals.
%
%  See online help at:  http://www.ece.gatech.edu/users/grimace/pez/index.html
%
%Short: PeZ allows a user to graphically edit the poles and zeros for a
%filter in the complex Z-Plane. To run, boot up MATLAB and type  pez.
% Last Revision: 9/22/97

%The following are for differences between v4 and v5
global mat_version aspect_ratio_name fixed_aspect;

global ed_scale sli_scale p_list z_list num_poles num_zeros z_axis w_main_win axes_zplane place num_diff_poles num_diff_zeros
global weight ed_weight sli_weight mirror_x mirror_y del_weight del_values pez_precision ed_real ed_imag ed_mag ed_angle
global fr_omega id_plot ui_text_line1 ui_text_line2 ui_text_line3 ui_text_line4 pez_fuz ed_change plot_ax pez_real_drag
global pez_gain pez_angle_type pez_gain_ed pez_gain_sli pez_file_name pez_groupdelay pez_log w_config
global pez_redraw_type pez_main_gids

if nargin<1,
     action='new';
end;     



% ================================
%  Handle the NEW event

if strcmp(action,'new'),

  %Figure out the matlab version and set up for changes------------------------
  mat_version=version;
  mat_version=str2num(mat_version(1));
  
  if(mat_version<5), 
      aspect_ratio_name='aspectRatio';        fixed_aspect=[1,1];
  else,
      aspect_ratio_name='PlotBoxAspectRatio'; fixed_aspect=[1,1,1];
  end;                                   

  %The lame macs won't do an xor right. go figure
  if(strcmp(computer,'MAC2') )
      pez_redraw_type='normal';
  else
      pez_redraw_type='xor';
  end;

  %-----------------------------------------------------------------------------

  % Initialize variables
  c_label     =192/255*[1 1 1]; %Background color for buttons       -light
  c_frame     = [.50 .50 .50];  %Background color for button frames--dark
  c_menu      = [.40 .40 .60];  %Menu color(blue)
  c_info      = [.65 .40 .40];  %
  c_infofr    = [.60 .45 .45];  %
  c_frameback = [.65 .50 .50];  % Frame around buttons
  c_io_frame  = [.40 .40 .70];  %Button colors for io(blue)
  c_io_back   = [.30 .30 .50];  %Background color for io(dark blue)
  c_io_text   = [ 1   1   1 ];  %Label color for io text

 
  p_list=[];
  z_list=[];
  num_poles=0;
  num_diff_poles=0;
  num_zeros=0;
  num_diff_zeros=0;

  z_axis=2;

  weight=1;
  del_values=0;
  pez_fuz=2*z_axis/80;
  pez_gain=1;

   
  % Open up main control window
  w_main_win=figure('resize','on','units','pixels',...
                  'Pointer','watch',... 
                  'pos',[400 0 800 465],...
                  'numbertitle','off','name','PEZ v3.1 : Pole-Zero Control Window',...
                  'visible','off');
  
  pez_conf('load_default');
    
  figure(w_main_win);
                  
  %^^^^^^^^^^^^ Menu Ops ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  

  % Set up the Menu Box Frame
  uicontrol(w_main_win, 'style','frame','units','norm','pos',[ .001 .93 .998 .070],'backgroundcolor',c_menu );

  um_file=uicontrol('Units','norm','back',[.5 .5 .8],'fore',[1 1 1],... 
                     'Pos',[ 0.01 0.945 0.14 0.05 ],... 
                     'Style','popupmenu','horizontalalign','left',... 
                     'string','<File...> |Import...|Export...|Config...|PeZ Info...|Exit');

  um_clear=uicontrol('Max',0 ,'Min',1 ,'Units','norm','back',[.5 .5 .8],'fore',[1 1 1],... 
                     'Pos',[ 0.155 0.945 0.14 0.05 ],... 
                     'Style','popupmenu','horizontalalign','left',... 
                     'string','<Clear...>|Poles|Zeros|All ');

  um_size=uicontrol('Max',0 ,'Min',1 ,'Units','norm','back',[.5 .5 .8],'fore',[1 1 1],... 
                     'Pos',[ 0.30 0.945 0.14 0.05 ],... 
                     'Style','popupmenu','horizontalalign','left',... 
                     'string','<Quicksize...>|Tiny|Small|Regular|---------|Redo Plots');

  %Note: Setting file options done at end of setup, due to import/export

  set(um_clear,'call',['argv=get(gco,''val'');set(gco,''val'',1);',...
                      'if argv==2, pez_bin(''kill_poles'');pez_plot(0);',...
                      'elseif argv==3, pez_bin(''kill_zeros'');pez_plot(0);',...
                      'elseif argv==4, pez_bin(''kill_zeros'');pez_bin(''kill_poles'');pez_plot(0); end;',...
                      'global axes_zplane;axes(axes_zplane);refresh;']);

  set(um_size,'call',['argv=get(gco,''val'');set(gco,''val'',1);',...
                      'if argv==2, pez(''size_supersmall'');',...
                      'elseif argv==3, pez(''size_small'');',...
                      'elseif argv==4, pez(''size_regular'');',...
                      'elseif argv==6, pez_plot(0); end;']);

                     
  % Set up the Z-Plane plot Axes
  axes_zplane=axes(aspect_ratio_name,fixed_aspect,'units','norm','pos',[.06 .198 .38 .67],...
                   'drawmode','fast','color','black');
  
  axis(axis);
  set(gca,'box','on');
  
  hold on;
  
  theta = linspace(0,2*pi,70);
  plot(cos(theta),sin(theta),':y',[-10; 10],[0;0],':y',[0;0],[-10; 10],':y');

  axis([-z_axis z_axis -z_axis z_axis]);
  title('Z-Plane');
  xlabel('Real part')
  ylabel('Imaginary part')

  % Set up the Info Box Frame
  uicontrol(w_main_win, 'style','frame','units','norm','pos',[ .47 .0 .52 .211],'backgroundcolor',c_infofr );

  % Set up Info Box Welcome Text
  ui_text_line1 = uicontrol(w_main_win,'style','text','units','norm','pos', [ .49 .147 .48 .048],...
                       'backgroundcolor',c_info,...
                       'foregroundcolor','white');
 
  % Set up Info Box Welcome Text
  ui_text_line2 = uicontrol(w_main_win,'style','text','units','norm','pos', [ .49 .099 .48 .048],...
                       'backgroundcolor',c_info,...
                       'foregroundcolor','white');
 
  % Set up Info Box Welcome Text
  ui_text_line3 = uicontrol(w_main_win,'style','text','units','norm','pos', [ .49 .051 .48 .048],...
                       'backgroundcolor',c_info,...
                       'foregroundcolor','white');

  % Set up Info Box Welcome Text
  ui_text_line4 = uicontrol(w_main_win,'style','text','units','norm','pos', [ .49 .01 .48 .048],...
                       'backgroundcolor',c_info,...
                       'foregroundcolor','white');
   
  pez('restore_text');                     

  % -/- Z-Plane Scaler -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-

  uicontrol('style','frame','units','norm','pos',[.13 .01 .23 .12],'backgroundcolor',c_frame); 

  uicontrol('style','text','units','norm',...
          'pos', [.15 .065 .16 .05], 'backgroundcolor',c_frame,'foregroundcolor',c_io_text,...
          'horizontalalignment','left','string','Z-Plane Axis:');

  % Scale Entry Box
  ed_scale = uicontrol('style','edit','units','norm','pos', [.28 .065 .05 .05],...
                   'horizontalalignment','left',...
                   'string', num2str(z_axis), 'val', z_axis,...
                   'call', 'pez_bin(''rzaxis'',0); ');
          
  % Scale Slider
  sli_scale = uicontrol(w_main_win,'Style','slider','Min',.5,'Max',10,'val',z_axis,...
                      'units','norm','pos',[ .15 .025 .18 .036],...
                      'CallBack','pez_bin(''rzaxis'',1 );' );

  %Realtime drag Checkbox 
  uicontrol('style','checkbox','units','normal','string','Real Time Drag Plots', ...
                         'pos',[0.00 0.88 0.20 0.05],'val',pez_real_drag,...
                         'fore','cyan','back','black',...
                         'call','global pez_real_drag;pez_real_drag=get(gco,''val'');');
 

  %-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
  PP=[]; %This is short hand for a list of handles used to reset the main buttons

  % -/- Add Options -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
  % Set Up big frame
  uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',c_frameback,'pos', [ .47 .23 .52 .68]);
  
  % Set up a frame for Weight
  uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',c_frame,'pos', [ .50 .27 .22 .10]);

  % Set up a frame for Add buttons
  uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',c_frame,'pos', [ .50 .38 .22 .45]);

  % Set up a frame for Add Title
  uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',c_frame,'pos', [ .50 .82 .22 .05]);
  
  % Set up Add Title Text
  p=uicontrol(w_main_win,'style','text','units','norm','pos', [ .51 .825 .20 .04],...
                       'backgroundcolor',c_frame,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','center','string','Add Poles & Zeros');

  PP=[PP p]; %Add to list of labels;
  
  % Set up text for Add Single

  p=uicontrol(w_main_win,'style','text','units','norm','pos', [ .51 .77 .20 .04],...
                       'backgroundcolor',c_frame,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','center','string','Add One-At-A-Time');

  PP=[PP p]; %Add to list of labels;

  p=uicontrol('style','push','units','norm', ...
                        'backgroundcolor',c_label,...
                        'foregroundcolor',[0 0 0],...
                        'string','Pole',...
                        'pos',[.515 .72 .095 .045 ],...
                        'callback','pez_bin(''addsp'');');

  PP=[PP p]; %Add to list of labels;

  p=uicontrol('style','push','units','norm', ...
                        'backgroundcolor',c_label,...
                        'foregroundcolor',[0 0 0],...
                        'string','Zero',...
                        'pos',[.615 .72 .095 .045 ],...
                        'callback','pez_bin(''addsz'');');

  PP=[PP p]; %Add to list of labels;

  
 % Set up text for Add Multiple

  p=uicontrol(w_main_win,'style','text','units','norm','pos', [ .51 .64 .20 .04],...
                       'backgroundcolor',c_frame,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','center','string','Add Multiple');

  PP=[PP p]; %Add to list of labels;

  p=uicontrol('style','push','units','norm', ...
                        'backgroundcolor',c_label,...
                        'foregroundcolor',[0 0 0],...
                        'string','Poles',...
                        'pos',[.515 .59 .095 .045 ],...
                        'callback','pez_bin(''addmp'');' );

  PP=[PP p]; %Add to list of labels;

  
  p=uicontrol('style','push','units','norm', ...
                        'backgroundcolor',c_label,...
                        'foregroundcolor',[0 0 0],...
                        'string','Zeros',...
                        'pos',[.615 .59 .095 .045 ],...
                        'callback','pez_bin(''addmz'');' );

  PP=[PP p]; %Add to list of labels;

% Set up text for Add Double

  p=uicontrol(w_main_win,'style','text','units','norm','pos', [ .51 .51 .20 .04],...
                       'backgroundcolor',c_frame,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','center','string','Add Double');

  PP=[PP p]; %Add to list of labels;

  p=uicontrol('style','push','units','norm', ...
                        'backgroundcolor',c_label,...
                        'foregroundcolor',[0 0 0],...
                        'string','Poles',...
                        'pos',[.51 .46 .095 .045 ],...
                        'callback','pez_bin(''adddp'');');
  
  PP=[PP p]; %Add to list of labels;

  p=uicontrol('style','push','units','norm', ...
                        'backgroundcolor',c_label,...
                        'foregroundcolor',[0 0 0],...
                        'string','Zeros',...
                        'pos',[.615 .46 .095 .045 ],...
                        'callback','pez_bin(''adddz'');');

  PP=[PP p]; %Add to list of labels;

  % Pole / Zero Combo
  p=uicontrol('style','push','units','norm', ...
                        'backgroundcolor',c_label,...
                        'foregroundcolor',[0 0 0],...
                        'string','Pole / Zero Combo',...
                        'pos',[ .51 .41 .20 .045 ],...
                        'callback','pez_bin(''adddpz''); ');

  PP=[PP p]; %Add to list of labels;
 
  % Set up text for Weight

  p=uicontrol(w_main_win,'style','text','units','norm','pos', [ .51 .325 .14 .04],...
                       'backgroundcolor',c_frame,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','left','string','Multiplicity:');
  PP=[PP p]; %Add to list of labels;

  % Weight Entry Box
  ed_weight = uicontrol('style','edit','units','norm','pos', [.65 .325 .06 .04],...
                   'horizontalalignment','left',...
                   'string', num2str(weight), 'val', weight,...
                   'call', 'pez_bin(''rweight'',0); ');

  PP=[PP ed_weight]; %Add to list of labels;
          
  % Weight Slider
  sli_weight = uicontrol(w_main_win,'Style','slider','Min',1,'Max',50,'val',weight,...
                      'units','norm','pos',[ .51 .28 .20 .036],...
                      'CallBack','pez_bin(''rweight'',1);' );

  PP=[PP sli_weight]; %Add to list of labels;

 % ------------------------
 % Set up a frame for Move buttons
  uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',c_frame,'pos', [.73 .47 .24 .36]);
   
  % Set up a frame for Move Title
  uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',c_frame,'pos', [ .73 .82 .24 .05]);
 
  % Set up Edit Title Text
  p=uicontrol(w_main_win,'style','text','units','norm','pos', [ .76 .825 .18 .04],...
                       'backgroundcolor',c_frame,'foregroundcolor',[1 1 1],...
                       'horizontalalignment','center','string','Edit Filter');

  PP=[PP p]; %Add to list of labels;

  % Set up a frame for Filter Gain
  uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',c_frame,'pos', [ .73 .61 .24 .12]);

      
  % Edit by Co-Ord   
  ed_coord=uicontrol('style','push','units','norm', 'backgroundcolor',c_label,'foregroundcolor',[0 0 0],...
                        'string','Edit By Co-Ord','pos',[.76 .75 .18 .045 ]);

  PP=[PP ed_coord]; %Add to list of labels;
                        
                        
  %-------GAIN ----------
  % Set up text for GAIN

  p=uicontrol(w_main_win,'style','text','units','norm','pos', [ .76 .68 .14 .04],...
                       'backgroundcolor',c_frame,'foregroundcolor',[1 1 1],...
                       'horizontalalignment','left','string','Filter Gain:');

  PP=[PP p]; %Add to list of labels;

  % Gain Entry Box
  pez_gain_ed = uicontrol('style','edit','units','norm','pos', [.88 .68 .06 .04],...
                   'horizontalalignment','left',...
                   'string', num2str(pez_gain), 'val', pez_gain,...
                   'call', 'pez_bin(''rgain'',0); ');

  PP=[PP pez_gain_ed]; %Add to list of labels;
          
  % Gain Slider
  pez_gain_sli = uicontrol(w_main_win,'Style','slider','Min',0,'Max',30,'val',pez_gain,...
                      'units','norm','pos',[ .76 .63 .18 .03],...
                      'CallBack','pez_bin(''rgain'',1);' );
  PP=[PP pez_gain_sli]; %Add to list of labels;

  %Import/Export Buttons  
  ie_import=uicontrol('style','push','units','norm', 'back',c_label,...
                    'fore',[0 0 0],'string','Import Filter Data','pos',[.76 .55 .18 .04 ]);

  PP=[PP ie_import]; %Add to list of labels;


  ie_export=uicontrol('style','push','units','norm', 'backgroundcolor',c_label,...
                     'foregroundcolor',[0 0 0],'string','Export Filter Data','pos',[.76 .50 .18 .04 ]);

  PP=[PP ie_export]; %Add to list of labels;


%^^^^^^^^^^^^ DELETE ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                          
  % Set up a frame for Delete buttons
  uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',c_frame,'pos', [ .73 .27 .24 .14]);
 
  % Set up a frame for Delete Title
  uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',c_frame,'pos', [ .73 .41  .24 .05]);
 
  % Set up Add Title Text
  p=uicontrol(w_main_win,'style','text','units','norm','pos', [ .76 .415 .18 .04],...
                       'backgroundcolor',c_frame,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','center','string','Delete Poles & Zeros');
    
  PP=[PP p]; %Add to list of labels;
      
  % Select & Delete
  p=uicontrol('style','push','units','norm', ...
                       'backgroundcolor',c_label,...
                       'foregroundcolor',[0 0 0],...
                       'string','Select & Delete',...
                       'pos',[.735 .34 .23 .04],'callback',...
                       'pez_bin(''dels'');');
 
  PP=[PP p]; %Add to list of labels;

  % Select & Delete Multiple
  p=uicontrol('style','push','units','norm', ...
                       'backgroundcolor',c_label,...
                       'foregroundcolor',[0 0 0],...
                       'string','Select & Delete Multiple',...
                       'pos',[.735 .29 .23 .04 ],'callback',...
                       'pez_bin(''delm'');');
 
  PP=[PP p]; %Add to list of labels;


%**************************************************************************************************
  
  % Set up a frame for Edit options
  ed_1 = uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',c_frame,'pos', [ .47 .23 .52 .68],'visible','off');
  ed_2 = uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',c_frame,'pos', [ .50 .25 .46 .56],'visible','off');
  ed_3 = uicontrol(w_main_win, 'style','frame','units','norm','backgroundcolor',c_frame,'pos', [ .50 .81 .46 .09],'visible','off');

  ed_4=uicontrol('style','text','units','norm','pos', [.55 .83 .35 .04], ...
           'back',c_frame,'fore',[1 1 1],'horizontal','center','string','Edit a Pole or Zero by Coordinate','visible','off');

  % Edit Select
  ed_5=uicontrol('style','push','units','norm','backgroundcolor',c_label,...
                       'foregroundcolor',[0 0 0],'string','Select a Pole or Zero',...
                       'pos',[.59 .70 .27 .05 ],'call','pez_bin(''edit_select'');','visible','off');
                       

  % Set up CoOrdinate boxes
  ed_6=uicontrol('style','text','units','norm','pos', [.59 .612 .27 .036], ...
           'backgroundcolor',c_frame,'foregroundcolor',[1 1 1],...
           'horizontalalignment','center','string','Cartesian Coordinates','visible','off');

  ed_7=uicontrol('style','text','units','norm','pos', [.59 .558 .06 .04], ...
           'backgroundcolor',c_frame,...
           'foregroundcolor',[1 1 1],...
           'horizontalalignment','left','string','Real:','visible','off');

  ed_real = uicontrol('style','edit','units','norm','pos', [.65 .558 .07 .05], ...
           'horizontalalignment','left','string', num2str(0), 'val', 0,'visible','off');
                  

%^^^^^^^^^^^^^^ IMAGINARY ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  ed_8=uicontrol('style','text','units','norm','pos', [.73 .558 .06 .04], ...
           'backgroundcolor',c_frame,...
           'foregroundcolor',[1 1 1],...
           'horizontalalignment','left','string','Imag:','visible','off');

  ed_imag = uicontrol('style','edit','units','norm','pos', [.79 .558 .07 .05],...
           'horizontalalignment','left','string', num2str(0), 'val', 0,'visible','off');



%^^^^^^^^^^^^^^ MAGNITUDE ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
               
  ed_9=uicontrol('style','text','units','norm','pos', [.59 .441 .27 .04], ...
           'backgroundcolor',c_frame,...
           'foregroundcolor',[1 1 1],...
           'horizontalalignment','center','string','Polar Coordinates','visible','off');
 
  ed_10=uicontrol('style','text','units','norm','pos', [.59 .387 .06 .04], ...
           'backgroundcolor',c_frame,...
           'foregroundcolor',[1 1 1],...
           'horizontalalignment','left','string','Mag:','visible','off');

  ed_mag = uicontrol('style','edit','units','norm','pos', [.65 .387 .07 .05],...
           'horizontalalignment','left','string', num2str(0), 'val', 0,'visible','off');
  
                              

%^^^^^^^^^^^^^^ ANGLE ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  ed_11=uicontrol('style','text','units','norm','pos', [.73 .387 .06 .04], ...
          'backgroundcolor',c_frame,...
          'foregroundcolor',[1 1 1],...
          'horizontalalignment','left','string','Angle:','visible','off');
          
  ed_angle = uicontrol('style','edit','units','norm','pos', [.79 .387 .07 .05], ...
          'horizontalalignment','left','string', num2str(0), 'val', 0,'visible','off');

  % Make Current Change
  ed_change=uicontrol('style','push','units','norm', ...
                       'backgroundcolor',c_label,...
                       'foregroundcolor',[0 0 0],...
                       'string','Make Current Change',...
                       'pos',[.59 .32 .27 .05 ],'visible','off','call','pez_bin(''edit_final'')');

  % Done Editing
  ed_12=uicontrol('style','push','units','norm', ...
                       'backgroundcolor',c_label,...
                       'foregroundcolor',[0 0 0],...
                       'string','Done Editing',...
                       'pos',[.59 .26 .27 .05 ],'visible','off');

  % Angle Type
  ed_13=uicontrol('Max',3 ,'Min',1 ,'style','popupmenu','units','norm', ...
                       'backgroundcolor',c_label,...
                       'foregroundcolor',[0 0 0],...
                       'string','rad/S|pi*rad/S|degrees',...
                       'val',pez_angle_type,...
                       'pos',[.86 .387 .10 .05 ],'visible','off',...
                       'call','pez_bin(''edit_angle_type'');');
  


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
                    'set(',num2str(ed_real,32),',  ''visible'',''off'',''call'',   '' '',''string'',''0'');',...
                    'set(',num2str(ed_imag,32),',  ''visible'',''off'',''call'',   '' '',''string'',''0'');',...
                    'set(',num2str(ed_mag,32),',   ''visible'',''off'',''call'',   '' '',''string'',''0'');',...
                    'set(',num2str(ed_angle,32),', ''visible'',''off'',''call'',   '' '',''string'',''0'');',...
                    'set(',num2str(ed_13,32),',''visible'',''off'');',...
                    'pez(''restore_text'');',...
                    'pez(''show_main'');' ]);
 
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
                    'set(',num2str(ed_13,32),',''visible'',''on'');',...
                    'pez(''info_edco'');']);
 



  %--############### IMPORT/EXPORT ###########################################################


    pez_file_name=['noname.mat'];
  
    ie_0=uicontrol(w_main_win,'style','frame','units','norm','backgroundcolor',c_io_back,'pos', [ .47 .23 .52 .68],'visible','off');

    ie_1=uicontrol('style','text','string','Import / Add Options','fore',c_io_text,'back',c_io_back,'horizontalalign','center',...
                   'units','norm','visible','off','pos',[.48 .85 .50 .05]);

    ie_2=uicontrol('style','push','string','File: <noname.mat>','fore',c_io_text,'back',c_io_frame,'horizontalalign','center','units','norm','visible','off',...
                  'pos',[0.725 0.76 0.23 0.05],'call','pez(''new_filename'',gco);');
                  
                  
    ie_3=uicontrol('max',2,'max',1,'style','popupmenu','units','normal', 'string','Add Below Values|Extract From File:|Use [B,A]=|Grab Filtdemo', ...
                   'pos',[0.50 0.76 0.22 0.05],'visible','off',...
                   'val',0,'fore',c_io_text,'back',c_io_frame   );
                           
    ie_4=uicontrol('style','text','units','norm','Horizontalalign','center','backgroundcolor',c_io_back,'foregroundcolor',c_io_text,...
                       'string','Save File Name','pos',[0.50 0.76 0.22 0.05 ],'visible','off');

    ie_5=uicontrol('style','text','string','Pole Values or Variable:','backgroundcolor',c_io_back,...
                        'foregroundcolor',c_io_text,'units','norm','pos',[.48 .64 .17 .05 ],'visible','off');
     
    ie_6=uicontrol('style','Edit','units','norm', 'Horizontalalign','left','backgroundcolor',c_io_frame,...
                       'foregroundcolor',c_io_text,'string','[ 1 ]','pos',[.65 .64 .25 .05 ],'visible','off');

    ie_7=uicontrol('Max',2 ,'Min',1 ,'style','popupmenu','units','norm','backgroundcolor',c_io_frame,'val',2,...
                       'foregroundcolor',c_io_text,'string','roots|poly','pos',[.90 .64 .07 .05 ],'visible','off');
     
    ie_8=uicontrol('style','text','string','Zero Values or Variable:','backgroundcolor',c_io_back,'foregroundcolor',c_io_text,...
                        'units','norm','pos',[.48 .55 .17 .05 ],'visible','off');

    ie_9=uicontrol('style','Edit','units','norm', 'Horizontalalign','left','backgroundcolor',c_io_frame,...
                       'foregroundcolor',c_io_text,'string','[ 1 ]','pos',[.65 .55 .25 .05 ],'visible','off');

    ie_10=uicontrol('Max',2 ,'Min',1 ,'style','popupmenu','units','norm', 'backgroundcolor',c_io_frame,'val',2,...
                       'foregroundcolor',c_io_text,'string','roots|poly','pos',[.90 .55 .07 .05 ],'visible','off');

    ie_11=uicontrol('style','text','string','Filter Gain:','fore',c_io_text,'back',c_io_back,...
                'horizontalalign','right','units','norm','visible','on','pos',[.70 .45 .20 .05],'visible','off');

    ie_12=uicontrol('style','Edit','units','norm', 'Horizontalalign','left','backgroundcolor',c_io_frame,...
                       'foregroundcolor',c_io_text,'string','1','pos',[.90 .45 .07 .05 ],'visible','off');

    ie_13=uicontrol('style','push','units','norm', 'Horizontalalign','center','backgroundcolor',c_io_frame,...
                       'foregroundcolor',c_io_text,'string','Import Using Above Values','pos',[.60 .35 .30 .05 ],'visible','off',...
                       'call', ['pval=[',num2str(ie_3,32),' ',...
                                         num2str(ie_6,32),' ',...
                                         num2str(ie_7,32),' ',...
                                         num2str(ie_9,32),' ',...
                                         num2str(ie_10,32),' ',...
                                         num2str(ie_12,32),' ];',...
                                'pez(''do_import'',pval);']);
                
    ie_14=uicontrol('style','push','units','norm', 'Horizontalalign','center','backgroundcolor',c_io_frame,...
                       'foregroundcolor',c_io_text,'string','Export to File','pos',[.60 .35 .30 .05 ],'visible','off',...
                       'call', ['pval=[',num2str(ie_6,32),' ',...
                                         num2str(ie_7,32),' ',...
                                         num2str(ie_9,32),' ',...
                                         num2str(ie_10,32), '];' ,...
                                'pez(''do_export'',pval);']);

    ie_15=uicontrol('style','push','units','norm', 'Horizontalalign','center','backgroundcolor',c_io_frame,...
                       'foregroundcolor',c_io_text,'string','Import From ''Filtdemo''','pos',[.60 .35 .30 .05 ],'visible','off',...
                       'call','pez(''get_filtdemo'')');

    ie_16=uicontrol('style','push','units','norm', 'Horizontalalign','center','backgroundcolor',c_io_frame,...
                       'foregroundcolor',c_io_text,'string','Return To Editing...','pos',[.60 .25 .30 .05 ],'visible','off');

    ie_17=uicontrol('style','push','units','norm', 'Horizontalalign','center','backgroundcolor',c_io_frame,...
                       'foregroundcolor',c_io_text,'string','Make Call','pos',[.60 .35 .30 .05 ],'visible','off');

    %-- Set Return To Main 
    set(ie_16,'call',[  'set(',num2str(ie_0,32),',''visible'',''off'');',...
                        'set(',num2str(ie_1,32),',''visible'',''off'');',...
                        'set(',num2str(ie_2,32),',''visible'',''off'');',...
                        'set(',num2str(ie_3,32),',''visible'',''off'');',...
                        'set(',num2str(ie_4,32),',''visible'',''off'');',...
                        'set(',num2str(ie_5,32),',''visible'',''off'');',...
                        'set(',num2str(ie_6,32),',''visible'',''off'');',...
                        'set(',num2str(ie_7,32),',''visible'',''off'');',...
                        'set(',num2str(ie_8,32),',''visible'',''off'');',...
                        'set(',num2str(ie_9,32),',''visible'',''off'');',...
                        'set(',num2str(ie_10,32),',''visible'',''off'');',...
                        'set(',num2str(ie_11,32),',''visible'',''off'');',...
                        'set(',num2str(ie_12,32),',''visible'',''off'');',...
                        'set(',num2str(ie_13,32),',''visible'',''off'');',...
                        'set(',num2str(ie_14,32),',''visible'',''off'');',...
                        'set(',num2str(ie_15,32),',''visible'',''off'');',...
                        'set(',num2str(ie_16,32),',''visible'',''off'');',...
                        'set(',num2str(ie_17,32),',''visible'',''off'');',...
                        'pez(''restore_text'');',...
                        'pez(''show_main'');' ]);

    import_select_call=[ 'if (get(gco,''val'')==1),',...
                           'set(',num2str(ie_2,32),',''visible'',''off'');',...
                           'set(',num2str(ie_4,32),',''visible'',''off'');',...
                           'set(',num2str(ie_5,32),',''visible'',''on'',''string'',''Pole Values:'');',...
                           'set(',num2str(ie_6,32),',''visible'',''on'',''string'',''[ 1 ]'');',...
                           'set(',num2str(ie_7,32),',''visible'',''on'');',...
                           'set(',num2str(ie_8,32),',''visible'',''on'',''string'',''Zero Values:'',''horiz'',''center'');',...
                           'set(',num2str(ie_9,32),',''visible'',''on'',''string'',''[ 1 ]'');',...
                           'set(',num2str(ie_10,32),',''visible'',''on'');',...
                           'set(',num2str(ie_11,32),',''visible'',''on'');',...
                           'set(',num2str(ie_12,32),',''visible'',''on'',''string'',''1'');',...
                           'set(',num2str(ie_13,32),',''visible'',''on'',''string'',''Add Values'');',...
                           'set(',num2str(ie_15,32),',''visible'',''off'');',...
                           'set(',num2str(ie_17,32),',''visible'',''off'');',...
                           'pez(''info_import_add'');',...
                         'elseif (get(gco,''val'')==2),',...                         
                           'set(',num2str(ie_2,32),',''visible'',''on'',''string'',''noname.mat'',''call'', ',...
                                          '  ''pez(''''new_filename'''',gco,0);'' );',... 
                           'set(',num2str(ie_4,32),',''visible'',''off'');',...
                           'set(',num2str(ie_5,32),',''visible'',''on'',''string'',''Pole Variable Name:'');',...
                           'set(',num2str(ie_6,32),',''visible'',''on'',''string'',''p_values'');',...
                           'set(',num2str(ie_7,32),',''visible'',''on'',''val'',2);',...
                           'set(',num2str(ie_8,32),',''visible'',''on'',''string'',''Zero Variable Name:'',''horiz'',''center'');',...
                           'set(',num2str(ie_9,32),',''visible'',''on'',''string'',''z_values'');',...
                           'set(',num2str(ie_10,32),',''visible'',''on'',''val'',2);',...
                           'set(',num2str(ie_11,32),',''visible'',''on'');',...
                           'set(',num2str(ie_12,32),',''visible'',''on'',''string'',''1'');',...
                           'set(',num2str(ie_13,32),',''visible'',''on'',''string'',''Load from File'');',...
                           'set(',num2str(ie_15,32),',''visible'',''off'');',...
                           'set(',num2str(ie_17,32),',''visible'',''off'');',...
                           'pez(''info_import_file'');',...
                         'elseif (get(gco,''val'')==3),',...                       
                           'set(',num2str(ie_2,32),',''visible'',''off'');',...
                           'set(',num2str(ie_4,32),',''visible'',''off'');',...
                           'set(',num2str(ie_5,32),',''visible'',''off'');',...
                           'set(',num2str(ie_6,32),',''visible'',''off'');',...
                           'set(',num2str(ie_7,32),',''visible'',''off'');',...
                           'set(',num2str(ie_8,32),',''visible'',''on'',''string'',''[B,A]='',''horiz'',''right'');',...
                           'set(',num2str(ie_9,32),',''visible'',''on'',''string'','' '');',...
                           'set(',num2str(ie_10,32),',''visible'',''off'');',...
                           'set(',num2str(ie_11,32),',''visible'',''off'');',...
                           'set(',num2str(ie_12,32),',''visible'',''off'');',...
                           'set(',num2str(ie_13,32),',''visible'',''off'');',...
                           'set(',num2str(ie_15,32),',''visible'',''off'');',...
                           'set(',num2str(ie_17,32),',''visible'',''on'');',...
                           'pez(''info_import_ba'');',...
                         'else, ',...                                                  
                           'set(',num2str(ie_2,32),',''visible'',''off'');',...
                           'set(',num2str(ie_4,32),',''visible'',''off'');',...
                           'set(',num2str(ie_5,32),',''visible'',''off'');',...
                           'set(',num2str(ie_6,32),',''visible'',''off'');',...
                           'set(',num2str(ie_7,32),',''visible'',''off'');',...
                           'set(',num2str(ie_8,32),',''visible'',''off'');',...
                           'set(',num2str(ie_9,32),',''visible'',''off'');',...
                           'set(',num2str(ie_10,32),',''visible'',''off'');',...
                           'set(',num2str(ie_11,32),',''visible'',''off'');',...
                           'set(',num2str(ie_12,32),',''visible'',''off'');',...
                           'set(',num2str(ie_13,32),',''visible'',''off'');',...
                           'set(',num2str(ie_15,32),',''visible'',''on'');',...
                           'set(',num2str(ie_17,32),',''visible'',''off'');',...
                           'pez(''info_import_filt'');',...
                         'end;' ];
                         

    import_call= ['pez(''hide_main'');',...
                          'set(',num2str(ie_0,32),',''visible'',''on'');',...
                          'set(',num2str(ie_1,32),',''visible'',''on'',''string'',''Import / Add Options'');',...
                          'set(',num2str(ie_3,32),',''visible'',''on'',''val'',1);',...
                          'set(',num2str(ie_5,32),',''visible'',''on'',''string'',''Pole Values:'');',...
                          'set(',num2str(ie_6,32),',''visible'',''on'',''string'',''[ 1 ]'');',...
                          'set(',num2str(ie_7,32),',''visible'',''on'');',...
                          'set(',num2str(ie_8,32),',''visible'',''on'',''string'',''Zero Values:'');',...
                          'set(',num2str(ie_9,32),',''visible'',''on'',''string'',''[ 1 ]'');',...
                          'set(',num2str(ie_10,32),',''visible'',''on'');',...
                          'set(',num2str(ie_11,32),',''visible'',''on'');',...
                          'set(',num2str(ie_12,32),',''visible'',''on'');',...
                          'set(',num2str(ie_13,32),',''visible'',''on'',''string'',''Add Values'');',...
                          'set(',num2str(ie_15,32),',''visible'',''off'');',...
                          'set(',num2str(ie_16,32),',''visible'',''on'');',...
                          'set(',num2str(ie_17,32),',''visible'',''off'');',...
                          'pez(''info_import_add'');'];

    export_call= ['pez(''hide_main'');',...
                          'set(',num2str(ie_0,32),',''visible'',''on'');',...
                          'set(',num2str(ie_1,32),',''visible'',''on'',''string'',''Export to File Options'');',...
                          'set(',num2str(ie_2,32),',''visible'',''on'',''string'',''noname.mat'',''call'', ',...
                                          '  ''pez(''''new_filename'''',gco,1);'' );',... 
                          'global pez_file_name;pez_file_name=''noname.mat'';',...
                          'set(',num2str(ie_4,32),',''visible'',''on'',''string'',''Save File Name:'');',...
                          'set(',num2str(ie_5,32),',''visible'',''on'',''string'',''Pole Variable Name'');',...
                          'set(',num2str(ie_6,32),',''visible'',''on'',''string'',''p_values'');',...
                          'set(',num2str(ie_7,32),',''visible'',''on'');',...
                          'set(',num2str(ie_8,32),',''visible'',''on'',''string'',''Zero Variable Name'');',...
                          'set(',num2str(ie_9,32),',''visible'',''on'',''string'',''z_values'');',...
                          'set(',num2str(ie_10,32),',''visible'',''on'');',...
                          'set(',num2str(ie_13,32),',''visible'',''on'');',...
                          'set(',num2str(ie_14,32),',''visible'',''on'');',...
                          'set(',num2str(ie_16,32),',''visible'',''on'');',...
                          'pez(''info_export'');'];
    
    
    % Do Import Selector Call
    set(ie_3,'call',import_select_call);
                          
    % Do Import Button
    set(ie_import,'call',import_call);
    
    % Do [B,A]= call
    set(ie_17,'call',['pez(''do_import_ba'',',num2str(ie_9,32),');']); 


    % Do Export Button
    set(ie_export,'call',export_call);

    % Set File Menu button now that everything's drawn
    set(um_file,'call',['argv=get(gco,''val'');set(gco,''val'',1);',...
                      'if argv==2,    ',import_call,...
                      'elseif argv==3,',export_call,...
                      'elseif argv==4, pez_conf(''edit_config'');',...
                      'elseif argv==5, pez(''hit_info'');',...
                      'elseif argv==6, pez(''exit'');end;']);

     
     
% ----- Done Setting Up, Resize everything --------------------------------------------
 
 
  pez_main_gids=PP; %Save a list of the main gui id's
  % Done drawing, now restore the pointer and window
  set(w_main_win,'Pointer','arrow','visible','on');
     

%============     
elseif strcmp(action,'hide_main'),
  set(pez_main_gids,'visible','off');

%============
elseif strcmp(action,'show_main'),
  set(pez_main_gids,'visible','on');

%============
elseif strcmp(action,'new_filename'),

  if(p_val2==1)
       [fn,pth] = uiputfile('*.mat','Write File Name');
  else  
       [fn,pth] = uigetfile('*.mat','Read File Name');
  end;

  if fn
     set(p_val,'string',['File: ',fn]);
     pez_file_name=[pth,fn];
  end;
  
%============
elseif strcmp(action,'get_filtdemo'),

  % This Code finds out if filtdemo is actually running and grabs info
  
  k=get(0,'children');
  l=1;
  k=[k; k(1)]; %For breaking loop
  while ( (l<length(k)) & ~strcmp(get(k(l),'name'),'Lowpass Filter Design Demo') ),
     l=l+1;
  end;
  
  
  if (l<length(k))
     figure(k(l));
     [b,a]=filtdemo('getfilt');
     pez_import(b,a); 
  else
     sprintf('Pez unable to find running ''filtdemo'' program.'),
  end;        
     

%============
elseif strcmp(action,'do_import'),
   
   
   if (get(p_val(1),'val')==2)
      % Load from file
      eval(['load ',pez_file_name,';']);
   end;
   
      eval(['pez_new_p=',get(p_val(2),'string'),';']);
      eval(['pez_new_z=',get(p_val(4),'string'),';']);

               
      if (get(p_val(3),'val')==2)
         pez_new_p=roots(pez_new_p);
      end;

      if (get(p_val(5),'val')==2)
         pez_new_z=roots(pez_new_z);
         
      end;
      
      pez_gain_tmp=str2num( get(p_val(6),'string') );

      pez_import(pez_new_z,pez_new_p, pez_gain_tmp, 1);         

%============
elseif strcmp(action,'do_import_ba'),
      
      eval_str=get(p_val(1),'string');
      sprintf(['[B,A]=',eval_str]),
      [b,a]= eval( eval_str );
      pez_import(b,a);

%============
elseif strcmp(action,'do_export'),
   
      global p_list z_list num_diff_poles num_diff_zeros;
      
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

      
      pole_save_var=get(p_val(1),'string');
      if (get(p_val(2),'val')==2)
          eval([pole_save_var,'=pole_poly_list;']);
      else
          eval([pole_save_var,'=pole_root_list;']); 
      end;

      zero_save_var=get(p_val(3),'string');
      if (get(p_val(4),'val')==2)
          eval([zero_save_var,'=zero_poly_list;']);
      else
          eval([zero_save_var,'=zero_root_list;']); 
      end;
      
      eval(['save ',pez_file_name,' ',pole_save_var,' ',zero_save_var]);
         


%------------ Exit --------------------------------------------------------------------
elseif strcmp(action,'exit')

 delete(w_main_win);

 if  any( get(0,'children') == id_plot )
    delete(id_plot);
 end,   
 
 if (exist('w_config') & ~(isempty(w_config)) ),
   if  any( get(0,'children') == w_config )
      delete(w_config);
   end;   
 end;    

clear global axes_zplane; clear global move_handle; clear global          pez_precision ;      
clear global del_place ;  clear global move_num_handle  ; clear global    pez_precision_ed    ;
clear global del_values ; clear global move_numh      ; clear global      pez_precision_sli  ; 
clear global del_weight ; clear global move_place    ; clear global       pez_real_drag      ; 
clear global del_x ;      clear global move_type     ; clear global       place            ;   
clear global del_y;       clear global move_x_val    ; clear global       plot_ax         ;    
clear global dp ;         clear global move_y_val     ; clear global      plot_theta      ;    
clear global drag_move;   clear global num_diff_poles ; clear global      sli_scale      ;     
clear global ed_angle;    clear global num_diff_zeros ; clear global      sli_weight      ;    
clear global ed_change ;  clear global num_poles    ; clear global        ui_text_line1   ;    
clear global ed_imag ;    clear global num_zeros   ; clear global         ui_text_line2   ;    
clear global ed_mag   ;   clear global p_list       ; clear global        ui_text_line3   ;    
clear global ed_real  ;   clear global pez_angle_type ; clear global      ui_text_line4   ;    
clear global ed_scale ;   clear global pez_file_name ; clear global       w_config         ;   
clear global ed_weight ;  clear global pez_fuz     ; clear global         w_main_win      ;    
clear global edit_type ;  clear global pez_gain    ; clear global         weight       ;       
clear global fr_omega  ;  clear global pez_gain_ed  ; clear global        x_val        ;       
clear global frs_omega ;  clear global pez_gain_sli  ; clear global       y_val        ;       
clear global id_plot  ;   clear global pez_groupdelay; clear global       z_axis       ;       
clear global mirror_x ;   clear global pez_log   ; clear global           z_list       ;       
clear global mirror_y  ;  clear global pez_new_point   ; clear pez_main_gids;    





%------------ New Plot Window -------------------------------------------------------
elseif strcmp(action,'new_plot_win')

  id_plot=figure('units','normal','pos',[.05 .50 .35 .45],'numbertitle','off',...
                 'name','Pole-Zero Plots','visible','off','color',[0 0 0]);

  % Set up the Menu Box Frame
  uf(1)=uicontrol(id_plot, 'style','frame','units','norm','pos',[ .001 .92 .998 .08],'backgroundcolor',[.4 .4 .6] );

  if((mat_version<5)&(~strcmp(computer,'MAC2') )), l_pos=0.22;       %Leave space for print button
  else,                                           l_pos=0.01; end;  %Start from complete left

  uf(2)=uicontrol('Max',0 ,'Min',1 ,'Units','norm','back',[.5 .5 .8],'fore',[1 1 1],... 
                     'Pos',[ l_pos 0.93 0.25 0.06],... 
                     'Style','popupmenu','horizontalalign','left',... 
                     'string','<Size...>|Small|Regular|Large|Hide',...
                     'call',['argv=get(gco,''val'');set(gco,''val'',1);',...
                             'if argv==2, pez(''size2_small'');',...
                             'elseif argv==3, pez(''size2_regular'');',...
                             'elseif argv==4, pez(''size2_large'');',...
                             'elseif argv==5, pez(''hide_me'');end;']);


   uf(3)=uicontrol('style','checkbox','units','norm','back',[.5 .5 .8],'fore',[1 1 1],...
                  'Pos',[ l_pos+0.27  0.925 0.25 0.06],... 
                  'string','Mag in dB',...
                  'val',pez_log,...
                  'call','pez(''set_log'', get(gco,''val'') );' );
                  %'call','global pez_log;pez_log=get(gco,''val'');pez_plot(0);');

   uf(4)=uicontrol('style','checkbox','units','norm','back',[.5 .5 .8],'fore',[1 1 1],...
                  'Pos',[ l_pos+0.53 0.925 0.24 0.06],... 
                  'string','GrpDelay',...
                  'val',pez_groupdelay,...
                  'call','pez(''set_groupdelay'',get(gco,''val''));');
                  %'call','global pez_groupdelay;pez_groupdelay=get(gco,''val'');pez_plot(0);');

   if((mat_version<5)&(~strcmp(computer,'MAC2') ))
       %No auto print options in v4,non-mac
       uicontrol('Style','push','Units','norm','back',[.5 .5 .8],'fore',[1 1 1],'Pos',[ 0.01 0.93 0.20 0.06 ],... 
                     'horizontalalign','left','string','<Print...>','call','global id_plot;uiprint(id_plot);');
   else
       s_turnon  = ['ttmp=[',num2str(uf,32),'];set(ttmp,''visible'',''on'');' ];
       s_turnoff = ['ttmp=[',num2str(uf,32),'];set(ttmp,''visible'',''off'');'];
       men_prop=uimenu('label','<PEZ Display Ops...>');
                uimenu(men_prop,'label','Hide Options for Printing','call',s_turnoff);
                uimenu(men_prop,'label','Turn Options back on','call',     s_turnon);
   end;

   plot_ax(1)=axes('box','on','units','norm','pos',[0.07 0.54 0.35 0.3255],'drawmode','fast','color','black',...
                   'xcolor',[1 1 1],'ycolor',[1 1 1],'fontsize',9,...
                   aspect_ratio_name,fixed_aspect);

    title('Z-Plane','color',[1 1 1]);
    hold on;

   plot_theta=linspace(0,2*pi,100);
   plot(cos(plot_theta),sin(plot_theta),':y',[-10; 10],[0;0],':y',[0;0],[-10; 10],':y','erasemode',pez_redraw_type);
   
      %Yoder
      h_plot(1)=plot(0,0,'erasemode',pez_redraw_type,'color','yellow');  %x's
      h_plot(2)=plot(0,0,'erasemode',pez_redraw_type,'color','yellow');  %o's

   plot_ax(2)=axes('box','on','units','norm','pos',[0.62 0.54 0.35 0.3255],'drawmode','fast','color','black',...
                   'xcolor',[1 1 1],'ycolor',[1 1 1],'fontsize',9);

    title('Impulse Response','color',[1 1 1]);
    xlabel('time index n');ylabel('amplitude');
    hold on;
    plot([0 0],[-100 100],'--r');
    plot([-100 100],[0 0],'--c');

      global pez_stemx pez_stemy
      pez_stemx(1:3:150)=0:49;
      pez_stemx(2:3:150)=0:49;
      pez_stemx(3:3:150)=NaN*ones(1,50);

      pez_stemy(3:3:150)=NaN*ones(1,50);

      %Yoder
      h_plot(3)=plot(0,0,'erasemode',pez_redraw_type,'color','yellow'); %The 'o' of the stem
      h_plot(4)=plot(0,0,'erasemode',pez_redraw_type,'color','yellow'); %The Stem
      hold on;



   plot_ax(3)=axes('box','on','units','norm','pos',[0.07 0.08 0.35 0.3255],'drawmode','fast','color','black',...
                   'xcolor',[1 1 1],'ycolor',[1 1 1]);

    set(plot_ax(3),'fontsize',9);
    title('Magnitude of Frequency Response','color',[1 1 1]);
    xlabel('omega/(2pi)');ylabel('amplitude');
    hold on;
    plot( [-1 1]/2, [0 0],'--c' );
      %Yoder
      h_plot(5)=plot(0,0,'erasemode',pez_redraw_type,'color','yellow');
      hold on;

   plot_ax(4)=axes('box','on','units','norm','pos',[0.62 0.08 0.35 0.3255],'color','black',...
                   'xcolor',[1 1 1],'ycolor',[1 1 1], 'fontsize',9);

    %set(plot_ax(4),'fontsize',9);
    title('Phase of Frequency Response','color',[1 1 1]);
    xlabel('omega/(2pi)');ylabel('radians');
    hold on;
    plot([-1 1]/2, [0 0],'--c'); %Draw the axis

      %Yoder
      h_plot(6)=plot(0,0,'erasemode',pez_redraw_type,'color','yellow');
      hold on;

   set(id_plot,'userdata',h_plot);
     
%--------------------------------------------------------------------------------------
elseif (strcmp(action,'set_log'))

   pez_log=p_val;
   axes(plot_ax(3));
   if(pez_log)
       title('Magnitude of Freq Resp(dB)','color',[1 1 1]);
%%       set(plot_ax(3), 'xlim',[0 1]/2 );
       set(plot_ax(3), 'xlim',[-1 1]/2 );
   else
       title('Magnitude of Freq Response','color',[1 1 1]);
       set(plot_ax(3), 'xlim',[-1 1]/2 );
   end;

   pez_plot(0);

%--------------------------------------------------------------------------------------
elseif (strcmp(action,'set_groupdelay'))

   pez_groupdelay=p_val;
   axes(plot_ax(4));
   if(pez_groupdelay)
       title('Group Delay','color',[1 1 1]);
       ylabel('# Samples');
   else
       title('Phase Freq Response','color',[1 1 1]);
       ylabel('Radians');
   end;

   pez_plot(0);

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
  
   set(id_plot,'units','norm');
   the_old_position = get(id_plot,'pos');
   the_old_position(3:4)=[x_size y_size];
  
   
   set(gcf,'pos',the_old_position);

%---------
elseif  strcmp(action,'hide_me')

   set(gcf,'visible','off');            
%---------
elseif  strcmp(action,'restore_text')

 set(ui_text_line1,'horizontalalignment','center','string','Welcome to PEZ 3.1: A Pole Zero Editor');
 set(ui_text_line2,'horizontalalignment','center','string','EE 2200');
 set(ui_text_line3,'horizontalalignment','center','string','Georgia Institute of Technology');
 set(ui_text_line4,'horizontalalignment','center','string','Comments & Abuse: Grimace@ee.gatech.edu');

%---------
elseif  strcmp(action,'hit_info')

 set(ui_text_line1,'horizontalalignment','center','string','PEZ by Craig Ulmer  :[ GRiMACE@ee.gatech.edu ]:');
 set(ui_text_line2,'horizontalalignment','center','string','~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
 set(ui_text_line3,'horizontalalignment','center','string','No Modifications/Sales without Author''s Consent');
 set(ui_text_line4,'horizontalalignment','center','string','"People who make Generalizations are wrong"');

%---------
elseif  strcmp(action,'info_edco')

 set(ui_text_line1,'horizontalalignment','center','string','Edit by Coordinate');
 set(ui_text_line2,'horizontalalignment','left',  'string',  'Press the ''Select a Pole or Zero'' button to choose ');
 set(ui_text_line3,'horizontalalignment','left',  'string',  'an object to edit. ');
 set(ui_text_line4,'horizontalalignment','left',  'string',  'Press ''Done Editing'' to return to the Main Menu.');

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
elseif  strcmp(action,'info_import_add')

 set(ui_text_line1,'horizontalalignment','center','string','Add Filter Data');
 set(ui_text_line2,'horizontalalignment','left','string',  'This option cascades the current PeZ filter with a newly');
 set(ui_text_line3,'horizontalalignment','left','string',  'defined filter. Describe the new filter through Polynomial');
 set(ui_text_line4,'horizontalalignment','left','string',  'equation coeffcients or pole/zero Root locations.');

%---------
elseif  strcmp(action,'info_import_file')

 set(ui_text_line1,'horizontalalignment','center','string','Add Filter Data from File');
 set(ui_text_line2,'horizontalalignment','left','string',  'This function extracts filter coefficients from a MATLAB');
 set(ui_text_line3,'horizontalalignment','left','string',  'data file. The Variable names tell Pez where to look');
 set(ui_text_line4,'horizontalalignment','left','string',  'inside of the specified data file.');

%---------
elseif  strcmp(action,'info_import_ba')

 set(ui_text_line1,'horizontalalignment','center','string','Import with MATLAB Call [B,A]=xxxxx');
 set(ui_text_line2,'horizontalalignment','left','string',  'This function imports data as it would be called by the');
 set(ui_text_line3,'horizontalalignment','left','string',  'usual MATLAB functions. It expects polynomial results.');
 set(ui_text_line4,'horizontalalignment','left','string',  'example: [B,A]= butter(5,0.5,''high'');');

%---------
elseif  strcmp(action,'info_import_filt')

 set(ui_text_line1,'horizontalalignment','center','string','Grab ''Filtdemo'' Values');
 set(ui_text_line2,'horizontalalignment','left','string',  'This function imports the current filter being designed');
 set(ui_text_line3,'horizontalalignment','left','string',  'by the MATLAB program''filtdemo''. Note: you may want to');
 set(ui_text_line4,'horizontalalignment','left','string',  'adjust the add precision(under config) for higher orders.');

%---------
elseif  strcmp(action,'info_export')

 set(ui_text_line1,'horizontalalignment','center','string','Export to File');
 set(ui_text_line2,'horizontalalignment','left','string',  'This function exports the current filter to a MATLAB');
 set(ui_text_line3,'horizontalalignment','left','string',  'formatted .MAT data file. Click the file button to ');
 set(ui_text_line4,'horizontalalignment','left','string',  'select a new file name.');

%---------                  
else

  invalid_pez_command=action,
  help pez

end;
