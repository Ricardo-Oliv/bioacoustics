# cd /home/pi/Desktop/deploy_classifier/ && python GUI.py
# python GUI.py
import os
import time as t
import random as rd
import math 
import gi
import os.path
import re
from datetime import datetime
import os.path, time


gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GdkPixbuf, GLib

class ButtonWindow(Gtk.Window):

    def __init__(self):
        Gtk.Window.__init__(self, title="Ultrasonic Classifier")
        self.set_border_width(10)
        self.set_default_size(800, 480)
        
        hp1 = Gtk.Paned.new(Gtk.Orientation.HORIZONTAL)
        hp2 = Gtk.Paned.new(Gtk.Orientation.HORIZONTAL)
        hp3 = Gtk.Paned.new(Gtk.Orientation.HORIZONTAL)
        vp1 = Gtk.Paned.new(Gtk.Orientation.VERTICAL)
        vp2 = Gtk.Paned.new(Gtk.Orientation.VERTICAL)

        grid_01 = Gtk.Grid()
        grid_02 = Gtk.Grid()
        grid_03 = Gtk.Grid()
        grid_03.set_column_homogeneous(True)
        grid_03.set_column_spacing(20)
        grid_04 = Gtk.Grid()
        grid_04.set_column_homogeneous(True)
        grid_04.set_column_spacing(10)
        
###########################################################################

        vboxCombo = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        
        self.set_border_width(10)

        name_store1 = Gtk.ListStore(int, str)
        name_store1.append([1, "UK_Bats"])
        name_store1.append([11, "Rodents"])
        name_store1.append([12, "Mechanical_Bearings"])
        
        name_store2 = Gtk.ListStore(int, str)
        name_store2.append([21, "Level1:_Species"])
        name_store2.append([31, "Level2:_Genera"])
        name_store2.append([22, "Level3:_Order"])
        name_store2.append([23, "Bicycle_Wheel"])
        
        name_store3 = Gtk.ListStore(int, str)
        name_store3.append([41, "All_Calls"])
        name_store3.append([42, "Echolocation_Only"])
        name_store3.append([43, "Socials_Only"])
        name_store3.append([44, "NULL"])

        name_combo1 = Gtk.ComboBox.new_with_model_and_entry(name_store1)
        name_combo1.connect("changed", self.on_name_combo1_changed)
        name_combo1.set_entry_text_column(1)
        vboxCombo.pack_start(name_combo1, False, False, 0)
        
        name_combo2 = Gtk.ComboBox.new_with_model_and_entry(name_store2)
        name_combo2.connect("changed", self.on_name_combo2_changed)
        name_combo2.set_entry_text_column(1)
        vboxCombo.pack_start(name_combo2, False, False, 0)
        
        name_combo3 = Gtk.ComboBox.new_with_model_and_entry(name_store3)
        name_combo3.connect("changed", self.on_name_combo3_changed)
        name_combo3.set_entry_text_column(1)
        vboxCombo.pack_start(name_combo3, False, False, 0)

        name_combo1.set_active(0)
        name_combo2.set_active(0)
        name_combo3.set_active(0)
        
        name = "UK_Bats" + "\n" + "Level1:_Species" + "\n" + "All_Calls"                   # Set defaults
        file = "/home/pi/Desktop/deploy_classifier/helpers/combo_01.txt"
        f= open(file, "w+")                                 # Create the file combo_01.txt
        f.write(name)
        f.close()

