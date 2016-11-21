.pragma library
//Enums intended to efficientize localStorage memory consumption
//and code semantics improvement (matando 2 pájaros de un tiro ;-D)
var RegistryTypes = {
    IDLE:           0x000,
    WORKING:        0x100,
    PAUSE:          0x200,
    SUMMARIZING:    0x300,
    SHORT_BREAK:    0x400,
    LONG_BREAK:     0x500,
    RINGING:        0x600,
    MASK:           0xF00
};

var States = {
    WORKING:        's'+RegistryTypes.WORKING,
    PAUSE:          's'+RegistryTypes.PAUSE,
    BREAK:          's'+RegistryTypes.SHORT_BREAK,
    SUMMARIZING:    's'+RegistryTypes.SUMMARIZING,
    IDLE:           's'+RegistryTypes.IDLE,
    RINGING:        's'+1,
    ALMOST_RINGING: 's'+2,
};

var Statuses = {
    IN_PROGRESS:    0x00,
    NORMAL_END:     0x10,
    CORRECT_END:    0x20,
    INCORRECT_END:  0x30,
    MASK:           0xF0
};

var IdleStatus = {//        Should be   0x0XX
    IDLE:                               0x00,
    TODO_ADD:                           0x01,
    TODO_EDIT:                          0x02,
    TODO_SUBDIVIDE:                     0x03,
    //etc... (Should state all actions when they would be useful for sth)
    SCHEDULED_TODO_START:               0X10,
    TODO_SELECTED:                      0X20,
        TODO_DOUBLECLICKED:             0X21,
        TODO_DBUS_STARTED:              0X22,
    MAX_TIME_EXCEEDED:                  0x30
};

var WorkingStatus = {//     Should be   0x1XX
    RUNNING:                            0x00,
        NOTE:                           0x01,
        SUBDIVIDE:                      0x02,
    TIMEOUT:                            0x10,
    MANUAL_FINISH:                      0x20,
        ENDED_FROM_FULL_REPRESENTATION: 0x21,
        RIGHT_CLICKED_IN_CONTEXT_MENU:  0x22,
        MAIN_ACTION_BUTTON_CLICKED:     0x24,
        EXTERNALLY_ENDED:               0x23,
        PAUSE:                          0x24,
    DROP:                               0x30
};

var PauseStatus = {//       Can be 0x4XX or 0x5XX
    RUNNING:                            0x00,
    RESUME:                             0x10,
        MAIN_ACTION_BUTTON_CLICKED:     0x11,
        CLICKED_IN_FULL_REPRESENTATION: 0x12,
    TIMEOUT:                            0x20,
}

var BreakStatus = {//       Can be 0x4XX or 0x5XX
    RUNNING:                            0x00,
    TIMEOUT:                            0x10,
    MANUAL_FINISH:                      0X20,
        MAIN_ACTION_BUTTON_CLICKED:     0x21,
        CLICKED_IN_FULL_REPRESENTATION: 0x22,
};

var SummarizingStatus = {// Should be   0x3XX
    EDITING:                            0x00,
    FINISHED_EDITION:                   0x10,
        MAIN_ACTION_BUTTON_CLICKED:     0x11,
        AUTOMATIC_MODE_AFTER_EDITION:   0x12,
        CLICKED_IN_FULL_REPRESENTATION: 0x13,
        TAKE_BREAK:                     0x14,
    SKIP_BREAK:                         0x20,
    TIMEOUT:                            0x30,
};

var RingingStatus = {//     Should be   0x6XX
    RINGING:                            0x00,
    CLICKED:                            0x10,
        MAIN_ACTION_BUTTON_CLICKED:     0x11,
        CLICKED_IN_FULL_REPRESENTATION: 0x12,
    TIMEOUT:                            0x20
};

var TomateImageColor = {
    RED:                                0,
    YELLOW:                             1,
    GREEN:                              2
};

if (Object.freeze){
    Object.freeze(States);
    Object.freeze(Statuses);
    Object.freeze(IdleStatus);
    Object.freeze(BreakStatus);
    Object.freeze(PauseStatus);
    Object.freeze(WorkingStatus);
    Object.freeze(RingingStatus);
    Object.freeze(RegistryTypes);
    Object.freeze(TomateImageColor);
    Object.freeze(SummarizingStatus);
};
