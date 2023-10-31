
drop table MY_USER_ROLES;
drop table my_users;
drop table MY_RGD_OBJECT_WATCH;
drop table MY_RGD_ONT_WATCH;
drop table MY_RGD_MESSAGE_CENTER;


CREATE TABLE
    MY_USER_ROLES
    (
        USERNAME VARCHAR2(45) NOT NULL,
        ROLE VARCHAR2(45) NOT NULL,
        EMAIL_DIGEST NUMBER NOT NULL,
        PRIMARY KEY (USERNAME,ROLE)
    );

COMMENT ON TABLE MY_USER_ROLES IS 'Table containing user to role mappings';

    CREATE TABLE
    MY_USERS
    (
        USERNAME VARCHAR2(45) NOT NULL,
        PASSWORD VARCHAR2(255) NOT NULL,
        ENABLED NUMBER NOT NULL,
        PRIMARY KEY (USERNAME)
    );
COMMENT ON TABLE MY_USERS IS 'Table containing user accounts';

    CREATE TABLE
    MY_RGD_OBJECT_WATCH
    (
        USERNAME VARCHAR2(100) NOT NULL,
        RGD_ID NUMBER NOT NULL,
        NOMEN Number,
        GO NUMBER,
        DISEASE NUMBER,
        PHENOTYPE NUMBER,
        PATHWAY NUMBER,
        STRAIN NUMBER,
        REFERENCE NUMBER,
        ALTERED_STRAINS NUMBER,
        PROTEIN NUMBER,
        INTERACTION NUMBER,
        REFSEQ_STATUS NUMBER,
        EXDB NUMBER,
        PRIMARY KEY (USERNAME, RGD_ID)
    );
COMMENT ON TABLE MY_RGD_OBJECT_WATCH IS 'Table containing binary representation of item with RGD IDs to watch.  1 means watch, 0 means do not watch.  This info is used by the notification pipeline';


    CREATE TABLE
    MY_RGD_ONT_WATCH
    (
        USERNAME VARCHAR2(100) NOT NULL,
        ACC_ID VARCHAR2(255) NOT NULL,
        GENES_RAT NUMBER,
        GENES_MOUSE NUMBER,
        GENES_HUMAN NUMBER,
        QTLS_RAT NUMBER,
        QTLS_MOUSE NUMBER,
        QTLS_HUMAN NUMBER,
        STRAINS NUMBER,
        VARIANTS_RAT NUMBER,
        PRIMARY KEY (USERNAME, ACC_ID)
    );
COMMENT ON TABLE MY_RGD_ONT_WATCH IS 'Table containing binary representation of item with ACC Ids to watch.  1 means watch, 0 means do not watch.  This info is used by the notification pipeline';



CREATE TABLE
    MY_RGD_MESSAGE_CENTER
    (
        MESSAGE_ID NUMBER NOT NULL,
        USERNAME VARCHAR2(100) NOT NULL,
        title VARCHAR2(255) NOT NULL,
        MESSAGE CLOB NOT NULL,
        CREATED_DATE DATE NOT NULL,
        PRIMARY KEY (USERNAME, CREATED_DATE)
    );
COMMENT ON TABLE MY_RGD_MESSAGE_CENTER IS 'Table to hold user messages.  Messages are viewed in the myrgd message center';

CREATE SEQUENCE MY_MESSAGE_CENTER_SEQ
 START WITH     1
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;





-- use later

drop table my_rgd_obj_list;
drop table MY_RGD_OBJ_LIST_ITEM;

    CREATE TABLE
    MY_RGD_OBJ_LIST
    (
        USERNAME VARCHAR2(45) NOT NULL,
        LIST_ID NUMBER NOT NULL,
        LIST_NAME VARCHAR2(255) NOT NULL,
        LINK CLOB,
        DESCRIPTION VARCHAR2(255),
        OBJ_TYPE NUMBER NOT NULL,
        PRIMARY KEY (LIST_ID)
    );

    CREATE TABLE
    MY_RGD_OBJ_LIST_ITEM
    (
        LIST_ID NUMBER NOT NULL,
        RGD_ID NUMBER NOT NULL
    );

CREATE SEQUENCE myList_seq
 START WITH     1
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;

