# cd /home/pi/Desktop/GUI/
# python Test_app.py

import gi
import os

gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

class ButtonWindow(Gtk.Window):

    def __init__(self):
        Gtk.Window.__init__(self, title="Ultrasonic Classifier")
        self.set_border_width(10)
        
        grid = Gtk.Grid()
        self.add(grid)
        
        img = Gtk.Image.new_from_file('/home/pi/Desktop/GUI/goatlogo70high.jpg')

        button1 = Gtk.Button.new_with_label("Play discovery roger audio")
        button1.connect("clicked", self.on_click_me_clicked)
        #hbox.pack_start(button1, True, True, 0)

        button2 = Gtk.Button.new_with_mnemonic("_Run Classifier")
        button2.connect("clicked", self.on_open_clicked)
        #hbox.pack_start(button2, True, True, 0)

        button3 = Gtk.Button.new_with_mnemonic("_Close")
        button3.connect("clicked", self.on_close_clicked)
        #hbox.pack_start(button3, True, True, 0)
        
        button4 = Gtk.Button.new_with_mnemonic("_Ignore")
        button4.connect("clicked", self.on_close_clicked)
        
        button5 = Gtk.Button.new_with_mnemonic("_Threshold")
        #button5.connect("clicked", self.on_close_clicked)
        
        button6 = Gtk.Button.new_with_mnemonic("_Something Else")
        button6.connect("clicked", self.on_close_clicked)
        
        adjustment = Gtk.Adjustment(0, 0, 100, 1, 10, 0)
        self.spinbutton_01 = Gtk.SpinButton()
        self.spinbutton_01.set_adjustment(adjustment)

        # a label
        self.label = Gtk.Label()
        self.label.set_text("Choose a threshold value ! ")
        self.spinbutton_01.connect("value-changed", self.spin_selected)
  
        check_numeric_01 = Gtk.CheckButton("Numeric")
        check_numeric_01.connect("toggled", self.on_numeric_toggled)

        check_ifvalid_01 = Gtk.CheckButton("If Valid")
        check_ifvalid_01.connect("toggled", self.on_ifvalid_toggled)
        
        grid.add(button1)
        grid.attach(button2, 1, 0, 2, 1)
        grid.attach_next_to(button3, button1, Gtk.PositionType.BOTTOM, 1, 2)
        grid.attach_next_to(button4, button3, Gtk.PositionType.RIGHT, 2, 1)
        grid.attach(button5, 1, 2, 1, 1)
        # grid.attach(check_numeric_01, 1, 3, 1, 1)
        # grid.attach(check_ifvalid_01, 1, 4, 1, 1)
        grid.attach(self.label, 0, 5, 2, 1)
        grid.attach(img, 0, 6, 2, 1)
        grid.attach_next_to(self.spinbutton_01, button5, Gtk.PositionType.RIGHT, 1, 1)
        
    # callback function: the signal of the spinbutton is used to change the text of the label
    def spin_selected(self, event):
        self.label.set_text("Threshold value selected is: " + str(self.spinbutton_01.get_value_as_int()) + ".")


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
        os.system("exit")
        #os.system("return [n]")
        
    #def on_close_clicked(self, button):
        #print("Closing application")
        #Gtk.main_quit()

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
        
win = ButtonWindow()
win.set_position(Gtk.WindowPosition.CENTER)
win.connect("destroy", Gtk.main_quit)
win.show_all()
Gtk.main()