###########################################################################
        name = "record"                                     # Set default to 'record'
        file = "/home/pi/Desktop/deploy_classifier/helpers/toggled_01.txt"
        f= open(file, "w+")                                 # Create the file toggled_01.txt
        f.write(name)
        f.close()
        
        hbox = Gtk.Box(spacing=6)
        hbox.set_orientation(Gtk.Orientation.VERTICAL)

        buttonZ1 = Gtk.RadioButton.new_with_label_from_widget(None, "Record some live audio")
        #buttonZ1.set_label("record")
        buttonZ1.connect("toggled", self.on_button_toggled, "record")
        hbox.pack_start(buttonZ1, False, False, 0)

        buttonZ2 = Gtk.RadioButton.new_with_label_from_widget(buttonZ1, "Process a batch of old recordings")
        #buttonZ2.set_label("process")
        buttonZ2.connect("toggled", self.on_button_toggled, "process")
        hbox.pack_start(buttonZ2, False, False, 0)

        buttonZ3 = Gtk.RadioButton.new_with_label_from_widget(buttonZ1, "Button 3")
        buttonZ3.connect("toggled", self.on_button_toggled, "empty 1")
        hbox.pack_start(buttonZ3, False, False, 0)
        
        buttonZ4 = Gtk.RadioButton.new_with_label_from_widget(buttonZ1, "Button 4")
        buttonZ4.connect("toggled", self.on_button_toggled, "empty 2")
        hbox.pack_start(buttonZ4, False, False, 0)
#######################################################################

        button1 = Gtk.Button.new_with_label("Take dog for a walk")
        button1.connect("clicked", self.on_click_me_clicked)

        button2 = Gtk.Button.new_with_mnemonic("_Drink another coffee")
        button2.connect("clicked", self.on_open_clicked)

        button3 = Gtk.Button.new_with_mnemonic("_Shut down the Pi")
        button3.connect("clicked", self.shut_down_clicked)
        
        button4 = Gtk.Button.new_with_mnemonic("_Ignore")
        button4.connect("clicked", self.on_close_clicked)
        
        button5 = Gtk.Button.new_with_mnemonic("_Threshold")
        
        button6 = Gtk.Button.new_with_mnemonic("_Something Else")
        button6.connect("clicked", self.on_close_clicked)

        button7 = Gtk.Button.new_with_label("Play disc rog audio")
        button7.connect("clicked", self.on_click_me_clicked)
        
        button8 = Gtk.Button.new_with_label("Self destruct")
        button8.connect("clicked", self.on_click_me_clicked)
        
        adjustment = Gtk.Adjustment(0, 50, 100, 1, 10, 0)
        self.spinbutton_01 = Gtk.SpinButton()
        self.spinbutton_01.set_adjustment(adjustment)

        # a label
        self.label = Gtk.Label()
        self.label.set_text("Choose an audio indicator threshold value!")
        self.spinbutton_01.connect("value-changed", self.spin_selected)
  
        check_numeric_01 = Gtk.CheckButton("Numeric")
        check_numeric_01.connect("toggled", self.on_numeric_toggled)

        check_ifvalid_01 = Gtk.CheckButton("If Valid")
        check_ifvalid_01.connect("toggled", self.on_ifvalid_toggled)
        
        checkbutton_01 = Gtk.CheckButton("Click me!")
        checkbutton_01.connect("toggled", self.on_ifvalid_toggled)
        
    
        box2 = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        #self.add(self.box2)
        toolbar = Gtk.Toolbar()
        selected_folder = "/home/pi/Desktop/deploy_classifier/my_audio"
        open_btn = Gtk.ToolButton.new_from_stock(Gtk.STOCK_OPEN)
        open_btn.connect("clicked", self.select_folder_clicked)
        toolbar.insert(open_btn, 0)
        save_btn = Gtk.ToolButton.new_from_stock(Gtk.STOCK_SAVE)
        #save_btn.connect("clicked", self.on_save_clicked)
        toolbar.insert(save_btn, 1)
        box2.pack_start(toolbar, False, True, 0)

        scrolledwindow = Gtk.ScrolledWindow()
        scrolledwindow.set_hexpand(True)
        #scrolledwindow.set_vexpand(False)
        scrolledwindow.set_policy(
            Gtk.PolicyType.NEVER, Gtk.PolicyType.NEVER)

        self.textview = Gtk.TextView()
        self.textbuffer = self.textview.get_buffer()
        scrolledwindow.add(self.textview)
        box2.pack_start(scrolledwindow, True, True, 0) 
        
        # button1 = Take dog for a walk.
        # button2 = Drink another coffee.
        # button3 = Shutdown the pi.
        # button4 = Ignore.
        # button5 = Threshold.
        
        grid_01.attach(box2, 0, 0, 2, 1)
        grid_01.attach(button2, 0, 1, 1, 1)         # Drink another coffee
        grid_01.attach_next_to(button3, button2, Gtk.PositionType.RIGHT, 1, 1)         # Shutdown the pi.

        grid_01.attach(button5, 0, 2, 1, 1)         # Threshold
        grid_01.attach_next_to(self.spinbutton_01, button5, Gtk.PositionType.RIGHT, 1, 1)
        grid_01.attach(self.label, 0, 3, 1, 1)
        
        grid_02.add(button7)
        grid_02.attach(button8, 0, 1, 1, 1)
        grid_02.attach(check_numeric_01, 0, 3, 1, 1)
        grid_02.attach(check_ifvalid_01, 0, 4, 1, 1)
        grid_02.attach(checkbutton_01, 0, 5, 1, 1)

