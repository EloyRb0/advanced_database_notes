--Trigger Functions-
--ADDED UPDATE_DATE and UPDATED_BY_USER to table PET_CARE_LOG--

--INSERT TRIGGER--

CREATE OR REPLACE TRIGGER trg_pet_care_insert
BEFORE INSERT ON PET_CARE_LOG
FOR EACH ROW
BEGIN
    :NEW.UPDATE_DATE := SYSDATE;
    :NEW.UPDATED_BY_USER := USER;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'An error occurred during insert into PET_CARE_LOG: ' || SQLERRM);
END;
/

--UPDATE TRIGGER--

CREATE OR REPLACE TRIGGER trg_pet_care_update
BEFORE UPDATE ON PET_CARE_LOG
FOR EACH ROW
BEGIN
    IF USER != :OLD.UPDATED_BY_USER THEN
        RAISE_APPLICATION_ERROR(-20002, 'Update failed: You are only allowed to update records that you created.');
    END IF;

    :NEW.UPDATE_DATE := SYSDATE;

EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE NOT IN (-20002) 
            RAISE_APPLICATION_ERROR(-20003, 'An error occurred during update on PET_CARE_LOG: ' || SQLERRM);
        ELSE
            RAISE; 
        END IF;
END;
/


--DELETE TRIGGER--

CREATE OR REPLACE TRIGGER trg_pet_care_delete
BEFORE DELETE ON PET_CARE_LOG
FOR EACH ROW
BEGIN
    -- Check if the current user is JOEMANAGER
    IF USER != 'JOEMANAGER' THEN
        RAISE_APPLICATION_ERROR(-20004, 'Delete failed: Only the manager (JOEMANAGER) is authorized to delete records.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE NOT IN (-20004) THEN
            RAISE_APPLICATION_ERROR(-20005, 'An error occurred during delete on PET_CARE_LOG: ' || SQLERRM);
        ELSE
            RAISE; 
        END IF;
END;
/