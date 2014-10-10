function varargout = analog_gui(EvData,analog,srate,dims,OF_flds)
% 
%  EvDataOut = analog_gui(EvData,analog,srate,dims)
%
%  Description:
%        The function will open a gui to review an analog channel and the
%        appropriate Event Database.
% 
%        Database    - The Event database (i.e. first field must be
%                      'event')
%        analog      - a vector
%        srate       - sampling rate
%        dims        - dimension of GUI window
%        OF_flds     - Event field to use for updating the GUI (default
%                     {'onset' 'offset'} )
   use_other_fields = 1;
   if (nargin<5)
       use_other_fields = 0;
   end
   if (nargin<4)
       x_start = 300;
       y_start = 400;
       x_width = 600;
       y_height= 500;
   else
       x_start = dims(1);
       y_start = dims(2);
       x_width = dims(3);
       y_height= dims(4);
       
   end
   MN = min(min(analog));
   MX = max(max(analog));
   
   probing_graph =0;
   
   flds = fieldnames(EvData);
   if (length(flds)<1), error('please check Event Database'); end
   PopStr = [flds{1}];
   for i = 2:length(flds)
       PopStr = [PopStr '|' flds{i}];
   end
   
   %  Create and then hide the GUI as it is being constructed.
   f = figure('Visible','off','Position',[x_start,y_start,x_width,y_height]);
   
   ax1 = axes('position', [ 0.05    0.5838    0.7750    0.3412]);
   ax2 = axes('position', [ 0.05    0.200     0.7750    0.3412]);
   
   ev_num =1;
   saved_EvData = EvData(ev_num);
   
   %  Construct the components.
   hEvNum   = uicontrol('Style','edit','String',num2str(ev_num),...
            'Position',[x_width-130,70,30,30],...
            'Callback',{@EvNumText_Callback});
   hNext    = uicontrol('Style','pushbutton','String','Next',...
            'Position',[x_width-95,55,70,20],...
            'Callback',{@Next_Callback});
   hPrev    = uicontrol('Style','pushbutton','String','Previous',...
            'Position',[x_width-95,75,70,20],...
            'Callback',{@Prev_Callback});
   hSave    = uicontrol('Style','pushbutton','String',['Save ' inputname(1)],...
            'Position',[x_width-130,35,120,20],...
            'Callback',{@Save_Callback,inputname(1)});
   hPlay    = uicontrol('Style','pushbutton','String','Play Selection',...
            'Position',[x_width-100,y_height-330,75,20],...
            'Callback',{@Play_Callback});
   hMN      = uicontrol('Style','edit','String',num2str(MN),...
            'Position',[x_width-100,y_height-290,60,30],...
            'Callback',{@MN_Callback});
   hMX      = uicontrol('Style','edit','String',num2str(MX),...
            'Position',[x_width-100,y_height-250,60,30],...
            'Callback',{@MX_Callback});
        
   if (use_other_fields)
       eval(['hSlider  = uicontrol(''Style'',''slider'',''Min'',1,''Max'',length(analog),''Value'',max(EvData(ev_num).' OF_flds{1} ',1),''SliderStep'',[0.0001 0.0005],''Position'',[5,105,x_width-160,30],''Callback'',{@Slider_Callback});']);
   else
       hSlider  = uicontrol('Style','slider','Min',1,'Max',length(analog),'Value',max(EvData(ev_num).onset,1),'SliderStep',[0.0001 0.0005],...
                'Position',[5,105,x_width-160,30],...
                'Callback',{@Slider_Callback});
   end
   hCheckBox= uicontrol('Style','checkbox','Min',0,'Max',1,'Value',0,...
            'Position',[x_width-150,y_height-360,20,20],...
            'Callback',{@CheckBox_Callback});
   hStatCB  = uicontrol('Style','text','String','Seconds (x-axis)',...
            'Position',[x_width-129,y_height-365,50,30]);

 
   cnt=1;x_base = 5;
   for i=1:3
       y_base=75;
       for j=1:3
         if (cnt>length(flds)) continue; end
         hPopup{cnt}   = uicontrol('Style','popupmenu','String',PopStr,'Value',cnt,...
            'Position',[x_base,y_base-3,80,30],...
            'Callback',{@Popup_Callback,cnt});
         hFld{cnt}     = uicontrol('Style','edit',...
            'Position',[x_base+85,y_base,100,30],...
            'Callback',{@Fld_Callback,cnt},...
            'KeyPressFcn',{@Graph_input,cnt});
         update_field(cnt);
         cnt = cnt+1;
         y_base = y_base - 35; 
       end
       x_base = x_base + 200;
   end
   
   plot_analog();
   set(f,'Visible','on');
   
   function EvNumText_Callback(source,eventdata)
       update_event(str2num(get(source,'String')));
   end

   function Next_Callback(source,eventdata)
       save_event;
       update_event(ev_num+1);
   end

   function Prev_Callback(source,eventdata)
       save_event;
       update_event(ev_num-1);
   end

   function Save_Callback(source,eventdata,name)
       assignin('base',name,EvData);
   end

   function Play_Callback(source,eventdata)
      ax = axis;
      st = ax(1);
      en = ax(2);
      if (get(hCheckBox,'Value') == get(hCheckBox,'Max'))
        st = st*srate;
        en = en*srate;
      end
      soundsc(double(analog(st:en,:)),srate);
   end

   function MN_Callback(source,eventdata)
       MN=str2num(get(source,'String'));
       plot_analog();
   end

   function MX_Callback(source,eventdata)
       MX=str2num(get(source,'String'));
       plot_analog();
   end

   function Slider_Callback(source,eventdata)
       plot_analog();
   end

   function Popup_Callback(source,eventdata,num)
       update_field(num);
   end

   function Fld_Callback(source,eventdata,num)
       my_val = str2num(get(hFld{num},'String'));
       if isempty(my_val), my_val = get(hFld{num},'String'); end
       eval(['saved_EvData.' flds{get(hPopup{num},'Value')} ' = my_val;']);
       if (num>1 && num<4 && probing_graph==0)
           if (use_other_fields)
               eval(['plot_analog(saved_EvData.' OF_flds{1} ',saved_EvData.' OF_flds{2} ');']);
           else
               plot_analog(saved_EvData.onset,saved_EvData.offset);
           end
       end
       update_field(num);
   end

   function CheckBox_Callback(source,eventdata)
       plot_analog();
   end

   function update_field(num)
       eval(['set(hFld{num},''String'',num2str(saved_EvData.' flds{get(hPopup{num},'Value')} '));']);
   end

   function Graph_input(source, eventdata, num)
       if  (length(eventdata.Character)<1), return; end
       if ~(eventdata.Character == '~'), return; end
       eventdata.Character
       probing_graph=1;
       [x,y] = ginput(1);
       if (get(hCheckBox,'Value') == get(hCheckBox,'Max')), x = x*srate; end
       set(hFld{num},'String',num2str(round(x)));
       eval(['saved_EvData.' flds{get(hPopup{num},'Value')} ' = round(x);']);
       probing_graph=0;
       if (use_other_fields)
               eval(['plot_analog(saved_EvData.' OF_flds{1} ',saved_EvData.' OF_flds{2} ');']);
               eval(['set(hSlider,''Value'',saved_EvData.' OF_flds{1} ');']);
       else
               plot_analog(saved_EvData.onset,saved_EvData.offset);
               set(hSlider,'Value',saved_EvData.onset);
       end
   end

   function plot_analog(st,en)
      if (nargin<1), st = round(get(hSlider,'Value')); end
      if (nargin<2), en = round(st+srate/3); end
      if (st == 0)
          st = round(get(hSlider,'Value'));
      end
      if (en == 0)
          en = round(st+srate/3);
      end
      if (srate>10000*2)
          f_mx = 10000;      % up to 7 Khz if possible
          wind = 256;
          noverlap = 64;
      else
          f_mx = floor(srate/2);
          wind = 32;
          noverlap = 8;
      end
      set(hSlider,'Value',st);
      subplot(ax2);
      [S,F,T] = spectrogram(double(analog(st:en,1)),wind,noverlap,[],srate);
      freq = find(F<=f_mx,1,'last');
      pcolor(T,F(1:freq),log10(abs(S(1:freq,:)))); shading interp;
      subplot(ax1);
      if (get(hCheckBox,'Value') == get(hCheckBox,'Max'))
          plot(st/srate:1/srate:en/srate,analog(st:en,:)); axis([st/srate en/srate MN MX]);
      else
          plot(st:en,analog(st:en,:)); axis([st en MN MX]);      
      end
      
   end
   
   function update_event(new_ev)
       if (new_ev<1 || new_ev>length(EvData))
           set(hEvNum,'String',ev_num);
           errordlg('You have moved to an invalid event number, please try a again');
           return;
       end
       ev_num = new_ev;
       set(hEvNum,'String',ev_num);
       saved_EvData = EvData(ev_num);
       for i=1:length(flds)
           update_field(i);
       end
       
       if (use_other_fields)
              eval(['plot_analog(saved_EvData.' OF_flds{1} ',EvData(ev_num).' OF_flds{2} ');']);
       else
              plot_analog(saved_EvData.onset,EvData(ev_num).offset);     
       end
       varargout = EvData;
   end

   function save_event
       EvData(ev_num) = saved_EvData;
       save('Analog_GUI_temp_save','EvData');
   end

end



