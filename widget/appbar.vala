using Gtk;
using Widgets;

namespace Widgets {
    public class Appbar : Gtk.EventBox {
        public Tabbar tabbar;
        public Box max_toggle_box;
        
        public ImageButton menu_button;
        public ImageButton min_button;
        public ImageButton max_button;
        public ImageButton unmax_button;
        public ImageButton close_button;
        
        public Appbar(Tabbar tab_bar, bool quake_mode) {
            tabbar = tab_bar;
            visible_window = false;
            
            draw.connect(on_draw);
            
            menu_button = new ImageButton("window_menu");
            min_button = new ImageButton("window_min");
            max_button = new ImageButton("window_max");
            unmax_button = new ImageButton("window_unmax");
            close_button = new ImageButton("window_close");
            
            max_toggle_box = new Box(Gtk.Orientation.HORIZONTAL, 0);
            
            min_button.button_press_event.connect((w, e) => {
                    ((Gtk.Window) w.get_toplevel()).iconify();
                    
                    return false;
                });
            max_button.button_press_event.connect((w, e) => {
                    ((Gtk.Window) w.get_toplevel()).maximize();

                    return false;
                });
            unmax_button.button_press_event.connect((w, e) => {
                    ((Gtk.Window) w.get_toplevel()).unmaximize();

                    return false;
                });
            
            Box box = new Box(Gtk.Orientation.HORIZONTAL, 0);
            
            max_toggle_box.add(max_button);
            if (!quake_mode) {
                box.pack_start(tabbar, true, true, 0);
            }
            box.pack_start(menu_button, false, false, 0);
            box.pack_start(min_button, false, false, 0);
            box.pack_start(max_toggle_box, false, false, 0);
            box.pack_start(close_button, false, false, 0);
            
            add(box);
        }
        
        public void update_max_button() {
            Utils.remove_all_children(max_toggle_box);
            
            if ((((Gtk.Window) get_toplevel()).get_window().get_state() & Gdk.WindowState.MAXIMIZED) == Gdk.WindowState.MAXIMIZED) {
                max_toggle_box.add(unmax_button);
            } else {
                max_toggle_box.add(max_button);
            }
            
            max_toggle_box.show_all();
        }
        
        private bool on_draw(Gtk.Widget widget, Cairo.Context cr) {
            Gtk.Allocation rect;
            widget.get_allocation(out rect);
            
            Widgets.Window window = (Widgets.Window) this.get_toplevel();

            cr.set_source_rgba(0, 0, 0, window.background_opacity);
            cr.set_operator (Cairo.Operator.SOURCE);
            cr.paint();
            cr.set_operator (Cairo.Operator.OVER);
            
            cr.set_source_rgba(1, 1, 1, 0.1);
            Draw.draw_rectangle(cr, 0, rect.height - 1, rect.width, 1);
            
            foreach(Gtk.Widget w in this.get_children()) {
                w.draw(cr);
            };

            return true;
        }        
    }
}