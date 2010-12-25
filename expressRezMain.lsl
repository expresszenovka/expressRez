//---------------------------------
// expressRez Main Script
// version 1.0  (December 25, 2010)
// https://github.com/expresszenovka/expressRez
// ---------------------
// Copyright Express Zenovka, 2010-2011
// GNU GPL http://www.gnu.org/licenses/gpl.html
//---------------------------------

//------- Variables -------//

// static communication strings
string SET_MESSAGE = "SET_IT";
string DEL_MESSAGE = "DELETE";
string MOV_MESSAGE = "MOV";

// static user messages
string TOUCH_TO_START = "Touch prim to get started.";
string NO_NOTECARD = "Please add the positions notecard to this box and then touch it again.";
string STATE_READING_ALERT = "Reading notecard: ";
string STATE_READING_FINISHED = "Done reading notecard.";
string DIALOG_TIMED_OUT = "Dialog timed out. Touch to see dialog again.";
string MISSING_PRIM = " is missing from this object.";
string FINISHED_MESSAGE = "This build has been set. Just delete this box now.";

// static menu components
string MENU_DIALOG = "Choose an option.";
string MENU_REZ_OPTION = "Rez";
string MENU_FIN_OPTION = "Cancel";
string MENU_SET_OPTION = "Set";
string MENU_DEL_OPTION = "Delete";

// "static" menus
list MENU_NO_REZ = [];
list MENU_REZ = [];

// static timeout values
integer DIALOG_TIMEOUT = 30;
float POSITION_TIMEOUT = 0.5;

// communication vars
integer master_channel;
integer dialog_channel;
integer listen_handle;

// reading vars
integer line;
string notecard;
key read_line_id;

// prim vars
list prims;
list e_prims;

// location vars

vector last_pos;
rotation last_rot;

//------- Functions -------//

updatePositions()
{
    if (llGetPos() == last_pos && llGetRot() == last_rot)
    {
        return;
    }
    last_pos = llGetPos();
    last_rot = llGetRot();
    integer i = 0;
    integer l =  llGetListLength(e_prims);
    vector v; rotation r;
    for (i = 0; i < l; i += 3)
    {
        v = ((vector) llList2String(e_prims, i + 1) * last_rot) + last_pos;
        r = (rotation) llList2String(e_prims, i + 2) * last_rot;
        llShout(llList2Integer(e_prims, i), MOV_MESSAGE + "|" + (string) v + "|" + (string) r);
    }
}

//------- States -------//
default
{
    on_rez(integer start_param)
    {
        llResetScript();
    }
    state_entry()
    {
        MENU_NO_REZ = [MENU_REZ_OPTION, MENU_FIN_OPTION];
        MENU_REZ = [MENU_SET_OPTION, MENU_DEL_OPTION, MENU_FIN_OPTION];
        master_channel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
        dialog_channel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
        llOwnerSay(TOUCH_TO_START);
    }
    touch_start(integer num_detected)
    {
        // boo-hoo if you have click wars.
        if (llDetectedKey(0) == llGetOwner())
        {
            if (llGetInventoryNumber(INVENTORY_NOTECARD) < 1)
            {
                llOwnerSay(NO_NOTECARD);
            }
            else
            {
                notecard = llGetInventoryName(INVENTORY_NOTECARD, 0);
                state reading;
            }
        }
    }
}

state reading
{
    on_rez(integer start_param)
    {
        llResetScript();
    }
    state_entry()
    {
        llOwnerSay(STATE_READING_ALERT + notecard);
        line = 0;
        read_line_id = llGetNotecardLine(notecard, line++);
    }
    dataserver(key request_id, string data)
    {
        if(request_id == read_line_id)
        {
            if(data == EOF)
            {
                state no_rez;
            }
            else
            {
                prims += [data];
            }
            read_line_id = llGetNotecardLine(notecard, line++);
        }
    }
    state_exit()
    {
        llOwnerSay(STATE_READING_FINISHED);
    }
    touch_start(integer num_detected)
    {
        //http://jira.secondlife.com/browse/SVC-3017
    }
}

