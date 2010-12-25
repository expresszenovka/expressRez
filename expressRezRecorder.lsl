//---------------------------------
// expressRez Prim Recorder
// version 1.0  (December 25, 2010)
// https://github.com/expresszenovka/expressRez
// ---------------------
// Copyright Express Zenovka, 2010-2011
// GNU GPL http://www.gnu.org/licenses/gpl.html
//---------------------------------

//------- Variables -------//

// static variables
string ASK_MESSAGE = "ASKING";
integer ASK_CHANNEL = -1234567;
integer WAIT_TIMEOUT = 30;

// prim vars
list prims;

//------- States -------//
default
{
    touch_start(integer number)
    {
        state waiting;
    }
}

state waiting
{
    state_entry()
    {
        prims = [];
        llListen(ASK_CHANNEL, "", NULL_KEY, "");
        llShout(ASK_CHANNEL, ASK_MESSAGE);
        llSetTimerEvent(WAIT_TIMEOUT);
    }
    listen(integer channel, string name, key id, string message)
    {
        integer bad_message = FALSE;
        
        list split = llParseString2List(message, ["|"], []);
        
        vector pos_in;
        rotation rot_in;
        
        if (llGetListLength(split) != 2)
        {
            bad_message = TRUE;
        }
        else
        {
            vector global = (vector) llList2String(split, 0);
            vector local = (vector) llList2String(split, 1);
            // this check breaks when global is infact zero BUT
            // the script is running from the next sim over
            // oops
            if ((global == ZERO_VECTOR && llGetRegionCorner() != ZERO_VECTOR) ||
                (local == ZERO_VECTOR && llList2Vector(llGetObjectDetails(id,[OBJECT_POS]),0) != ZERO_VECTOR))
            {
                bad_message = TRUE;
            }
            else
            {
                // this prevents mixing floats of the wrong scale
                // and possibly losing precision
                // read following URL for more information
                // http://lslwiki.net/lslwiki/wakka.php?wakka=float
                pos_in = (global - llGetRegionCorner()) + local;
                rot_in = llList2Rot(llGetObjectDetails(id,[OBJECT_ROT]),0);
            }
        }

        if (bad_message == FALSE)
        {
            vector relative_pos = (pos_in - llGetPos()) / llGetRot();
            rotation relative_rot = rot_in / llGetRot();
        
            prims += [llList2String(llGetObjectDetails(id,[OBJECT_NAME]),0) + "|" + (string) relative_pos + "|" + (string) relative_rot];
        }
    }
    timer()
    {
        llOwnerSay("!---- START ----!");
        integer l = llGetListLength(prims);
        integer i = 0;
        string s_temp = "";
        string p_temp = "";
        for (i = 0; i < l; i++)
        {
            p_temp = llList2String(prims, i) + "\n";
            if (llStringLength(s_temp) + llStringLength(p_temp) > 1023)
            {
                llOwnerSay(s_temp);
                s_temp = "";
            }
            s_temp += p_temp;
        }
        // adding the last one
        if (s_temp != "")
        {
            llOwnerSay(s_temp);
        }
        // spew em out
        llOwnerSay("!---- DONE ----!");
        state default;
    }
    touch_start(integer num_detected)
    {
        //http://jira.secondlife.com/browse/SVC-3017
    }
}