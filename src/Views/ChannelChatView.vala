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

public class Iridium.Views.ChannelChatView : Iridium.Views.ChatView {

    private Gee.List<string> usernames = new Gee.ArrayList<string> ();

    protected override int get_indent () {
        return -140; // TODO: Figure out how to compute this
    }

    public override void display_self_private_msg (Iridium.Services.Message message) {
        var rich_text = new Iridium.Models.SelfPrivateMessageText (message);
        rich_text.set_usernames (usernames);
        rich_text.display (text_view.get_buffer ());
        do_autoscroll ();
    }

    public override void display_server_msg (Iridium.Services.Message message) {
        var rich_text = new Iridium.Models.ServerMessageText (message);
        rich_text.display (text_view.get_buffer ());
        do_autoscroll ();
    }

    public void display_private_msg (Iridium.Services.Message message) {
        var rich_text = new Iridium.Models.OthersPrivateMessageText (message);
        rich_text.set_usernames (usernames);
        rich_text.display (text_view.get_buffer ());
        do_autoscroll ();
    }

    public void display_channel_error_msg (Iridium.Services.Message message) {
        // TODO: Implement
    }

    public void set_usernames (Gee.List<string> usernames) {
        this.usernames = usernames;
    }

}