##########################################################################
        hp1.add1(hbox)
        hp1.add2(grid_01)
        hp1.set_position(300)   # Only max of 2 panes allowed.
##########################################################################       
        
        button9 = Gtk.Button.new_with_label("Play disc rog audio")
        button9.connect("clicked", self.on_click_me_clicked)

        button10 = Gtk.Button.new_with_label("STOP")
        button10.connect("clicked", self.on_click_me_clicked)
        color = Gdk.Color(40000, 0, 0)
        button10.modify_bg(Gtk.StateType.PRELIGHT, color)
        button10.modify_bg(Gtk.StateType.NORMAL, Gdk.Color(65000, 0, 0)) # Red, Green, Blue, max 65535
        
        button11 = Gtk.Button.new_with_label("RECORD")
        button11.connect("clicked", self.on_click_me_clicked)
        color = Gdk.Color(0, 40000, 0)
        button11.modify_bg(Gtk.StateType.PRELIGHT, color)
        button11.modify_bg(Gtk.StateType.NORMAL, Gdk.Color(0, 50000, 0)) # Red, Green, Blue, max 65535
        
        button12 = Gtk.Button.new_with_label("Play audio")
        button12.connect("clicked", self.on_click_me_clicked)
        
        
        button13 = Gtk.Button.new_with_label("Play audio")
        button13.connect("clicked", self.on_click_me_clicked)
        
        button14 = Gtk.Button.new_with_label("Play audio")
        button14.connect("clicked", self.on_click_me_clicked)
        
        button15 = Gtk.Button.new_with_label("Play audio")
        button15.connect("clicked", self.on_click_me_clicked)

        media_box = Gtk.EventBox()
        image = Gtk.Image()
        pixbuf = GdkPixbuf.Pixbuf.new_from_file("/home/pi/Desktop/GUI/goatlogo70high.jpg")
        image.set_from_pixbuf(pixbuf)
        media_box.add(image)
        media_box.connect("button_press_event",self.hello1)
        
        start_media_box = Gtk.EventBox()
        start_image = Gtk.Image()
        pixbuf_start = GdkPixbuf.Pixbuf.new_from_file_at_size("/home/pi/Desktop/GUI/start_250.png", 100, 100)
        start_image.set_from_pixbuf(pixbuf_start)
        start_media_box.add(start_image)
        start_media_box.connect("button_press_event",self.start)  # Starts the window of results in app.
        # start_media_box.connect("button_press_event",self.record_and_classify)
        # record_and_calssify does not connect until 'stop' is pressed! Not useful!!!!
        
        stop_media_box = Gtk.EventBox()
        stop_image = Gtk.Image()
        pixbuf_stop = GdkPixbuf.Pixbuf.new_from_file_at_size("/home/pi/Desktop/GUI/stop_250.png", 100, 100)
        stop_image.set_from_pixbuf(pixbuf_stop)
        stop_media_box.add(stop_image)
        stop_media_box.connect("button_press_event",self.stop)

        grid_03.add(media_box)
        
        grid_04.add(start_media_box)                         # Record
        grid_04.attach(stop_media_box, 1, 0, 1, 1)           # Stop
        
        grid_05 = Gtk.Grid()

        box1 = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box1.set_homogeneous(False)

        self.label1 = Gtk.Label()
        self.label1.set_width_chars(60)
        file = '/home/pi/Desktop/deploy_classifier/instructions.txt'
        if os.path.isfile(file):
            with open(file) as fp:
                text2 = fp.read()
            fp.close()
        self.label1.set_text(text2)
        box1.pack_start(self.label1, True, True, 0)
        
        # self.activitybar = Gtk.ProgressBar()
        # self.timeout_id = GLib.timeout_add(50, self.on_timeout_pulse, None)
        # self.activity_mode = True
        # box1.pack_start(self.activitybar, True, True, 0)
        
        self.label2 = Gtk.Label()
        self.label2.set_width_chars(60)
        box1.pack_start(self.label2, True, True, 0)   

        grid_05.add(box1)
        #grid_05.attach(box2, 1, 1, 1, 1)
        #grid_04.attach(stop_media_box, 1, 0, 1, 1)           # Stop
