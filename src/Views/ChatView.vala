/*
 * Copyright (c) 2019 Andrew Vojak (https://avojak.com)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Andrew Vojak <andrew.vojak@gmail.com>
 */

public abstract class Iridium.Views.ChatView : Gtk.Grid {

    // TODO: Disable or somehow indicate that you are disconnected from a server
    //       and cannot send messages.

    // TODO: Should toggle these colors slightly depending on whether user is in dark mode or not
    // Colors defined by the elementary OS Human Interface Guidelines
    private static string COLOR_STRAWBERRY = "#ed5353"; // "#c6262e";
    private static string COLOR_ORANGE = "#ffa154"; // "#f37329";
    private static string COLOR_LIME = "#9bdb4d"; // "#68b723";
    private static string COLOR_BLUEBERRY = "#64baff"; // "#3689e6";
    //  private static string COLOR_GRAPE = "#a56de2";

    protected Gtk.TextView text_view;

    private Gtk.ScrolledWindow scrolled_window;
    private Gtk.Entry entry;

    private Gdk.Cursor cursor_pointer;
    private Gdk.Cursor cursor_text;

    public ChatView () {
        Object (
            orientation: Gtk.Orientation.VERTICAL
        );
    }

    construct {
        text_view = new Gtk.TextView ();
        text_view.pixels_below_lines = 3;
        text_view.border_width = 12;
        text_view.wrap_mode = Gtk.WrapMode.WORD_CHAR;
        /* text_view.left_margin = 140; */
        text_view.indent = get_indent ();
        text_view.monospace = true;
        text_view.editable = false;
        text_view.cursor_visible = false;
        text_view.vexpand = true;
        text_view.hexpand = true;

        // Initialize the buffer iterator
        Gtk.TextIter iter;
        text_view.get_buffer ().get_end_iter (out iter);

        scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled_window.add (text_view);

        entry = new Gtk.Entry ();
        entry.hexpand = true;
        entry.margin = 6;
        entry.secondary_icon_tooltip_text = "Clear";

        attach (scrolled_window, 0, 0, 1, 1);
        attach (entry, 0, 1, 1, 1);

        create_text_tags ();

        cursor_pointer = new Gdk.Cursor.from_name (text_view.get_display (), "pointer");
        cursor_text = new Gdk.Cursor.from_name (text_view.get_display (), "text");

        entry.activate.connect (() => {
            message_to_send (entry.get_text ());
            entry.set_text ("");
        });
        entry.changed.connect (() => {
            if (entry.text != "") {
                entry.secondary_icon_name = "edit-clear-symbolic";
            } else {
                entry.secondary_icon_name = null;
            }
        });
        entry.icon_release.connect ((icon_pos, event) => {
            if (icon_pos == Gtk.EntryIconPosition.SECONDARY) {
                entry.set_text ("");
            }
        });

        /* scrolled_window.get_vadjustment ().value_changed.connect (() => {
            print (scrolled_window.get_vadjustment ().value.to_string () + "\n");
        }); */

        // This approach for detecting the mouse motion over a TextTag and changin the cursor
        // was adapted from: 
        // https://www.kksou.com/php-gtk2/sample-codes/insert-links-in-GtkTextView-Part-4-Change-Cursor-over-Link.php
        text_view.motion_notify_event.connect ((event) => {
            int buffer_x;
            int buffer_y;
            text_view.window_to_buffer_coords (Gtk.TextWindowType.TEXT, (int) event.x, (int) event.y, out buffer_x, out buffer_y);

            Gtk.TextIter pos;
            text_view.get_iter_at_location (out pos, buffer_x, buffer_y);

            // TODO: Maybe also add self username?
            var username_tag = text_view.get_buffer ().get_tag_table ().lookup ("username");
            var self_username_tag = text_view.get_buffer ().get_tag_table ().lookup ("self-username");
            var inline_username_tag = text_view.get_buffer ().get_tag_table ().lookup ("inline-username");
            //  var inline_self_username_tag = text_view.get_buffer ().get_tag_table ().lookup ("inline-self-username");
            var window = text_view.get_window (Gtk.TextWindowType.TEXT);
            if (window != null) {
                if ((username_tag != null && pos.has_tag (username_tag)) ||
                    (self_username_tag != null && pos.has_tag (self_username_tag)) ||
                    (inline_username_tag != null && pos.has_tag (inline_username_tag))) {
                    window.set_cursor (cursor_pointer);
                } else {
                    window.set_cursor (cursor_text);
                }
            }
        });

        //  text_view.button_release_event.connect ((event) => {
        //      // Ensure this was a click from mouse button 1
        //      if (event.type != Gdk.BUTTON_RELEASE || event.state != Gdk.BUTTON1_MASK) {
        //          return false;
        //      }
        //      print ("Click!!!! \n");
        //  });
    }

