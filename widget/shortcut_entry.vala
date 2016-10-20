using Gtk;

namespace Widgets {
    public class ShortcutEntry : Gtk.EventBox {
        public Gdk.RGBA active_frame_color;
        public Gdk.RGBA background_color;
        public Gdk.RGBA hint_color;
        public Gdk.RGBA normal_frame_color;
        public Gdk.RGBA shortcut_background_color;
        public Gdk.RGBA shortcut_font_color;
        public Gdk.RGBA shortcut_frame_color;
        public int height = 24;
        public int shortcut_font_padding_x = 4;
        public int shortcut_font_padding_y = 0;
        public int shortcut_font_size = 9;
        public int shortcut_key_padding_x = 4;
        public int shortcut_key_padding_y = 0;
        public int shortcut_key_spacing = 5;
        public string shortcut = "";
        public Cairo.ImageSurface button_left_surface;
        public Cairo.ImageSurface button_right_surface;
        
        public signal void change_key(string new_key);
        
        public ShortcutEntry() {
            Intl.bindtextdomain(GETTEXT_PACKAGE, "/usr/share/locale");
            
			button_left_surface = new Cairo.ImageSurface.from_png(Utils.get_image_path("shortcut_button_left.png"));
			button_right_surface = new Cairo.ImageSurface.from_png(Utils.get_image_path("shortcut_button_right.png"));
            
            set_visible_window(false);
            set_can_focus(true);
            
            set_size_request(-1, 24);
            
            normal_frame_color = Gdk.RGBA();
            normal_frame_color.red = 0;
            normal_frame_color.green = 0;
            normal_frame_color.blue = 0;
            normal_frame_color.alpha = 0.1;
            
            active_frame_color = Utils.hex_to_rgba("#2ca7f8");
            background_color = Utils.hex_to_rgba("#ffffff");
            hint_color = Utils.hex_to_rgba("#ADAEAF");
            
            shortcut_background_color = Utils.hex_to_rgba("#69AAFF");
            shortcut_background_color.alpha = 0.15;
            shortcut_frame_color = Utils.hex_to_rgba("#5F9FD9");
            shortcut_frame_color.alpha = 0.30;
            shortcut_font_color = Utils.hex_to_rgba("#303030");
            
            draw.connect(on_draw);
            button_press_event.connect((w, e) => {
                    grab_focus();
                    
                    queue_draw();
                    
                    return false;
                });
            key_press_event.connect((w, e) => {
                    string keyname = Keymap.get_keyevent_name(e);
                    
                    if (keyname == "Backspace") {
                        shortcut = "";
                        change_key(shortcut);
                        
                        queue_draw();
                    } else if (keyname == "Ctrl + Tab" || keyname == "Ctrl + Shift + Tab") {
                        return false;
                    } else if (keyname.has_prefix("F") || keyname.contains("+")) {
                        shortcut = keyname;
                        change_key(shortcut);
                        
                        queue_draw();
                    }
                    
                    return false;
                });
        }
        
        public void set_text(string text) {
            shortcut = text;
            
            queue_draw();
        }
        
        public string get_text() {
            return shortcut;
        }
        
        private bool on_draw(Gtk.Widget widget, Cairo.Context cr) {
            Gtk.Allocation rect;
            widget.get_allocation(out rect);

            if (is_focus) {
                Draw.stroke_rounded_rectangle(cr, 0, 0, rect.width, rect.height, 4, active_frame_color, background_color);
            } else {
                Draw.stroke_rounded_rectangle(cr, 0, 0, rect.width, rect.height, 4, normal_frame_color, background_color);
            }
            
            if (shortcut == "") {
                cr.set_source_rgba(hint_color.red, hint_color.green, hint_color.blue, hint_color.alpha);
                Draw.draw_text(
                    cr,
                    _("Please enter a new shortcut"),
                    shortcut_font_padding_x,
                    shortcut_font_padding_y,
                    rect.width - shortcut_font_padding_x * 2,
                    rect.height - shortcut_font_padding_y * 2,
                    shortcut_font_size);
            } else {
                int x = shortcut_font_padding_x;
                int y = shortcut_font_padding_y;
                var shortcut_keys = shortcut.split(" + ");
                foreach (string key in shortcut_keys) {
                    var font_description = new Pango.FontDescription();
                    font_description.set_size((int)(shortcut_font_size * Pango.SCALE));
        
                    var layout = Pango.cairo_create_layout(cr);
                    layout.set_font_description(font_description);
                    layout.set_text(key, key.length);
                    layout.set_alignment(Pango.Alignment.LEFT);
                    layout.set_single_paragraph_mode(true);
                    layout.set_ellipsize(Pango.EllipsizeMode.END);

                    int text_width, text_height;
                    layout.get_pixel_size(out text_width, out text_height);
                    
                    int key_width = int.max(text_width, 20);

                    int button_width = button_left_surface.get_width();
                    int button_height = button_left_surface.get_height();
                    int button_y = (height - button_height) / 2;
                    int shortcut_key_width = key_width + shortcut_key_padding_x * 2;
                    
                    Draw.draw_surface(cr, button_left_surface, x, button_y);
                    Draw.draw_surface(cr, button_right_surface, x + shortcut_key_width - button_width, button_y);
                    
                    cr.set_source_rgba(shortcut_background_color.red, shortcut_background_color.green, shortcut_background_color.blue, shortcut_background_color.alpha);
                    Draw.draw_rectangle(cr, x + button_width, button_y, shortcut_key_width - button_width * 2, button_height);
                    
                    cr.set_source_rgba(shortcut_frame_color.red, shortcut_frame_color.green, shortcut_frame_color.blue, shortcut_frame_color.alpha);
                    Draw.draw_rectangle(cr, x + button_width, button_y, shortcut_key_width - button_width * 2, 1);
                    Draw.draw_rectangle(cr, x + button_width, button_y + button_height - 1, shortcut_key_width - button_width * 2, 1);
                    
                    int render_y = y + int.max(0, (height - text_height) / 2);
                    
                    cr.set_source_rgba(shortcut_font_color.red, shortcut_font_color.green, shortcut_font_color.blue, shortcut_font_color.alpha);
                    cr.move_to(x + (key_width - text_width) / 2 + shortcut_key_padding_x, render_y);
                    Pango.cairo_update_layout(cr, layout);
                    Pango.cairo_show_layout(cr, layout);
                    
                    x += key_width + shortcut_key_spacing + shortcut_key_padding_x * 2;
                }
                
            }
            
            return true;
        }
    }
}