#########################################################################   
        # hp3.add1(grid_02)                          # Some random checkboxes
        # self.add(vboxCombo)
        hp3.add1(vboxCombo) 
        hp3.add2(grid_05)                          # Display text file
        hp3.set_position(200)
##########################################################################
        hp2.add1(grid_03)                          # Goat logo
        hp2.add2(grid_04)                          # Record / Stop recording.
        #hp2.set_position(310)   
##########################################################################    
        vp1.add1(hp1)                              # Check boxes and buttons
        vp1.add2(hp3)                              # Some random checkboxes and text box.
        vp1.set_position(160)
##########################################################################  
        vp2.add1(vp1) 
        vp2.set_position(350)
        vp2.add2(hp2)                             # Got logo and recording controls.
##########################################################################
        self.add(vp2)
##########################################################################
        # selected_folder = "/home/pi/Desktop/deploy_classifier/my_audio"
    
    def replace_line(self, file_name, line_num, text):
        lines = open(file_name, 'r').readlines()
        lines[line_num] = text
        out = open(file_name, 'w')
        out.writelines(lines)
        out.close()
        
    def on_name_combo1_changed(self, combo):
        tree_iter = combo.get_active_iter()
        if tree_iter is not None:
            model = combo.get_model()
            row_id, name = model[tree_iter][:2]
            print("Selected: ID=%d, name=%s" % (row_id, name))
            self.replace_line('/home/pi/Desktop/deploy_classifier/helpers/combo_01.txt', 0, name + '\n')
        else:
            entry = combo.get_child()
            print("Entered: %s" % entry.get_text())
            
    def on_name_combo2_changed(self, combo):
        tree_iter = combo.get_active_iter()
        if tree_iter is not None:
            model = combo.get_model()
            row_id, name = model[tree_iter][:2]
            print("Selected: ID=%d, name=%s" % (row_id, name))
            self.replace_line('/home/pi/Desktop/deploy_classifier/helpers/combo_01.txt', 1, name + '\n')
        else:
            entry = combo.get_child()
            print("Entered: %s" % entry.get_text())

    def on_name_combo3_changed(self, combo):
        tree_iter = combo.get_active_iter()
        if tree_iter is not None:
            model = combo.get_model()
            row_id, name = model[tree_iter][:2]
            print("Selected: ID=%d, name=%s" % (row_id, name))
            self.replace_line('/home/pi/Desktop/deploy_classifier/helpers/combo_01.txt', 2, name + '\n')
        else:
            entry = combo.get_child()
            print("Entered: %s" % entry.get_text())

    def select_folder_clicked(self, widget):
        # selected_folder = "/home/pi/Desktop/deploy_classifier/my_audio"
        dialog = Gtk.FileChooserDialog("Please choose the folder containing your audio files", self,

            Gtk.FileChooserAction.SELECT_FOLDER,
            (Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL,
             Gtk.STOCK_OPEN, Gtk.ResponseType.OK))

        response = dialog.run()
        # selected_folder = "/home/pi/Desktop/deploy_classifier/my_audio"
        selected_folder = dialog.get_filename()
        if response == Gtk.ResponseType.OK:
            selected_folder = dialog.get_filename()
            print(selected_folder)
            file = "/home/pi/Desktop/deploy_classifier/helpers/audio_files_path.txt"
            f= open(file, "w+")                         # Create the file audio_files_path.txt
            f.write(selected_folder)
            f.close()
            self.textbuffer.set_text(selected_folder)
        elif response == Gtk.ResponseType.CANCEL:
            dialog.destroy()

        dialog.destroy()

    def on_timeout_pulse(self, user_data):
        if self.activity_mode:
            self.activitybar.pulse()
        # As this is a timeout function, return True so that it
        # continues to get called
        return True
        
    def record_and_classify(self, button, event):
        print("\"Open\" button was clicked")
        file = "/home/pi/Desktop/deploy_classifier/bash_app"
        os.system("bash " + file)

    def stop(self, widget, event):            # Stop image.
        print("stop")
        stopFile = "/home/pi/Desktop/deploy_classifier/helpers/stop.txt"
        startFile = "/home/pi/Desktop/deploy_classifier/helpers/start.txt"
        f= open(stopFile, "w+")
        if os.path.isfile(startFile):
            os.remove(startFile)
            print("start file removed")
        print("stop file created !!")
        f.close()

    def shut_down_clicked(self, button):         # Shut down Pi.
        print("shut down")
        shutDownFile = "/home/pi/Desktop/deploy_classifier/helpers/shutDown.txt"
        startFile = "/home/pi/Desktop/deploy_classifier/helpers/start.txt"
        f= open(shutDownFile, "w+")
        if os.path.isfile(startFile):
            os.remove(startFile)
            print("start file removed")
        print("shut down file created !!")
        f.close()

    def start(self, widget, event):    # Start box rather than image.
        
        file = "/home/pi/Desktop/deploy_classifier/helpers/toggled_01.txt"
        with open(file) as fp:
            textToggled = fp.read()
        fp.close()
        print(textToggled)
        
        stopFile = "/home/pi/Desktop/deploy_classifier/helpers/stop.txt"
        startFile = "/home/pi/Desktop/deploy_classifier/helpers/start.txt"
        f= open(startFile, "w+")     # Create the file start.txt
        if os.path.isfile(stopFile):
            os.remove(stopFile)
            print("stop file removed")
        print("start file created !!")
        a = 0
        while a==0:
            if os.path.isfile(stopFile):
                print("stopFile detected !!!!")
                a = 1
            elif textToggled == "record":                                                            # There exists no stopFile.
                file = '/home/pi/Desktop/deploy_classifier/Final_result_copy.txt'
                if os.path.isfile(file):
                    current_time = time.ctime(os.path.getctime("/home/pi/Desktop/deploy_classifier/Final_result_copy.txt"))
                    newText = ""
                    line2 = ""
                    line3 = ""
                    zzz = ""
                    lines = 0
                    with open(file) as fp:
                        line = fp.readline()
                        cnt = 1
                        while line :
                            line = fp.readline()
                            line2 = re.sub('\ |\"|\!|\/|\;|\:', '', line)
                            if cnt < 7:                                                 # was 7
                                zzz = re.split(r'\t+', line2)
                                line3 = zzz.pop(0) + " = " + zzz.pop(1)
                                newText = newText + line3
                            cnt += 1
                    text = current_time + "\n" + newText
                    fp.close()
                    
                else:
                    text = "Waiting for data ......"
                waittime=1
                num=rd.randint(1,60)
                text2 = ""
                for i in range(num):
                    text2 = text2 + "*"                 # A random series of characters as a progress indicator.
                self.label1.set_text(text2)
                self.label2.set_text(text)
                while Gtk.events_pending():
                    Gtk.main_iteration()
                t.sleep(waittime)
                    
            elif textToggled == "process":                                                            # There exists no stopFile.
                file = '/home/pi/Desktop/deploy_classifier/Final_result_copy.txt'
                if os.path.isfile(file):
                    with open(file, "r") as fp:
                        text = fp.read()
                    fp.close()
                    
                else:
                    text = "Waiting for data ......"
                waittime=1
                num=rd.randint(1,60)
                text2 = ""
                for i in range(num):
                    text2 = text2 + "*"                 # A random series of characters as a progress indicator.
                self.label1.set_text(text2)
                self.label2.set_text(text)
                while Gtk.events_pending():
                    Gtk.main_iteration()
                t.sleep(waittime)

    def updateTime(self):
        timeStr = self.getTime()
        print(timeStr)
        #self.set_text(timeStr)
        return GLib.SOURCE_CONTINUE

    def getTime(self):
        return time.strftime("%c")

    # callback function: the signal of the spinbutton is used to change the text of the label
    def spin_selected(self, event):
        value = str(self.spinbutton_01.get_value_as_int())
        self.label.set_text("Threshold value selected is: " + value + ".")
        file = "/home/pi/Desktop/deploy_classifier/helpers/threshold.txt"
        f= open(file, "w+")                                 # Create the file threshold.txt
        f.write(value)
        f.close()


    def on_click_me_clicked(self, button):
        print("\"Click me\" button was clicked")
        file = "/home/pi/Desktop/deploy_classifier/alert_sounds/Go_for_Deploy.wav"
        os.system("aplay " + file)

    def on_open_clicked(self, button):
        print("\"Open\" button was clicked")
        file = "/home/pi/Desktop/deploy_classifier/bash_app"
        os.system("bash " + file)

    def on_close_clicked(self, button):
        print("Stopping application")
        os.system(exit)
        #os.system(return [n])

    def on_numeric_toggled(self, button):
        self.spinbutton_01.set_numeric(button.get_active())
        print("Numeric")

    def on_ifvalid_toggled(self, button):
        if button.get_active():
            policy = Gtk.SpinButtonUpdatePolicy.IF_VALID
            print("Validated")
        else:
            policy = Gtk.SpinButtonUpdatePolicy.ALWAYS
        self.spinbutton_01.set_update_policy(policy)
        
    def on_spinbutton_01_value_changed(self, spinbutton):
        # print spinbutton_01.get_value_as_int()
        print("Nothing")
        
    def hello1(self, widget, event):
        print("clicked label 1")
        
    def test(self):
        Gtk.Window.__init__(self, title="RadioButton Demo")
        self.set_border_width(10)

        hbox = Gtk.Box(spacing=6)
        self.add(hbox)

        button1 = Gtk.RadioButton.new_with_label_from_widget(None, "Button 1")
        button1.connect("toggled", self.on_button_toggled, "1")
        hbox.pack_start(button1, False, False, 0)

        button2 = Gtk.RadioButton.new_from_widget(button1)
        button2.set_label("Button 2")
        button2.connect("toggled", self.on_button_toggled, "2")
        hbox.pack_start(button2, False, False, 0)

        button3 = Gtk.RadioButton.new_with_mnemonic_from_widget(button1,
            "B_utton 3")
        button3.connect("toggled", self.on_button_toggled, "3")
        hbox.pack_start(button3, False, False, 0)

    def on_button_toggled(self, button, name):
        if button.get_active():
            state = "on"
        else:
            state = "off"
        print("Button", name, "was turned", state)
        file = "/home/pi/Desktop/deploy_classifier/helpers/toggled_01.txt"
        f= open(file, "w+")                                 # Create the file toggled_01.txt
        f.write(name)
        f.close()
        
    def set_style_text(self, checkbutton):
        start, end = textbuffer.get_bounds()

        if checkbuttonColor.get_active():
            textbuffer.apply_tag(texttagColor, start, end)
        else:
            textbuffer.remove_tag(texttagColor, start, end)
            
    def set_wrap_mode(self, radiobutton, wrap_mode):
        textview.set_wrap_mode(wrap_mode)
    
win = ButtonWindow()
win.set_position(Gtk.WindowPosition.CENTER)
win.connect("destroy", Gtk.main_quit)
win.show_all()
Gtk.main()