    private void create_text_tags () {
        var buffer = text_view.get_buffer ();
        var color = Gdk.RGBA ();

        // Other usernames
        color.parse (COLOR_BLUEBERRY);
        unowned Gtk.TextTag username_tag = buffer.create_tag ("username");
        username_tag.foreground_rgba = color;
        username_tag.weight = Pango.Weight.SEMIBOLD;
        username_tag.event.connect (on_username_clicked);

        // Self username
        color.parse (COLOR_LIME);
        unowned Gtk.TextTag self_username_tag = buffer.create_tag ("self-username");
        self_username_tag.foreground_rgba = color;
        self_username_tag.weight = Pango.Weight.SEMIBOLD;
        self_username_tag.event.connect (on_username_clicked);

        // Errors
        color.parse (COLOR_STRAWBERRY);
        unowned Gtk.TextTag error_tag = buffer.create_tag ("error");
        error_tag.foreground_rgba = color;
        error_tag.weight = Pango.Weight.SEMIBOLD;

        // Inline usernames
        color.parse (COLOR_ORANGE);
        unowned Gtk.TextTag inline_username_tag = buffer.create_tag ("inline-username");
        inline_username_tag.foreground_rgba = color;
        inline_username_tag.event.connect (on_username_clicked);

        // Inline self username
        color.parse (COLOR_LIME);
        unowned Gtk.TextTag inline_self_username_tag = buffer.create_tag ("inline-self-username");
        inline_self_username_tag.foreground_rgba = color;

        // Hyperlinks
        color.parse (COLOR_BLUEBERRY);
        unowned Gtk.TextTag hyperlink_tag = buffer.create_tag ("hyperlink");
        hyperlink_tag.foreground_rgba = color;
    }

    // TODO: Need to figure out a good way to lock scrolling... Might be annoying
    //       to experience the auto-scroll when you're looking back at old
    //       messages...
    protected void do_autoscroll () {
        var buffer_end_mark = text_view.get_buffer ().get_mark ("buffer-end");
        if (buffer_end_mark != null) {
            text_view.scroll_mark_onscreen (buffer_end_mark);
        }
    }

    public void set_entry_focus () {
        entry.grab_focus_without_selecting ();
        entry.set_position (-1);
    }

    private bool on_username_clicked (Gtk.TextTag source, GLib.Object event_object, Gdk.Event event, Gtk.TextIter iter) {
        if (event.type == Gdk.EventType.BUTTON_RELEASE) {
            iter.backward_word_start ();
            Gtk.TextIter word_start = iter;
            iter.forward_word_end ();
            Gtk.TextIter word_end = iter;
            var username = word_start.get_text (word_end);
            if (entry.text.length == 0) {
                entry.text = username + ": ";
                set_entry_focus ();
            } else {
                entry.text += username;
                set_entry_focus ();
            }
        }
        return false;
    }

    public abstract void display_self_private_msg (Iridium.Services.Message message);
    public abstract void display_server_msg (Iridium.Services.Message message);

    protected abstract int get_indent ();

    public signal void message_to_send (string message);

}
