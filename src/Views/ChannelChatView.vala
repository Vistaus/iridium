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

    protected override int get_indent () {
        return -140; // TODO: Figure out how to compute this
    }

    public void display_priv_msg (Iridium.Services.Message message) {
        var rich_text = new Iridium.Models.OthersPrivMessageText (message);
        rich_text.display (text_view.get_buffer ());
    }

    public void display_self_priv_msg (Iridium.Services.Message message) {
        var rich_text = new Iridium.Models.SelfPrivMessageText (message);
        rich_text.display (text_view.get_buffer ());
    }

    // TODO: Can probably refactor this out into the base class
    public void display_server_msg (Iridium.Services.Message message) {
        var rich_text = new Iridium.Models.ServerMessageText (message);
        rich_text.display (text_view.get_buffer ());
    }

    public void display_channel_error_msg (Iridium.Services.Message message) {

    }

}