state no_rez
{
    on_rez(integer start_param)
    {
        // probably unecessary but better safe than sorry
        llResetScript();
    }
    state_entry()
    {
        llListenRemove(listen_handle);
        listen_handle = llListen(dialog_channel, "", llGetOwner(), "");
        llSetTimerEvent(DIALOG_TIMEOUT);
        llDialog(llGetOwner(), MENU_DIALOG, MENU_NO_REZ, dialog_channel);
    }
    touch_start(integer num_detected)
    {
        if (llDetectedKey(0) == llGetOwner())
        {
            llListenRemove(listen_handle);
            listen_handle = llListen(dialog_channel, "", llGetOwner(), "");
            llSetTimerEvent(DIALOG_TIMEOUT);
            llDialog(llGetOwner(), MENU_DIALOG, MENU_NO_REZ, dialog_channel);
        }
    }
    listen(integer channel, string name, key id, string message)
    {
        // double checking
        if (channel == dialog_channel && id == llGetOwner())
        {
            if (message == MENU_FIN_OPTION)
            {
                llSetTimerEvent(0);
                llListenRemove(listen_handle);
            }
            else if (message == MENU_REZ_OPTION)
            {
                state rez;
            }
        }
    }
    timer()
    {
        llSetTimerEvent(0);
        llListenRemove(listen_handle);
        llOwnerSay(DIALOG_TIMED_OUT);
    }
    state_exit()
    {
        // just playing it safe
        llSetTimerEvent(0);
    }
    changed(integer change)
    {
        // catch changed owner.
        if(change & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
}

state rez
{
    on_rez(integer start_param)
    {
        // probably unecessary but better safe than sorry
        llResetScript();
    }
    state_entry()
    {
        integer i = 0;
        integer l = llGetListLength(prims);
        list prim;
        e_prims = [];
        for (i = 0; i < l; i++)
        {
            prim = llParseString2List(llList2String(prims, i), ["|"], []);
            if (llGetInventoryType(llList2String(prim,0)) != INVENTORY_NONE)
            {
                llRezObject(llList2String(prim,0), llGetPos() + <0.0,0.0,1.0>, ZERO_VECTOR, ZERO_ROTATION, master_channel - i);
                e_prims += llListReplaceList(prim, [master_channel - i], 0, 0);
            }
            else
            {
                llOwnerSay(llList2String(prim,0) + MISSING_PRIM);
            }
            // don't want no gray goo
            llSleep(1);
        }
        updatePositions();
        // scales waiting time based on number of prims to manipulate
        llSetTimerEvent(POSITION_TIMEOUT * llGetListLength(prims));
        // showing dialog after rezzing everything out
        llListenRemove(listen_handle);
        listen_handle = llListen(dialog_channel, "", llGetOwner(), "");
        llDialog(llGetOwner(), MENU_DIALOG, MENU_REZ, dialog_channel);
    }
    touch_start(integer num_detected)
    {
        if (llDetectedKey(0) == llGetOwner())
        {
            llListenRemove(listen_handle);
            listen_handle = llListen(dialog_channel, "", llGetOwner(), "");
            llSetTimerEvent(POSITION_TIMEOUT * llGetListLength(prims));
            llDialog(llGetOwner(), MENU_DIALOG, MENU_REZ, dialog_channel);
        }
    }
    listen(integer channel, string name, key id, string message)
    {
        // double checking
        if (channel == dialog_channel && id == llGetOwner())
        {
            if (message == MENU_FIN_OPTION)
            {
                llListenRemove(listen_handle);
            }
            else if (message == MENU_SET_OPTION)
            {
                integer a = 0;
                integer b =  llGetListLength(e_prims);
                for (a = 0; a < b; a+=3)
                {
                    llShout(llList2Integer(e_prims, a), SET_MESSAGE);
                }
                state finished;
            }
            else if (message == MENU_DEL_OPTION)
            {
                integer a = 0;
                integer b =  llGetListLength(e_prims);
                for (a = 0; a < b; a+=3)
                {
                    llShout(llList2Integer(e_prims, a), DEL_MESSAGE);
                }
                state no_rez;
            }
        }
    }
    timer()
    {
        updatePositions();
    }
    state_exit()
    {
        // just playing it safe
        llSetTimerEvent(0);
    }
    changed(integer change)
    {
        // catch changed owner.
        if(change & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
}

state finished
{
    state_entry()
    {
        llOwnerSay(FINISHED_MESSAGE);
    }
    touch_start(integer num_detected)
    {
        if (llDetectedKey(0) == llGetOwner())
        {
            llOwnerSay(FINISHED_MESSAGE);
        }
    }
}